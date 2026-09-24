# frozen_string_literal: true

namespace :remotion do
  desc "Preview a TSX component (upload only, no render)"
  task :preview, [:file_path] => :environment do |_t, args|
    if args[:file_path].blank?
      puts "\n❌ Error: File path is required"
      puts "\nUsage:"
      puts "  rails remotion:preview[path/to/component.tsx]"
      puts "\nExample:"
      puts "  rails remotion:preview[./tmp/my_video.tsx]"
      puts ""
      exit 1
    end

    file_path = args[:file_path]

    unless File.exist?(file_path)
      puts "\n❌ Error: File not found: #{file_path}"
      exit 1
    end

    puts "\n" + ("=" * 70)
    puts "TSX Component Preview Upload"
    puts "=" * 70
    puts "File: #{file_path}"
    puts "Size: #{File.size(file_path)} bytes"
    puts ("=" * 70) + "\n"

    # Read component code
    component_code = File.read(file_path)

    # Find or create test conversation
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

    puts "[1/2] Uploading component..."
    begin
      result = RemotionService.upload_component(conversation, component_code)

      conversation.mark_component_uploaded!(result[:component_id])

      puts "✓ Component uploaded successfully\n"
      puts "━" * 70
      puts "Component ID: #{result[:component_id]}"
      puts "File name:    #{result[:file_name]}"
      puts "Message:      #{result[:message]}"
      puts "━" * 70
      puts "\n[2/2] Component preview complete!"
      puts "\nℹ️  Component is stored for 24 hours"
      puts "ℹ️  Use this component_id to render a video:\n\n"
      puts "  Conversation ID: #{conversation.id}"
      puts "  Component ID:    #{result[:component_id]}"
      puts "\n  rails remotion:render_component[#{result[:component_id]},#{conversation.id}]"
      puts ""
    rescue RemotionService::Error => e
      puts "\n❌ Upload failed: #{e.message}\n"
      puts "Details: #{e.class.name}"
      exit 1
    end
  end

  desc "Render a video from an uploaded component"
  task :render_component, %i[component_id conversation_id] => :environment do |_t, args|
    if args[:component_id].blank? || args[:conversation_id].blank?
      puts "\n❌ Error: component_id and conversation_id are required"
      puts "\nUsage:"
      puts "  rails remotion:render_component[COMPONENT_ID,CONVERSATION_ID]"
      puts "\nExample:"
      puts "  rails remotion:render_component[550e8400-e29b-41d4-a716-446655440000,123]"
      puts "\nOr use the shortcut after preview:"
      puts "  rails remotion:preview[./tmp/component.tsx]"
      puts "  # Then copy the render command shown"
      puts ""
      exit 1
    end

    component_id = args[:component_id]
    conversation_id = args[:conversation_id]

    puts "\n" + ("=" * 70)
    puts "TSX Component Render"
    puts "=" * 70
    puts "Component ID:    #{component_id}"
    puts "Conversation ID: #{conversation_id}"
    puts ("=" * 70) + "\n"

    # Load conversation
    conversation = ClaudeConversation.find_by(id: conversation_id)
    unless conversation
      puts "❌ Error: Conversation not found: #{conversation_id}"
      exit 1
    end

    # Optional: Set render parameters via ENV vars
    width = ENV["WIDTH"]&.to_i || 1080
    height = ENV["HEIGHT"]&.to_i || 1920
    fps = ENV["FPS"]&.to_i || 30
    duration = ENV["DURATION"]&.to_i || 300

    # Parse component props from ENV if provided (JSON format)
    component_props = {}
    if ENV["PROPS"].present?
      begin
        component_props = JSON.parse(ENV["PROPS"])
      rescue JSON::ParserError => e
        puts "⚠️  Warning: Invalid PROPS JSON, using empty props: #{e.message}"
      end
    end

    puts "[1/3] Starting render..."
    puts "  Dimensions:  #{width}x#{height}"
    puts "  FPS:         #{fps}"
    puts "  Duration:    #{duration} frames (#{duration / fps}s)"
    puts "  Props:       #{component_props.inspect}\n\n"

    begin
      render_result = RemotionService.start_render_with_component(
        conversation,
        component_id,
        width: width,
        height: height,
        fps: fps,
        duration_in_frames: duration,
        component_props: component_props
      )

      puts "✓ Render started successfully"
      puts "  Render ID: #{render_result[:render_id]}"
      puts "  Status:    #{render_result[:status]}"
      puts "  Mode:      #{render_result[:mode]}\n\n"

      conversation.mark_rendering!(render_result[:render_id])
    rescue RemotionService::Error => e
      puts "\n❌ Render start failed: #{e.message}"
      exit 1
    end

    # Poll status
    puts "[2/3] Polling render status..."
    puts "━" * 70

    max_attempts = 120 # 10 minutes max
    attempt = 0
    last_progress = -1

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
            print "\r  Progress: [#{bar}] #{progress}%  "
            last_progress = progress
          end
          sleep 3
        when "done"
          puts "\n━" * 70
          puts "\n✓ Render completed successfully!\n\n"
          puts "[3/3] Video ready:"
          puts "  Video URL: #{status[:video_url]}"
          puts "  Render ID: #{conversation.render_id}"
          puts "  Duration:  #{(Time.current - conversation.updated_at).round(1)}s\n"
          conversation.mark_done!(status[:video_url])
          puts "\n✓ Test completed successfully! 🎉\n\n"
          break
        when "error"
          puts "\n━" * 70
          puts "\n❌ Render failed with error:"
          puts "  #{status[:error]}\n"
          conversation.mark_error!(status[:error])
          exit 1
        end
      rescue RemotionService::Error => e
        puts "\n\n❌ Status check failed: #{e.message}"
        exit 1
      end
    end

    if attempt > max_attempts
      puts "\n\n❌ Timeout: Render took longer than expected"
      exit 1
    end
  end

  desc "Full workflow: upload component from file and render video"
  task :test_file, [:file_path] => :environment do |_t, args|
    if args[:file_path].blank?
      puts "\n❌ Error: File path is required"
      puts "\nUsage:"
      puts "  rails remotion:test_file[path/to/component.tsx]"
      puts "\nOptional ENV variables:"
      puts "  WIDTH=1080        # Video width (default: 1080)"
      puts "  HEIGHT=1920       # Video height (default: 1920)"
      puts "  FPS=30            # Frames per second (default: 30)"
      puts "  DURATION=300      # Total frames (default: 300)"
      puts "  PROPS='{\"key\":\"value\"}'  # JSON props for component"
      puts "\nExample:"
      puts "  rails remotion:test_file[./tmp/my_video.tsx]"
      puts "  WIDTH=1920 HEIGHT=1080 FPS=60 rails remotion:test_file[./tmp/my_video.tsx]"
      puts ""
      exit 1
    end

    file_path = args[:file_path]

    unless File.exist?(file_path)
      puts "\n❌ Error: File not found: #{file_path}"
      exit 1
    end

    puts "\n" + ("=" * 70)
    puts "TSX Component Full Workflow Test"
    puts "=" * 70
    puts "File:   #{file_path}"
    puts "Size:   #{File.size(file_path)} bytes"
    puts ("=" * 70) + "\n"

    # Read component code
    component_code = File.read(file_path)

    # Show a preview of the code
    lines = component_code.lines
    preview_lines = [lines.first(5), ["...", ""], lines.last(3)].flatten
    puts "Component preview:"
    puts "┌" + ("─" * 68) + "┐"
    preview_lines.each do |line|
      puts "│ #{line.chomp.ljust(66)} │"
    end
    puts "└" + ("─" * 68) + "┘\n\n"

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

    puts "✓ Created test conversation ##{conversation.id}\n\n"

    # Step 1: Upload component
    puts "[1/3] Uploading component..."
    begin
      result = RemotionService.upload_component(conversation, component_code)
      conversation.mark_component_uploaded!(result[:component_id])

      puts "✓ Component uploaded successfully"
      puts "  Component ID: #{result[:component_id]}"
      puts "  File name:    #{result[:file_name]}\n\n"
    rescue RemotionService::Error => e
      puts "\n❌ Upload failed: #{e.message}"
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
    start_time = Time.current

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
            elapsed = (Time.current - start_time).round(1)
            print "\r  [#{bar}] #{progress}% (#{elapsed}s)  "
            last_progress = progress
          end
          sleep 3
        when "done"
          elapsed = (Time.current - start_time).round(1)
          puts "\n━" * 70
          puts "\n✓ Render completed successfully in #{elapsed}s!\n\n"
          puts "Results:"
          puts "  Conversation ID: #{conversation.id}"
          puts "  Component ID:    #{conversation.component_id}"
          puts "  Render ID:       #{conversation.render_id}"
          puts "  Video URL:       #{status[:video_url]}"
          puts "  Video path:      #{conversation.video_file_path}"
          conversation.mark_done!(status[:video_url])
          puts "\n✓ Test completed successfully! 🎉\n\n"
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

  desc "Create a sample TSX component file for testing"
  task :create_sample, [:output_path] => :environment do |_t, args|
    output_path = args[:output_path] || "./tmp/sample_component.tsx"

    sample_code = <<~TYPESCRIPT
      import { useCurrentFrame, useVideoConfig, interpolate, Easing } from "remotion";

      interface SampleVideoProps {
        title?: string;
        subtitle?: string;
        color?: string;
      }

      export default function SampleVideo({
        title = "Sample Video",
        subtitle = "Generated by JOP-Remotion",
        color = "#3B82F6",
      }: SampleVideoProps) {
        const frame = useCurrentFrame();
        const { width, height, fps } = useVideoConfig();

        // Title animation (frames 0-90)
        const titleOpacity = interpolate(
          frame,
          [0, 20, 70, 90],
          [0, 1, 1, 0],
          {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: Easing.inOut(Easing.quad),
          }
        );

        const titleScale = interpolate(
          frame,
          [0, 30],
          [0.8, 1],
          {
            extrapolateRight: "clamp",
            easing: Easing.out(Easing.back(1.3)),
          }
        );

        // Subtitle animation (frames 40-120)
        const subtitleOpacity = interpolate(
          frame,
          [40, 60, 100, 120],
          [0, 1, 1, 0],
          {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }
        );

        // Background animation
        const bgHue = interpolate(frame, [0, 120], [220, 260]);

        return (
          <div
            style={{
              width,
              height,
              background: `linear-gradient(135deg, hsl(${bgHue}, 70%, 15%) 0%, hsl(${bgHue + 30}, 50%, 8%) 100%)`,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              padding: width * 0.1,
            }}
          >
            {/* Title */}
            {titleOpacity > 0 && (
              <div
                style={{
                  opacity: titleOpacity,
                  transform: `scale(${titleScale})`,
                  marginBottom: 40,
                }}
              >
                <h1
                  style={{
                    color,
                    fontSize: width / 15,
                    fontWeight: "900",
                    textAlign: "center",
                    margin: 0,
                    textShadow: "0 4px 24px rgba(0, 0, 0, 0.5)",
                  }}
                >
                  {title}
                </h1>
              </div>
            )}

            {/* Subtitle */}
            {subtitleOpacity > 0 && (
              <div style={{ opacity: subtitleOpacity }}>
                <p
                  style={{
                    color: "#E5E7EB",
                    fontSize: width / 30,
                    fontWeight: "600",
                    textAlign: "center",
                    margin: 0,
                    letterSpacing: "0.05em",
                  }}
                >
                  {subtitle}
                </p>
              </div>
            )}

            {/* Frame counter (for debugging) */}
            <div
              style={{
                position: "absolute",
                bottom: 20,
                right: 20,
                color: "rgba(255, 255, 255, 0.3)",
                fontSize: 12,
                fontFamily: "monospace",
              }}
            >
              Frame: {frame} / {fps}fps
            </div>
          </div>
        );
      }
    TYPESCRIPT

    # Ensure directory exists
    FileUtils.mkdir_p(File.dirname(output_path))

    File.write(output_path, sample_code)

    puts "\n✓ Sample component created: #{output_path}\n"
    puts "File size: #{File.size(output_path)} bytes\n\n"
    puts "Test it with:"
    puts "  rails remotion:test_file[#{output_path}]\n\n"
    puts "Or customize the render:"
    puts "  WIDTH=1920 HEIGHT=1080 DURATION=120 rails remotion:test_file[#{output_path}]\n\n"
    puts "With custom props:"
    puts "  PROPS='{\"title\":\"My Video\",\"color\":\"#10B981\"}' rails remotion:test_file[#{output_path}]\n\n"
  end
end
