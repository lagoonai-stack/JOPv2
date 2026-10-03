# frozen_string_literal: true

# VideoSpec
#
# The contract between the movie-maker agent (which decides) and the Remotion
# service (which generates code). The agent emits this object in Step 6; this
# class validates it, computes every derived field, and produces the canonical
# form sent to Node.
#
# Two rules govern the design:
#
#   1. Nothing here is inferred by an LLM. Dimensions, durations and start
#      frames are computed from the agreement reached with the user. Before
#      this existed, a missing spec meant the Node service re-guessed the
#      format from the prose and a video agreed as vertical could come out
#      horizontal.
#
#   2. Derivation happens HERE and nowhere else. The Node side validates that
#      the derived fields are present and coherent, but never recomputes them —
#      two implementations of the same formula is how the pipeline drifted in
#      the first place.
#
# Business rules that used to live in the agent's ~45-line pre-delivery
# checklist (which nothing verified) are enforced here, and their messages are
# written to be fed straight back to the agent for a correction pass.
#
# Deliberately free of Rails dependencies so it can be unit-tested standalone.
class VideoSpec
  SPEC_VERSION = "1"

  FORMATS = {
    "vertical" => { width: 1080, height: 1920 },
    "horizontal" => { width: 1920, height: 1080 }
  }.freeze

  MODES = %w[minimalista dinamico].freeze
  PALETTES = %w[dark_premium bold editorial neon custom].freeze
  COMPOSITION_TYPES = %w[A B C].freeze
  VISUAL_CATEGORIES = %w[produto geometrico organico tipografico].freeze
  CONTAINER_TYPES = %w[card_grande card_medio barra pilula circulo fullscreen].freeze
  TEXT_POSITIONS = %w[centro inferior superior].freeze
  TEXT_ALIGNS = %w[center left right].freeze
  TRANSITION_MODES = %w[morph directional].freeze
  DIRECTIONS = %w[left right up down].freeze
  # Motion library vocabulary (template-remotion/src/remotion/design-system).
  # Both fields are optional per moment; the generator receives them as data.
  ACCENT_TYPES = %w[underline strike scribble circle highlight].freeze
  TEXTURES = %w[dots lines grid].freeze

  # Fixed for now, but a field rather than a constant: every duration table in
  # the agent is calibrated for 30fps, and the formula below works in seconds
  # so that enabling 60fps later is a value change, not a recalibration.
  FPS = 30

  MIN_MOMENTS = 3
  MAX_MOMENTS = 12
  MAX_CAPTION_WORDS_MINIMALISTA = 4

  # "Momento estável menor que 1.5s" is a listed prohibition; 4.5s is the top of
  # the agent's own table for a 12-word line.
  MIN_MOMENT_SECONDS = 2.0
  MAX_MOMENT_SECONDS = 4.5

  HEX_COLOR = /\A#[0-9A-Fa-f]{6}\z/

  attr_reader :raw, :errors

  # @param raw [Hash] the spec as the agent emitted it
  # @return [VideoSpec]
  def self.build(raw)
    spec = new(raw)
    spec.validate
    spec
  end

  def initialize(raw)
    @raw = raw.is_a?(Hash) ? raw : {}
    @errors = []
  end

  def valid?
    errors.empty?
  end

  def moments
    @moments ||= raw["moments"].is_a?(Array) ? raw["moments"] : []
  end

  def mode
    raw["mode"]
  end

  def minimalista?
    mode == "minimalista"
  end

  def format
    raw["format"]
  end

  def dimensions
    FORMATS.fetch(format, FORMATS["vertical"])
  end

  def width  = dimensions[:width]
  def height = dimensions[:height]
  def fps    = FPS

  # ---------------------------------------------------------------------------
  # Derived timeline
  # ---------------------------------------------------------------------------

  # Every moment with its computed duration and start frame.
  # @return [Array<Hash>]
  def timeline
    @timeline ||= begin
      cursor = 0

      moments.each_with_index.map do |moment, position|
        overlap = overlap_frames_for(moment)
        # A transition overlaps the outgoing moment, so the incoming one starts
        # earlier than the plain sum of durations would suggest.
        cursor -= overlap if position.positive?

        duration = duration_frames_for(moment)
        start_frame = cursor
        cursor += duration

        {
          "index" => position + 1,
          "start_frame" => start_frame,
          "duration_frames" => duration
        }
      end
    end
  end

  def total_frames
    return 0 if timeline.empty?

    last = timeline.last
    last["start_frame"] + last["duration_frames"]
  end

  # Duration in frames for one moment: an explicit value from the agent wins
  # (a director may hold a final beat longer for impact), otherwise it comes
  # from the word count via the table in the agent's timing block.
  def duration_frames_for(moment)
    override = moment["duration_frames"]
    return override.to_i if override.is_a?(Numeric) && override.to_i.positive?

    (duration_seconds_for(moment) * FPS).round
  end

  def duration_seconds_for(moment)
    words = word_count(moment)

    seconds =
      if minimalista?
        # 2 palavras → 2.0s, 3 → 2.5s, 4 → 3.0s
        1.0 + (words * 0.5)
      else
        case words
        when 0..4 then 2.0 + ([words - 2, 0].max * 0.25)
        when 5..8 then 2.5 + ((words - 5) / 3.0)
        else           3.5 + ([words - 9, 3].min / 3.0)
        end
      end

    seconds.clamp(MIN_MOMENT_SECONDS, MAX_MOMENT_SECONDS)
  end

  def word_count(moment)
    text = [moment["caption"], (moment["caption_secondary"] unless minimalista?)]
           .compact
           .join(" ")

    text.split(/\s+/).reject(&:empty?).size
  end

  def overlap_frames_for(moment)
    transition = moment["transition_from_previous"]
    return 0 unless transition.is_a?(Hash)

    value = transition["overlap_frames"]
    value.is_a?(Numeric) ? value.to_i.clamp(0, 60) : 0
  end

  # ---------------------------------------------------------------------------
  # Canonical form sent to the Remotion service
  # ---------------------------------------------------------------------------

  def to_h
    derived = timeline.each_with_object({}) { |entry, acc| acc[entry["index"]] = entry }

    {
      "spec_version" => SPEC_VERSION,
      "format" => format,
      "mode" => mode,
      "palette" => raw["palette"],
      "palette_overrides" => raw["palette_overrides"],
      "theme" => raw["theme"],
      "width" => width,
      "height" => height,
      "fps" => fps,
      "total_frames" => total_frames,
      "moments" => moments.each_with_index.map do |moment, position|
        entry = derived[position + 1]

        {
          "index" => position + 1,
          "caption" => moment["caption"],
          "caption_secondary" => moment["caption_secondary"],
          "composition_type" => moment["composition_type"],
          "visual_category" => moment["visual_category"],
          "visual_component" => moment["visual_component"],
          "container_type" => moment["container_type"],
          "background_color" => moment["background_color"],
          "text_position" => moment["text_position"],
          "text_align" => moment["text_align"],
          "start_frame" => entry["start_frame"],
          "duration_frames" => entry["duration_frames"],
          "transition_from_previous" => moment["transition_from_previous"],
          "accent" => moment["accent"],
          "texture" => moment["texture"],
          "notes" => moment["notes"]
        }.compact
      end
    }.compact
  end

  # The subset the render pipeline reads, in the shape ClaudeConversation stores.
  def to_video_spec_column
    {
      "width" => width,
      "height" => height,
      "fps" => fps,
      "duration_in_frames" => total_frames
    }
  end

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------

  def validate
    @errors = []
    @caption_too_long = false

    validate_header
    validate_moment_count
    return @errors unless moments.any?

    moments.each_with_index { |moment, position| validate_moment(moment, position) }
    validate_sequence_rules

    @errors
  end

  # Errors phrased as instructions, ready to be handed back to the agent.
  def error_report
    errors.map { |error| "- #{error}" }.join("\n")
  end

  # True when at least one minimalist caption exceeds the word limit — the one
  # error whose fix requires changing text the user already approved.
  def caption_too_long?
    @caption_too_long == true
  end

  private

  def validate_header
    unless raw["spec_version"].to_s == SPEC_VERSION
      @errors << "spec_version deve ser \"#{SPEC_VERSION}\" (recebido: #{raw['spec_version'].inspect})."
    end

    unless FORMATS.key?(format)
      @errors << "format deve ser \"vertical\" ou \"horizontal\" (recebido: #{format.inspect})."
    end

    unless MODES.include?(mode)
      @errors << "mode deve ser \"minimalista\" ou \"dinamico\" (recebido: #{mode.inspect})."
    end

    unless PALETTES.include?(raw["palette"])
      @errors << "palette deve ser um de #{PALETTES.join(', ')} (recebido: #{raw['palette'].inspect})."
    end

    if raw["palette"] == "custom" && !raw["palette_overrides"].is_a?(Hash)
      @errors << "palette_overrides é obrigatório quando palette é \"custom\"."
    end

    if raw["theme"].to_s.strip.empty?
      @errors << "theme é obrigatório: uma frase curta com o tema/nicho do vídeo."
    end

    if raw.key?("fps") && raw["fps"].to_i != FPS
      @errors << "fps deve ser #{FPS}; as tabelas de duração são calibradas para essa taxa."
    end
  end

  def validate_moment_count
    if moments.size < MIN_MOMENTS || moments.size > MAX_MOMENTS
      @errors << "moments deve ter entre #{MIN_MOMENTS} e #{MAX_MOMENTS} itens (recebido: #{moments.size})."
    end
  end

  def validate_moment(moment, position)
    number = position + 1

    unless moment.is_a?(Hash)
      @errors << "Momento #{number} não é um objeto."
      return
    end

    if moment["caption"].to_s.strip.empty?
      @errors << "Momento #{number}: caption é obrigatório."
    elsif minimalista? && word_count(moment) > MAX_CAPTION_WORDS_MINIMALISTA
      @caption_too_long = true
      @errors <<"Momento #{number}: no modo minimalista a legenda tem no máximo " \
                 "#{MAX_CAPTION_WORDS_MINIMALISTA} palavras (recebido: #{word_count(moment)} em " \
                 "\"#{moment['caption']}\")."
    end

    validate_enum(moment["composition_type"], COMPOSITION_TYPES, "composition_type", number)
    validate_enum(moment["visual_category"], VISUAL_CATEGORIES, "visual_category", number)
    validate_enum(moment["text_position"], TEXT_POSITIONS, "text_position", number)
    validate_enum(moment["text_align"], TEXT_ALIGNS, "text_align", number)

    if moment["visual_component"].to_s.strip.empty?
      @errors << "Momento #{number}: visual_component é obrigatório (o componente do repertório visual)."
    end

    unless moment["background_color"].to_s.match?(HEX_COLOR)
      @errors << "Momento #{number}: background_color deve ser hexadecimal #RRGGBB " \
                 "(recebido: #{moment['background_color'].inspect})."
    end

    container = moment["container_type"]
    if moment["composition_type"] == "A"
      unless container.nil?
        @errors << "Momento #{number}: composition_type \"A\" é lettering puro e não tem container; " \
                   "container_type deve ser null."
      end
    elsif !CONTAINER_TYPES.include?(container)
      @errors << "Momento #{number}: container_type deve ser um de #{CONTAINER_TYPES.join(', ')} " \
                 "(recebido: #{container.inspect})."
    end

    if minimalista? && moment["text_position"] != "inferior"
      @errors << "Momento #{number}: no modo minimalista a legenda fica sempre em \"inferior\"; " \
                 "a posição nunca muda entre momentos."
    end

    validate_accent(moment, number)
    validate_enum(moment["texture"], TEXTURES, "texture", number) unless moment["texture"].nil?
    validate_transition(moment, position)
  end

  # The accent marks one word (or short run of words) of the caption, so the
  # word has to actually be in it — otherwise the generator has nothing to wrap.
  def validate_accent(moment, number)
    accent = moment["accent"]
    return if accent.nil?

    unless accent.is_a?(Hash)
      @errors << "Momento #{number}: accent deve ser um objeto {\"type\", \"word\"} ou null."
      return
    end

    validate_enum(accent["type"], ACCENT_TYPES, "accent.type", number)

    word = accent["word"].to_s.strip
    captions = [moment["caption"], moment["caption_secondary"]].compact.join(" ")
    if word.empty?
      @errors << "Momento #{number}: accent.word é obrigatório (a palavra da legenda que recebe o acento)."
    elsif !captions.downcase.include?(word.downcase)
      @errors << "Momento #{number}: accent.word \"#{word}\" não aparece na legenda deste momento."
    end
  end

  def validate_transition(moment, position)
    number = position + 1
    transition = moment["transition_from_previous"]

    if position.zero?
      unless transition.nil?
        @errors << "Momento 1 não tem momento anterior; transition_from_previous deve ser null."
      end
      return
    end

    unless transition.is_a?(Hash)
      @errors << "Momento #{number}: transition_from_previous é obrigatório a partir do momento 2."
      return
    end

    mode_value = transition["mode"]
    unless TRANSITION_MODES.include?(mode_value)
      @errors << "Momento #{number}: transition_from_previous.mode deve ser \"morph\" ou \"directional\" " \
                 "(recebido: #{mode_value.inspect})."
      return
    end

    if mode_value == "directional" && !DIRECTIONS.include?(transition["direction"])
      @errors << "Momento #{number}: uma transição \"directional\" precisa de direction " \
                 "(#{DIRECTIONS.join(', ')})."
    end

    if mode_value == "morph"
      %w[morph_from morph_to].each do |key|
        unless CONTAINER_TYPES.include?(transition[key])
          @errors << "Momento #{number}: uma transição \"morph\" precisa de #{key} " \
                     "com um tipo de container (#{CONTAINER_TYPES.join(', ')})."
        end
      end
    end
  end

  def validate_enum(value, allowed, field, number)
    return if allowed.include?(value)

    @errors << "Momento #{number}: #{field} deve ser um de #{allowed.join(', ')} (recebido: #{value.inspect})."
  end

  # Rules about the sequence as a whole — the anti-repetition guarantees that
  # were previously only checklist items the agent graded itself on.
  def validate_sequence_rules
    each_run(moments.map { |m| m["composition_type"] }) do |value, length, at|
      next if length < 3

      @errors << "Momentos #{at}-#{at + length - 1}: composition_type \"#{value}\" se repete " \
                 "#{length} vezes seguidas; nunca use o mesmo tipo em 3 momentos consecutivos."
    end

    each_run(moments.map { |m| m["visual_category"] }) do |value, length, at|
      next if length < 3

      @errors << "Momentos #{at}-#{at + length - 1}: visual_category \"#{value}\" se repete " \
                 "#{length} vezes seguidas; varie as categorias do repertório visual."
    end

    directions = moments.map do |moment|
      transition = moment["transition_from_previous"]
      transition.is_a?(Hash) ? transition["direction"] : nil
    end

    directions.each_cons(2).with_index(1) do |(previous, current), position|
      next if previous.nil? || current.nil? || previous != current

      @errors << "Momentos #{position + 1} e #{position + 2}: a mesma direção \"#{current}\" " \
                 "em conexões consecutivas; alterne a direção entre transições."
    end
  end

  # Yields (value, run_length, one_based_start) for each run of equal values.
  def each_run(values)
    return if values.empty?

    start = 0
    values.each_with_index do |value, index|
      next if index.zero? || value == values[index - 1]

      yield(values[start], index - start, start + 1)
      start = index
    end

    yield(values[start], values.size - start, start + 1)
  end
end
