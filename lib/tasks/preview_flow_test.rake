# frozen_string_literal: true

# rake remotion:preview_flow
#   — Mirrors VideoController#request_preview as closely as possible.
#   — Uses the real generation_prompt from the latest conversation that has one.
#   — Optionally pass a conversation_id: rake remotion:preview_flow[5]
#
# After the preview is created it optionally continues to render:
#   rake remotion:preview_flow          # preview only
#   RENDER=1 rake remotion:preview_flow # preview + render + poll until done

namespace :remotion do
  desc "Full preview flow test using real conversation data (mirrors VideoController)"
  task :preview_flow, [:conversation_id] => :environment do |_t, args|
    sep  = "=" * 70
    dash = "─" * 70

    puts "\n#{sep}"
    puts "  JOP Preview Flow Test  (mirrors VideoController#request_preview)"
    puts sep

    # ── 1. Find conversation ─────────────────────────────────────────────────

    conversation = if args[:conversation_id].present?
      ClaudeConversation.find_by(id: args[:conversation_id])
    else
      ClaudeConversation.where.not(generation_prompt: [nil, ""])
                        .order(created_at: :desc)
                        .first
    end

    unless conversation
      puts "\n❌  No conversation with a generation_prompt found."
      puts "    Run the chat first so Claude produces a Step-6 spec, then retry."
      exit 1
    end

    puts "\n  Conversation ID : #{conversation.id}"
    puts "  User ID         : #{conversation.user_id}"
    puts "  Video status    : #{conversation.video_status}"
    puts "  Prompt length   : #{conversation.generation_prompt.length} chars"
    puts "  Prompt preview  : #{conversation.generation_prompt.first(120).gsub(/\n/, ' ')}…\n\n"

    # Guard: don't start a new preview while a final render is running
    if conversation.rendering?
      puts "❌  Conversation is already rendering. Aborting."
      exit 1
    end

    # ── 2. Check Node health ─────────────────────────────────────────────────

    print "  Checking Remotion service health... "
    if RemotionService.healthy?
      puts "✓ online"
    else
      puts "❌ OFFLINE"
      puts "\n  Make sure the Node service is running:"
      puts "  cd JOP-Remotion && npm run dev\n\n"
      exit 1
    end

    # ── 3. Call generate_preview (exactly as VideoController does) ────────────

    puts "\n#{dash}"
    puts "  [1/2] Generating AI component + preview video…"
    puts dash

    prompt    = conversation.generation_prompt.strip
    start_t   = Time.current

    begin
      result = RemotionService.generate_preview(
        conversation,
        prompt,
        model:             "gpt-4o",
        width:             1920,
        height:            1080,
        duration_in_frames: 300,
        fps:               30
      )
    rescue RemotionService::ConfigurationError => e
      puts "\n❌  Remotion misconfigured: #{e.message}"
      exit 1
    rescue RemotionService::ApiError, RemotionService::RenderError => e
      puts "\n❌  Service error: #{e.message}"
      exit 1
    rescue ArgumentError => e
      puts "\n❌  Bad argument: #{e.message}"
      exit 1
    end

    elapsed = (Time.current - start_t).round(1)
    puts "\n  ✓ Done in #{elapsed}s\n\n"
    puts "  component_id    : #{result[:component_id]}"
    puts "  preview_token   : #{result[:preview_token]}"
    puts "  preview_url     : #{result[:preview_url]}"
    puts "  detected_skills : #{Array(result[:detected_skills]).join(', ').presence || '—'}"
    puts "  config          : width=#{result[:width]} height=#{result[:height]} " \
         "fps=#{result[:fps]} frames=#{result[:duration_in_frames]}"

    # ── 4. Persist to conversation (exactly as VideoController does) ──────────

    conversation.update!(
      component_id:             result[:component_id],
      preview_token:            result[:preview_token],
      preview_token_expires_at: 7.days.from_now,
      video_spec: {
        width:             result[:width],
        height:            result[:height],
        durationInFrames:  result[:duration_in_frames],
        fps:               result[:fps]
      },
      ai_model:        "gpt-4o",
      detected_skills: result[:detected_skills],
      video_status:    "previewing"
    )

    puts "\n  ✓ Conversation #{conversation.id} updated → video_status: previewing"

    remotion_base = ENV.fetch("REMOTION_SERVICE_URL", "http://localhost:3001")
    preview_full  = "#{remotion_base}#{result[:preview_url]}"

    puts "\n#{sep}"
    puts "  ✅  PREVIEW READY"
    puts sep
    puts "  Open in browser : #{preview_full}"
    puts "  Conversation ID : #{conversation.id}"
    puts "  Component ID    : #{result[:component_id]}"
    puts sep

    # ── 5. Optional: continue to render (RENDER=1) ────────────────────────────

    unless ENV["RENDER"] == "1"
      puts "\n  Tip: set RENDER=1 to continue and render the final video.\n\n"
      next
    end

    puts "\n#{dash}"
    puts "  [2/2] Starting final render…"
    puts dash

    config = conversation.video_spec || {}

    begin
      render_result = RemotionService.start_render(
        conversation,
        result[:component_id],
        width:             config["width"]            || 1920,
        height:            config["height"]           || 1080,
        fps:               config["fps"]              || 30,
        duration_in_frames: config["durationInFrames"] || 300
      )
    rescue RemotionService::Error => e
      puts "\n❌  Render start failed: #{e.message}"
      exit 1
    end

    conversation.mark_rendering!(render_result[:render_id])
    puts "\n  ✓ Render started"
    puts "  render_id : #{render_result[:render_id]}\n\n"

    # Poll until done
    puts "  Polling…"
    max_polls    = 120   # 10 min @ 5s interval
    last_pct     = -1
    poll_start   = Time.current

    max_polls.times do |i|
      sleep 5

      begin
        status = RemotionService.check_status(render_result[:render_id])
      rescue RemotionService::NotFoundError
        conversation.mark_error!("Render job not found")
        puts "\n❌  Render job disappeared (Node restarted?)"
        exit 1
      rescue RemotionService::ApiError => e
        puts "\n⚠️   Poll #{i + 1} failed (#{e.message}), retrying…"
        next
      end

      pct = (status[:progress].to_f * 100).to_i

      if pct != last_pct
        bar    = ("█" * (pct / 2)) + ("░" * (50 - pct / 2))
        secs   = (Time.current - poll_start).round(1)
        print "\r  [#{bar}] #{pct}%  (#{secs}s)  "
        $stdout.flush
        last_pct = pct
      end

      case status[:status]
      when "done"
        conversation.mark_done!(status[:video_url])
        secs = (Time.current - poll_start).round(1)
        puts "\n\n#{sep}"
        puts "  ✅  RENDER COMPLETE in #{secs}s"
        puts sep
        puts "  Video URL       : #{remotion_base}#{status[:video_url]}"
        puts "  Conversation ID : #{conversation.id}"
        puts sep + "\n\n"
        break
      when "error"
        conversation.mark_error!(status[:error])
        puts "\n❌  Render failed: #{status[:error]}"
        exit 1
      end
    end
  end
end
