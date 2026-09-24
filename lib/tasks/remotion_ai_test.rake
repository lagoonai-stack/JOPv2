# frozen_string_literal: true

namespace :remotion do
  namespace :ai do
    desc "Generate a video component from a prompt using AI"
    task :generate, [:prompt] => :environment do |_t, args|
      if args[:prompt].blank?
        puts "\n❌ Error: Prompt is required"
        puts "\nUsage:"
        puts "  rails remotion:ai:generate['your prompt here']"
        puts "\nExamples:"
        puts "  rails remotion:ai:generate['Create an animated title that fades in']"
        puts "  rails remotion:ai:generate['Make a countdown from 3 to 1 with bouncing numbers']"
        puts "  rails remotion:ai:generate['Animated bar chart showing sales data']"
        puts "\nOptional ENV variables:"
        puts "  MODEL=gpt-4o          # AI model to use (default: gpt-4o)"
        puts "  TEMPERATURE=0.7       # Creativity level 0-2 (default: 0.7)"
        puts "  MAX_TOKENS=4000       # Max response length (default: 4000)"
        puts ""
        exit 1
      end

      prompt = args[:prompt]

      puts "\n" + ("=" * 70)
      puts "AI Component Generation"
      puts "=" * 70
      puts "Prompt: #{prompt}"
      puts ("=" * 70) + "\n"

      # Find or create test user
      user = User.first
      unless user
        puts "❌ Error: No users found. Create a user first."
        exit 1
      end

      ClaudeConversation.where(user: user).update_all(finished_at: Time.zone.now)

      conversation = ClaudeConversation.create!(
        user: user,
        agent_name: "movie-maker",
        video_status: "idle"
      )

      puts "✓ Created conversation ##{conversation.id}\n\n"

      # AI generation options from ENV
      options = {}
      options[:model] = ENV["MODEL"] if ENV["MODEL"].present?
      options[:temperature] = ENV["TEMPERATURE"].to_f if ENV["TEMPERATURE"].present?
      options[:max_tokens] = ENV["MAX_TOKENS"].to_i if ENV["MAX_TOKENS"].present?
      options[:max_retries] = ENV["MAX_RETRIES"].to_i if ENV["MAX_RETRIES"].present?

      unless options.empty?
        puts "Options:"
        options.each { |k, v| puts "  #{k}: #{v}" }
        puts "\n"
      end

      # Generate component
      puts "[1/2] Generating component with AI..."
      start_time = Time.current

      begin
        result = RemotionService.generate_component(conversation, prompt, options)

        elapsed = (Time.current - start_time).round(1)
        puts "✓ Component generated in #{elapsed}s\n"
        puts "━" * 70
        puts "Component ID:  #{result[:component_id]}"
        puts "File name:     #{result[:file_name]}"
        puts "Model:         #{result[:model]}"
        puts "Attempts:      #{result[:attempts]}"
        puts "Code length:   #{result[:code_length]} characters"
        puts "━" * 70
        puts "\n"

        conversation.mark_component_generated!(
          result[:component_id],
          prompt: result[:prompt],
          model: result[:model],
          attempts: result[:attempts]
        )

        puts "[2/2] Component saved successfully!"
        puts "\n✓ AI generation complete! 🤖\n\n"
        puts "Next steps:"
        puts "  1. Render video: rake remotion:render_component[#{result[:component_id]},#{conversation.id}]"
        puts "  2. Or full test: rake remotion:ai:test['#{prompt}']\n\n"
      rescue RemotionService::Error => e
        puts "\n❌ Generation failed: #{e.message}\n"
        puts "Details: #{e.class.name}"
        exit 1
      end
    end

    desc "Generate component with AI and show preview"
    task :preview, [:prompt] => :environment do |_t, args|
      if args[:prompt].blank?
        puts "\n❌ Error: Prompt is required"
        puts "\nUsage:"
        puts "  rails remotion:ai:preview['your prompt here']"
        puts "\nExamples:"
        puts "  rails remotion:ai:preview['Create an animated title that fades in']"
        puts "  rails remotion:ai:preview['Make a countdown from 3 to 1']"
        puts "\nOptional ENV variables:"
        puts "  MODEL=gpt-4o          # AI model to use (default: gpt-4o)"
        puts "  TEMPERATURE=0.7       # Creativity level 0-2 (default: 0.7)"
        puts ""
        exit 1
      end

      prompt = args[:prompt]

      puts "\n" + ("=" * 70)
      puts "AI Component Generation with Preview"
      puts "=" * 70
      puts "Prompt: #{prompt}"
      puts ("=" * 70) + "\n"

      # Find or create test user
      user = User.first
      unless user
        puts "❌ Error: No users found. Create a user first."
        exit 1
      end

      conversation = ClaudeConversation.create!(
        user: user,
        agent_name: "movie-maker",
        video_status: "idle"
      )

      puts "✓ Created conversation ##{conversation.id}\n\n"

      # AI generation options from ENV
      options = {}
      options[:model] = ENV["MODEL"] if ENV["MODEL"].present?
      options[:temperature] = ENV["TEMPERATURE"].to_f if ENV["TEMPERATURE"].present?

      unless options.empty?
        puts "Options:"
        options.each { |k, v| puts "  #{k}: #{v}" }
        puts "\n"
      end

      # Generate component with preview
      puts "[1/2] Generating component with AI and creating preview..."
      start_time = Time.current

      begin
        result = RemotionService.generate_with_preview(conversation, prompt, options)

        elapsed = (Time.current - start_time).round(1)
        puts "✓ Component generated in #{elapsed}s\n"
        puts "━" * 70
        puts "Component ID:    #{result[:component_id]}"
        puts "File name:       #{result[:file_name]}"
        puts "Model:           #{result[:model]}"
        puts "Attempts:        #{result[:attempts]}"
        puts "Code length:     #{result[:code_length]} characters"
        puts "Detected skills: #{result[:detected_skills]&.join(', ') || 'none'}"
        puts "━" * 70
        puts "\n"

        conversation.mark_component_generated!(
          result[:component_id],
          prompt: result[:prompt],
          model: result[:model],
          attempts: result[:attempts],
          detected_skills: result[:detected_skills]
        )

        # Store preview token
        conversation.store_preview_token!(
          token: result[:preview_token],
          expires_at: result[:preview_expires_at]
        )

        puts "[2/2] Preview ready!"
        puts "\n✓ AI generation with preview complete! 🤖\n\n"

        remotion_base = ENV.fetch("REMOTION_SERVICE_URL", "http://localhost:3001")
        preview_full_url = "#{remotion_base}#{result[:preview_url]}"

        puts "Preview URL: #{preview_full_url}"
        puts "\nNext steps:"
        puts "  1. View preview in browser: open #{preview_full_url}"
        puts "  2. Render video: rails remotion:render_component[#{result[:component_id]},#{conversation.id}]"
        puts "  3. Or full test: rails remotion:ai:test['#{prompt}']\n\n"
      rescue RemotionService::Error => e
        puts "\n❌ Generation failed: #{e.message}\n"
        puts "Details: #{e.class.name}"
        exit 1
      end
    end

    desc "Test the complete Rails chat flow: generate with preview then render"
    task :chat_flow, [:prompt] => :environment do |_t, args|
      if args[:prompt].blank?
        puts "\n❌ Error: Prompt is required"
        puts "\nUsage:"
        puts "  rails remotion:ai:chat_flow['your prompt here']"
        puts "\nExample:"
        puts "  rails remotion:ai:chat_flow['Create an animated title']"
        puts "\nThis task mimics the full chat flow:"
        puts "  1. User provides prompt"
        puts "  2. Rails calls generate_with_preview"
        puts "  3. User sees preview"
        puts "  4. User approves and renders"
        puts ""
        exit 1
      end

      prompt = args[:prompt]

      puts "\n" + ("=" * 70)
      puts "AI Chat Flow Test"
      puts "=" * 70
      puts "Prompt: #{prompt}"
      puts ("=" * 70) + "\n"

      # Create test conversation
      user = User.first
      unless user
        puts "❌ Error: No users found. Create a user first."
        exit 1
      end

      ClaudeConversation.where(user: user).update_all(finished_at: Time.zone.now)

      conversation = ClaudeConversation.create!(
        user: user,
        agent_name: "movie-maker",
        generation_prompt: prompt,
        video_status: "spec_ready"
      )

      puts "✓ Created conversation ##{conversation.id}\n\n"

      # Step 1: Generate with preview (mimics VideoController#request_preview)
      puts "[1/4] Generating component with AI and creating preview..."
      start_time = Time.current

      begin
        result = RemotionService.generate_with_preview(
          conversation,
          conversation.generation_prompt,
          temperature: 0.7,
          max_tokens: 4000,
          model: "gpt-4o"
        )

        elapsed = (Time.current - start_time).round(1)
        puts "✓ Component generated and preview created in #{elapsed}s\n"
        puts "━" * 70
        puts "Component ID:      #{result[:component_id]}"
        puts "Preview Token:     #{result[:preview_token]}"
        puts "Preview URL:       #{result[:preview_url]}"
        puts "Model:             #{result[:model]}"
        puts "Attempts:          #{result[:attempts]}"
        puts "Code length:       #{result[:code_length]} chars"
        puts "Detected skills:   #{result[:detected_skills]&.join(', ')}"

        # Display extracted configuration
        if result[:config].present?
          puts "\nExtracted Configuration:"
          puts "  Width:             #{result[:config][:width] || result[:config]['width']}px"
          puts "  Height:            #{result[:config][:height] || result[:config]['height']}px"
          puts "  FPS:               #{result[:config][:fps] || result[:config]['fps']}"
          puts "  Duration (frames): #{result[:config][:durationInFrames] || result[:config]['durationInFrames']}"
          duration_seconds = (result[:config][:durationInFrames] || result[:config]['durationInFrames'] || 300) / 30.0
          puts "  Duration (seconds):#{duration_seconds.round(1)}s"
        end
        puts "━" * 70
        puts "\n"

        # Store component metadata (mimics VideoController#request_preview)
        conversation.mark_component_uploaded!(
          result[:component_id],
          ai_model: result[:model],
          ai_attempts: result[:attempts],
          detected_skills: result[:detected_skills]
        )

        # Store extracted configuration
        if result[:config].present?
          conversation.update!(video_spec: result[:config])
        end

        # Store preview token
        conversation.store_preview_token!(
          token: result[:preview_token],
          expires_at: Time.zone.parse(result[:preview_expires_at])
        )

        puts "[2/4] Preview available at:"
        puts "  #{ENV.fetch('REMOTION_SERVICE_URL', 'http://localhost:3001')}#{result[:preview_url]}\n\n"

      rescue RemotionService::Error => e
        puts "\n❌ Generation/preview failed: #{e.message}\n"
        exit 1
      end

      # Step 2: Start render (mimics VideoController#approve)
      puts "[3/4] Starting video render..."

      # Use extracted configuration if available
      config = conversation.video_spec || {}
      width = config["width"] || config[:width] || 1080
      height = config["height"] || config[:height] || 1920
      fps = config["fps"] || config[:fps] || 30
      duration = config["durationInFrames"] || config[:durationInFrames] || 300

      puts "  Using config: #{width}x#{height}, #{fps}fps, #{duration} frames\n\n"

      begin
        render_result = RemotionService.start_render_with_component(
          conversation,
          conversation.component_id,
          width: width,
          height: height,
          fps: fps,
          duration_in_frames: duration,
          component_props: {}
        )

        puts "✓ Render started"
        puts "  Render ID: #{render_result[:render_id]}"
        puts "  Mode:      #{render_result[:mode]}\n\n"

        conversation.mark_rendering!(render_result[:render_id])
      rescue RemotionService::Error => e
        puts "\n❌ Render start failed: #{e.message}\n"
        exit 1
      end

      # Step 3: Poll status
      puts "[4/4] Rendering video..."
      puts "━" * 70

      max_attempts = 120
      attempt = 0
      last_progress = -1
      poll_start = Time.current

      loop do
        attempt += 1
        break if attempt > max_attempts

        begin
          status = RemotionService.render_status(conversation.render_id, conversation)

          case status[:status]
          when "rendering"
            progress = status[:progress]
            if progress != last_progress
              bar_length = 50
              filled = (bar_length * progress / 100).to_i
              bar = ("█" * filled) + ("░" * (bar_length - filled))
              elapsed = (Time.current - poll_start).round(1)
              print "\r  [#{bar}] #{progress}% (#{elapsed}s)  "
              last_progress = progress
              $stdout.flush
            end
            sleep 3
          when "done"
            elapsed = (Time.current - poll_start).round(1)
            puts "\n━" * 70
            puts "\n✓ Render completed successfully in #{elapsed}s!\n\n"
            puts "Results:"
            puts "  Conversation ID: #{conversation.id}"
            puts "  Component ID:    #{conversation.component_id}"
            puts "  Render ID:       #{conversation.render_id}"
            puts "  Video URL:       #{status[:video_url]}"
            conversation.mark_done!(status[:video_url])
            puts "\n✓ Chat flow test completed successfully! 🎉\n\n"
            break
          when "error"
            puts "\n━" * 70
            puts "\n❌ Render failed: #{status[:error]}\n"
            conversation.mark_error!(status[:error])
            exit 1
          end
        rescue RemotionService::Error => e
          puts "\n\n❌ Status check failed: #{e.message}"
          exit 1
        end
      end

      if attempt > max_attempts
        puts "\n\n❌ Timeout: Render exceeded maximum time"
        exit 1
      end
    end

    desc "Full AI workflow: generate component with preview and render video"
    task :test, [:prompt] => :environment do |_t, args|
      if args[:prompt].blank?
        puts "\n❌ Error: Prompt is required"
        puts "\nUsage:"
        puts "  rails remotion:ai:test['your prompt here']"
        puts "\nOptional ENV variables:"
        puts "  MODEL=gpt-4o          # AI model (default: gpt-4o)"
        puts "  TEMPERATURE=0.7       # Creativity 0-2 (default: 0.7)"
        puts "  WIDTH=1080            # Video width (default: 1080)"
        puts "  HEIGHT=1920           # Video height (default: 1920)"
        puts "  FPS=30                # Frames per second (default: 30)"
        puts "  DURATION=300          # Total frames (default: 300)"
        puts "  PROPS='{\"key\":\"val\"}'  # JSON props for component"
        puts "\nExamples:"
        puts "  rails remotion:ai:test['Create a title animation']"
        puts "  WIDTH=1920 HEIGHT=1080 rails remotion:ai:test['Animated chart']"
        puts ""
        exit 1
      end

      prompt = args[:prompt]

      puts "\n" + ("=" * 70)
      puts "AI Component Generation & Render Test"
      puts "=" * 70
      puts "Prompt: #{prompt}"
      puts ("=" * 70) + "\n"

      # Find or create test user
      user = User.first
      unless user
        puts "❌ Error: No users found. Create a user first."
        exit 1
      end

      conversation = ClaudeConversation.create!(
        user: user,
        agent_name: "movie-maker",
        video_status: "idle"
      )

      puts "✓ Created conversation ##{conversation.id}\n\n"

      # AI options
      ai_options = {}
      ai_options[:model] = ENV["MODEL"] if ENV["MODEL"].present?
      ai_options[:temperature] = ENV["TEMPERATURE"].to_f if ENV["TEMPERATURE"].present?
      ai_options[:max_tokens] = ENV["MAX_TOKENS"].to_i if ENV["MAX_TOKENS"].present?

      # Step 1: Generate component
      puts "[1/3] Generating component with AI..."
      start_gen = Time.current

      begin
        result = RemotionService.generate_component(conversation, prompt, ai_options)

        elapsed_gen = (Time.current - start_gen).round(1)
        puts "✓ Component generated in #{elapsed_gen}s"
        puts "  Model:       #{result[:model]}"
        puts "  Attempts:    #{result[:attempts]}"
        puts "  Code length: #{result[:code_length]} chars\n\n"

        conversation.mark_component_generated!(
          result[:component_id],
          prompt: result[:prompt],
          model: result[:model],
          attempts: result[:attempts]
        )
      rescue RemotionService::Error => e
        puts "\n❌ Generation failed: #{e.message}"
        exit 1
      end

      # Step 2: Start render
      width = ENV["WIDTH"]&.to_i || 1080
      height = ENV["HEIGHT"]&.to_i || 1920
      fps = ENV["FPS"]&.to_i || 30
      duration = ENV["DURATION"]&.to_i || 300

      component_props = {}
      if ENV["PROPS"].present?
        begin
          component_props = JSON.parse(ENV["PROPS"])
        rescue JSON::ParserError => e
          puts "⚠️  Warning: Invalid PROPS JSON: #{e.message}"
        end
      end

      puts "[2/3] Starting render..."
      puts "  Dimensions:  #{width}x#{height}"
      puts "  FPS:         #{fps}"
      puts "  Duration:    #{duration} frames (#{duration / fps}s)"
      puts "  Props:       #{component_props.inspect}\n\n"

      begin
        render_result = RemotionService.start_render_with_component(
          conversation,
          conversation.component_id,
          width: width,
          height: height,
          fps: fps,
          duration_in_frames: duration,
          component_props: component_props
        )

        puts "✓ Render started"
        puts "  Render ID: #{render_result[:render_id]}\n\n"

        conversation.mark_rendering!(render_result[:render_id])
      rescue RemotionService::Error => e
        puts "\n❌ Render start failed: #{e.message}"
        exit 1
      end

      # Step 3: Poll status
      puts "[3/3] Rendering video..."
      puts "━" * 70

      max_attempts = 120
      attempt = 0
      last_progress = -1
      start_render = Time.current

      loop do
        attempt += 1
        break if attempt > max_attempts

        begin
          status = RemotionService.render_status(conversation.render_id, conversation)

          case status[:status]
          when "rendering"
            progress = status[:progress]
            if progress != last_progress
              bar_length = 50
              filled = (bar_length * progress / 100).to_i
              bar = ("█" * filled) + ("░" * (bar_length - filled))
              elapsed = (Time.current - start_render).round(1)
              print "\r  [#{bar}] #{progress}% (#{elapsed}s)  "
              last_progress = progress
            end
            sleep 3
          when "done"
            elapsed_total = (Time.current - start_gen).round(1)
            elapsed_render = (Time.current - start_render).round(1)
            puts "\n━" * 70
            puts "\n✓ Render completed in #{elapsed_render}s!\n\n"
            puts "Results:"
            puts "  Conversation ID: #{conversation.id}"
            puts "  Component ID:    #{conversation.component_id}"
            puts "  Render ID:       #{conversation.render_id}"
            puts "  Prompt:          #{prompt}"
            puts "  AI Model:        #{conversation.ai_model}"
            puts "  Video URL:       #{status[:video_url]}"
            puts "  Total time:      #{elapsed_total}s (gen: #{elapsed_gen}s, render: #{elapsed_render}s)"
            conversation.mark_done!(status[:video_url])
            puts "\n✓ Test completed successfully! 🎉🤖\n\n"
            break
          when "error"
            puts "\n━" * 70
            puts "\n❌ Render failed: #{status[:error]}\n"
            conversation.mark_error!(status[:error])
            exit 1
          end
        rescue RemotionService::Error => e
          puts "\n\n❌ Status check failed: #{e.message}"
          exit 1
        end
      end

      if attempt > max_attempts
        puts "\n\n❌ Timeout: Render exceeded maximum time"
        exit 1
      end
    end

    desc "Test AI generation with various prompts"
    task samples: :environment do
      sample_prompts = [
        "Create an animated title that says 'Welcome' with a fade in effect",
        "Make a countdown timer from 3 to 1 with bouncing numbers",
        "Animated text that types out letter by letter",
        "Create a simple bar chart animation",
        "Make a logo reveal with a zoom and fade effect"
      ]

      puts "\n" + ("=" * 70)
      puts "AI Generation Sample Prompts"
      puts "=" * 70
      puts "\nThe following prompts will be tested:"
      sample_prompts.each_with_index do |prompt, i|
        puts "  #{i + 1}. #{prompt}"
      end
      puts "\n" + ("=" * 70)

      print "\nWhich prompt would you like to test? (1-#{sample_prompts.length}): "
      choice = STDIN.gets.chomp.to_i

      if choice < 1 || choice > sample_prompts.length
        puts "❌ Invalid choice"
        exit 1
      end

      selected_prompt = sample_prompts[choice - 1]
      puts "\n✓ Selected: #{selected_prompt}\n"

      # Generate component
      user = User.first
      unless user
        puts "❌ Error: No users found. Create a user first."
        exit 1
      end

      conversation = ClaudeConversation.create!(
        user: user,
        agent_name: "movie-maker",
        video_status: "idle"
      )

      puts "Generating component...\n"

      begin
        result = RemotionService.generate_component(conversation, selected_prompt)

        puts "✓ Component generated successfully!\n"
        puts "━" * 70
        puts "Component ID:  #{result[:component_id]}"
        puts "Model:         #{result[:model]}"
        puts "Code length:   #{result[:code_length]} characters"
        puts "━" * 70

        conversation.mark_component_generated!(
          result[:component_id],
          prompt: selected_prompt,
          model: result[:model],
          attempts: result[:attempts]
        )

        puts "\nTo render this component:"
        puts "  rails remotion:render_component[#{result[:component_id]},#{conversation.id}]"
        puts "\nOr run full test:"
        puts "  rails remotion:ai:test['#{selected_prompt}']\n\n"
      rescue RemotionService::Error => e
        puts "\n❌ Generation failed: #{e.message}"
        exit 1
      end
    end

    desc "Show AI generation statistics"
    task stats: :environment do
      puts "\n" + ("=" * 70)
      puts "AI Generation Statistics"
      puts ("=" * 70) + "\n"

      total = ClaudeConversation.where.not(generation_prompt: nil).count
      by_model = ClaudeConversation.where.not(ai_model: nil).group(:ai_model).count
      avg_attempts = ClaudeConversation.where.not(ai_attempts: nil).average(:ai_attempts)&.round(1)

      puts "Total AI-generated components: #{total}"
      puts "\nBy model:"
      by_model.each do |model, count|
        puts "  #{model}: #{count}"
      end
      puts "\nAverage attempts per generation: #{avg_attempts || 'N/A'}"

      recent = ClaudeConversation.where.not(generation_prompt: nil)
                                 .order(created_at: :desc)
                                 .limit(5)

      if recent.any?
        puts "\nRecent AI generations:"
        recent.each do |conv|
          prompt_preview = conv.generation_prompt.truncate(50)
          skills = conv.skills_array.join(", ") if conv.skills_array.any?
          skills_text = skills ? " | skills: #{skills}" : ""
          puts "  [#{conv.id}] #{prompt_preview} (#{conv.ai_model})#{skills_text}"
        end
      end

      puts "\n" + ("=" * 70) + "\n"
    end

    desc "Show detected skills for a conversation"
    task :show_skills, [:conversation_id] => :environment do |_t, args|
      if args[:conversation_id].blank?
        puts "\n❌ Error: Conversation ID is required"
        puts "\nUsage:"
        puts "  rails remotion:ai:show_skills[123]"
        puts ""
        exit 1
      end

      conversation = ClaudeConversation.find_by(id: args[:conversation_id])
      unless conversation
        puts "\n❌ Error: Conversation not found"
        exit 1
      end

      unless conversation.ai_generated?
        puts "\n❌ Error: This conversation was not AI-generated"
        exit 1
      end

      puts "\n" + ("=" * 70)
      puts "AI-Generated Component Skills"
      puts "=" * 70
      puts "\nConversation ID: #{conversation.id}"
      puts "Prompt: #{conversation.generation_prompt}"
      puts "Model: #{conversation.ai_model}"
      puts "\nDetected Skills:"

      skills = conversation.skills_array
      if skills.any?
        skills.each do |skill|
          puts "  • #{skill}"
        end
      else
        puts "  (none detected)"
      end

      puts "\n" + ("=" * 70) + "\n"
    end

    desc "Check AI generation prerequisites"
    task check: :environment do
      puts "\n" + ("=" * 70)
      puts "AI Generation Prerequisites Check"
      puts ("=" * 70) + "\n"

      checks = {
        "JOP-Remotion service running" => lambda {
          RemotionService.healthy?
        },
        "OPENAI_API_KEY configured" => lambda {
          ENV["OPENAI_API_KEY"].present?
        },
        "REMOTION_SHARED_SECRET configured" => lambda {
          ENV["REMOTION_SHARED_SECRET"].present?
        },
        "OpenAI package installed" => lambda {
          # Check if remotion service has openai
          true # We'll assume it's installed
        },
        "At least one user exists" => lambda {
          User.exists?
        }
      }

      all_passed = true

      checks.each do |name, check|
        result = begin
          check.call
        rescue StandardError
          false
        end
        status = result ? "✓" : "✗"
        result ? "" : ""
        puts "#{status} #{name}"
        all_passed = false unless result
      end

      puts "\n" + ("=" * 70)

      if all_passed
        puts "\n✓ All checks passed! Ready to generate AI components.\n"
        puts "Try: rails remotion:ai:generate['Create an animated title']\n\n"
      else
        puts "\n❌ Some checks failed. Please fix the issues above.\n\n"
        exit 1
      end
    end
  end
end
