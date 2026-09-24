import { examples } from "@/examples/code";

// Import markdown files at build time
import threeDSkill from "./3d.md";
import audioSkill from "./audio.md";
import audioVisualizationSkill from "./audio-visualization.md";
import chartsSkill from "./charts.md";
import continuousMotionSkill from "./continuous-motion.md";
import depthStackSkill from "./depth-stack.md";
import gifsSkill from "./gifs.md";
import lightLeaksSkill from "./light-leaks.md";
import lottieSkill from "./lottie.md";
import mapsSkill from "./maps.md";
import messagingSkill from "./messaging.md";
import sequencingSkill from "./sequencing.md";
import sfxSkill from "./sfx.md";
import socialMediaSkill from "./social-media.md";
import timingSkill from "./timing.md";
import subtitlesSkill from "./subtitles.md";
import textAnimationsSkill from "./text-animations.md";
import transitionsSkill from "./transitions.md";
import typographySkill from "./typography.md";
import videosSkill from "./videos.md";
import voiceoverSkill from "./voiceover.md";

// Guidance skills (markdown files with patterns/rules)
// Alphabetically sorted. Every entry is a creative user intent — not a
// runtime/backend API, not an implementation detail, not the whole product
// domain.
const GUIDANCE_SKILLS = [
  "3d",
  "audio",
  "audio-visualization",
  "charts",
  "continuous-motion",
  "depth-stack",
  "gifs",
  "light-leaks",
  "lottie",
  "maps",
  "messaging",
  "sequencing",
  "sfx",
  "social-media",
  "timing",
  "subtitles",
  "text-animations",
  "transitions",
  "typography",
  "videos",
  "voiceover",
] as const;

// Example skills (complete working code references)
const EXAMPLE_SKILLS = [
  "example-histogram",
  "example-progress-bar",
  "example-text-rotation",
  "example-falling-spheres",
  "example-animated-shapes",
  "example-lottie",
  "example-gold-price-chart",
  "example-typewriter-highlight",
  "example-word-carousel",
] as const;

export const SKILL_NAMES = [...GUIDANCE_SKILLS, ...EXAMPLE_SKILLS] as const;

export type SkillName = (typeof SKILL_NAMES)[number];

// Map guidance skill names to imported content (same order as GUIDANCE_SKILLS)
const guidanceSkillContent: Record<(typeof GUIDANCE_SKILLS)[number], string> = {
  "3d": threeDSkill,
  "audio": audioSkill,
  "audio-visualization": audioVisualizationSkill,
  "charts": chartsSkill,
  "continuous-motion": continuousMotionSkill,
  "depth-stack": depthStackSkill,
  "gifs": gifsSkill,
  "light-leaks": lightLeaksSkill,
  "lottie": lottieSkill,
  "maps": mapsSkill,
  "messaging": messagingSkill,
  "sequencing": sequencingSkill,
  "sfx": sfxSkill,
  "social-media": socialMediaSkill,
  "timing": timingSkill,
  "subtitles": subtitlesSkill,
  "text-animations": textAnimationsSkill,
  "transitions": transitionsSkill,
  "typography": typographySkill,
  "videos": videosSkill,
  "voiceover": voiceoverSkill,
};

// Map example skill names to example IDs
const exampleIdMap: Record<(typeof EXAMPLE_SKILLS)[number], string> = {
  "example-histogram": "histogram",
  "example-progress-bar": "progress-bar",
  "example-text-rotation": "text-rotation",
  "example-falling-spheres": "falling-spheres",
  "example-animated-shapes": "animated-shapes",
  "example-lottie": "lottie-animation",
  "example-gold-price-chart": "gold-price-chart",
  "example-typewriter-highlight": "typewriter-highlight",
  "example-word-carousel": "word-carousel",
};

export function getSkillContent(skillName: SkillName): string {
  // Handle example skills - return the code directly
  if (skillName.startsWith("example-")) {
    const exampleId =
      exampleIdMap[skillName as (typeof EXAMPLE_SKILLS)[number]];
    const example = examples.find((e) => e.id === exampleId);
    if (example) {
      return `## Example: ${example.name}\n${example.description}\n\n\`\`\`tsx\n${example.code}\n\`\`\``;
    }
    return "";
  }

  // Handle guidance skills - return imported markdown content
  return (
    guidanceSkillContent[skillName as (typeof GUIDANCE_SKILLS)[number]] || ""
  );
}

export function getCombinedSkillContent(skills: SkillName[]): string {
  if (skills.length === 0) {
    return "";
  }

  const contents = skills
    .map((skill) => ({ skill, content: getSkillContent(skill) }))
    .filter(({ content }) => content.length > 0);

  return contents
    .map(({ skill, content }) => `### SKILL: ${skill.toUpperCase()}\n${content}`)
    .join("\n\n");
}

export const SKILL_DETECTION_PROMPT = `You are a multi-label classifier for a motion graphics generation prompt. Your job is to select every skill category that the user's prompt clearly invokes, as well as extract any explicit requests for dimensions or duration.

## Input language
The user prompt may be in English or Brazilian Portuguese. Classify based on meaning, not surface tokens. Map PT-BR phrasing ("gráfico", "legendas", "vertical", "quicar", "abertura cinematográfica", "um a um") to the equivalent category intent.

## Core selection rule (anchor to phrase)
For each skill you select, you MUST be able to point to a specific phrase, word, or clear implication in the user's prompt that triggered it. If you cannot name that anchor, do not select the skill. "Vibes" or "it might help" are not anchors.

## Discipline rule
Prefer fewer skills. Most prompts match 1–3 skills. Selecting 5+ is a strong signal you are over-selecting — reconsider before finalising. Every selected skill injects a full document into the next model's context, so each extra pick dilutes focus and inflates cost.

## Guidance vs example combination rule
Only include an example-* skill when the user's prompt describes something structurally equivalent to that example (same visual archetype, not merely the same domain). If the match is only thematic, prefer the guidance skill alone. Example skills inject full working code and are expensive; when in doubt, skip.

## Guidance categories (patterns and rules)
- 3d: three-dimensional scenes using ThreeJS — rotating solids, spatial scenes, physics-driven 3D objects. USE WHEN: the prompt explicitly asks for "3D", "ThreeJS", "rotating cube", "sphere with depth", "cena 3D", "cubo girando". DO NOT USE WHEN: the prompt only asks for 2D shapes with drop shadows, parallax on flat layers, or isometric SVG illustrations — those are not real 3D. PAIRS WITH: timing.
- audio: playing a pre-recorded audio track inside the composition — background music, narration files, ambient beds — via \`<Audio>\` from \`@remotion/media\`, with trim, volume curves, speed, loop, and pitch. USE WHEN: the prompt references "background music", "soundtrack", "audio file", an MP3/WAV URL or path, "trilha", "trilha de fundo", "música de fundo", "áudio anexado", "narração pronta". DO NOT USE WHEN: the user wants visuals that react to sound (use audio-visualization), AI-generated narration (use voiceover), or short stingers like whooshes, dings, or page-turns (use sfx). PAIRS WITH: voiceover, sfx, subtitles.
- audio-visualization: visual elements that react to or represent sound — bars, waveforms, beat-driven pulses, equalizer-style reveals. USE WHEN: the prompt mentions "audio reactive", "beat-driven", "waveform", "equalizer", "visualização de áudio", "pulsando no ritmo da música". DO NOT USE WHEN: the user only adds a soundtrack or voiceover with no visual reaction tied to it. PAIRS WITH: sequencing, typography.
- charts: data visualizations where real numbers drive the geometry — bars, lines, pies, progress bars, histograms, KPI counters. USE WHEN: the prompt references specific data, percentages, comparisons, "bar chart", "line graph", "progress from 0 to 100", "gráfico de barras", "histograma", "evolução mensal". DO NOT USE WHEN: the prompt asks for abstract shapes that merely resemble bars, or decorative dashboards without real data. PAIRS WITH: sequencing, typography.
- continuous-motion: deterministic, seamless infinite loops in Remotion using math instead of CSS keyframes. USE WHEN: the prompt asks for an "infinite slider", "seamless loop", "carrossel contínuo", "slider infinito", "continuous scrolling", or a scrolling row of logos/testimonials. DO NOT USE WHEN: the prompt asks for standard scene transitions or one-off entering animations. PAIRS WITH: sequencing.
- depth-stack: 3D-like stacking effects and physical scale layering (cards overlay) using math rather than external libraries. USE WHEN: the prompt asks for "stack layout", "cards overlay", "depth", "layered cards", "pilha de cards", "cartões em perspectiva", "stack". DO NOT USE WHEN: the prompt asks for a flat grid or simple sequencing without physical depth and scale. PAIRS WITH: sequencing.
- gifs: displaying an existing animated-image asset (GIF / APNG / AVIF / WebP) inside the composition via \`<AnimatedImage>\` from \`remotion\` or \`<Gif>\` from \`@remotion/gif\`, with \`playbackRate\`, \`loopBehavior\`, and \`getGifDurationInSeconds\` for duration sync. USE WHEN: the prompt supplies a GIF/APNG/AVIF/WebP file or URL, asks to "display a GIF", "show this animated image", "embed this .gif", "use AnimatedImage", "exibir um GIF", "mostrar esse gif", or wants composition duration synced to a GIF's length. DO NOT USE WHEN: the user wants to build a looping animation from scratch using typography, shapes, or video — this skill is only for playing an existing animated-image asset. PAIRS WITH: (none).
- light-leaks: the \`<LightLeak>\` WebGL component from \`@remotion/light-leaks\`, typically placed inside a \`<TransitionSeries.Overlay>\` over a cut point between scenes, configured by \`seed\` (pattern shape) and \`hueShift\` (color rotation in degrees). USE WHEN: the prompt asks for "@remotion/light-leaks", the "LightLeak component", a pre-built WebGL leak overlay between scene cuts, a hue-shifted flare sitting over a transition ("blue light leak transition", "vazamento de luz entre cenas", "light leak azul/verde/roxo"). DO NOT USE WHEN: the user describes custom-drawn gradient flares built manually with divs, SVG, or CSS filters — that is typography or custom transition work, not this component. PAIRS WITH: transitions.
- lottie: loading and playing pre-made Lottie/JSON animations from URLs. USE WHEN: the user explicitly references "Lottie", "After Effects export", "animação em Lottie", or provides a .json animation URL. DO NOT USE WHEN: the user describes a custom animation to build — Lottie is only for pre-built JSON assets. PAIRS WITH: (none).
- maps: geographic or map-based visuals — markers moving across a map, route drawing, country highlights, city-to-city animations. USE WHEN: the prompt references "map", "route", "pin dropping", "countries", "mapa", "traçar rota", "marcador no mapa". DO NOT USE WHEN: the user only mentions a geographic theme without an actual map in the visual. PAIRS WITH: sequencing, typography.
- messaging: chat-style interfaces — iMessage, WhatsApp, SMS, DMs — with bubbles appearing sequentially, typing indicators, platform chrome. USE WHEN: the prompt explicitly describes a chat or message thread ("WhatsApp conversation", "iMessage", "balão de mensagem", "DM do Instagram", "conversa de chat"). DO NOT USE WHEN: the user only wants a single quote or kinetic text block styled like a caption — that is typography, not a chat UI. PAIRS WITH: sequencing, typography.
- sequencing: staggered reveals and choreography within a single scene — items, bullets, or icons appearing one after another. USE WHEN: the prompt lists multiple elements, uses phrases like "one by one", "staggered", "list of items", "aparecendo um a um", "lista de itens", "reveal progressivo". DO NOT USE WHEN: the prompt describes cuts or changes between entirely separate scenes — that is transitions. PAIRS WITH: timing, typography.
- sfx: discrete sound effects synced to visual beats — whoosh, ding, click, page-turn, boom, shutter — served from the pre-hosted \`@remotion/sfx\` catalog. USE WHEN: the prompt asks for a "sound effect", "whoosh on transition", "ding", "boom", "click sound", "page-turn", "shutter", "efeito sonoro", "som de whoosh", "estalo no corte". DO NOT USE WHEN: the user wants a music track, ambient bed, or continuous soundscape — that is audio, not sfx. PAIRS WITH: transitions, sequencing.
- social-media: platform-native social formats with their own chrome and conventions — either vertical short-form (Stories, Reels, TikTok, Shorts) OR horizontal long-form hook content (YouTube channel intros, subscribe CTAs, 16:9 openers). USE WHEN: the prompt names a platform or format — "Instagram Story", "TikTok", "Reel", "YouTube Short", "vídeo vertical 9:16", "stories", "YouTube channel intro", "abertura de canal", "hook de vídeo", "CTA de inscrever-se", any subscribe-button sequence on 16:9. DO NOT USE WHEN: the user asks for a generic video with no platform framing, no format/aspect spec, and no platform-specific conventions like subscribe CTAs or story chrome. PAIRS WITH: typography, transitions.
- timing: organic, physical motion for entrances and exits — things popping, bouncing, scaling, settling with momentum, as well as bezier interpolations. USE WHEN: the prompt asks for "pop in", "bounce", "scale up", "snappy", "elástico", "quicar", or any reveal that should feel alive rather than mechanical. Spring is the default for reveals. DO NOT USE WHEN: the user explicitly asks for constant-speed without any easing. PAIRS WITH: sequencing.
- subtitles: word-synced caption strips overlaid on video or talking-head content, including word-by-word highlight and burned-in styles. USE WHEN: the prompt mentions "subtitles", "captions", "legendas", "word-by-word", "karaoke captions", "legendas estilo podcast", or an SRT/VTT file. DO NOT USE WHEN: the user only wants a headline or centered title — that is typography, not a caption track. PAIRS WITH: typography.
- text-animations: word- or character-level animated reveals — typewriter, word rotation, highlight sweep, crossfade swaps, shimmer sweeps. USE WHEN: the prompt asks for "typewriter", "rotating words", "text swap", "highlighted word", "efeito máquina de escrever", "palavras alternando", "shimmer", "efeito de brilho no texto". DO NOT USE WHEN: the user wants static titles with a simple fade-in — that is typography alone. PAIRS WITH: typography, sequencing.
- transitions: visible changes between two distinct scenes — fades, slides, wipes, cinematic wipes, cross-dissolves joining cuts. USE WHEN: the prompt describes multiple scenes, "transition", "fade to next", "slide to the next section", "3 cenas com transição", "corte com fade", "cinematic wipe", "wipe transition". DO NOT USE WHEN: elements appear inside a single continuous scene — that is sequencing, not transitions. PAIRS WITH: sequencing, light-leaks.
- typography: hierarchy, scale, weight, and styling of text as the primary visual — bold titles, kinetic headlines, text-led compositions. USE WHEN: the prompt is text-first ("big title", "quote", "headline", "tipografia grande", "frase em destaque") or names a type-driven aesthetic. DO NOT USE WHEN: the prompt only mentions a small label or caption accompanying another dominant visual like a chart or a 3D object. PAIRS WITH: text-animations, timing.
- videos: embedding an actual video clip inside the composition via \`<Video>\` from \`@remotion/media\`, with trim, volume, speed, loop, and pitch. USE WHEN: the prompt references "video clip", "MP4", "b-roll", "embed this video", "clipe de vídeo", "vídeo anexado", "incorporar vídeo", or supplies a video file/URL that must play in the composition. DO NOT USE WHEN: the user only describes a visual style reminiscent of video ("cinematic look", "estilo videoclipe", "looks like a movie") with no actual video file in play. PAIRS WITH: audio, transitions, subtitles.
- voiceover: generating AI narration via ElevenLabs TTS and sizing each scene to the resulting audio through \`calculateMetadata\`. USE WHEN: the prompt asks for "AI voiceover", "TTS narration", "ElevenLabs", "generate voice from script", "voz gerada por IA", "narração automática", or a scene-timed narration pipeline driven from script text. DO NOT USE WHEN: the user supplies their own pre-recorded narration file — that is audio, not voiceover. PAIRS WITH: audio, subtitles.

## Code examples (complete working references)
- example-histogram: frequency-distribution bar chart with unlabeled equal-width bars. USE WHEN: the prompt describes "histogram", "distribution", "frequency of X", "histograma de frequências", or a minimal unlabeled bar visualization. DO NOT USE WHEN: the prompt asks for a chart with real-world labeled axes or a time series — use example-gold-price-chart. PAIRS WITH: charts.
- example-text-rotation: a single hero word (or phrase) held fullscreen, 
  replaced over time by the next one with a dissolve — each entry scales in from 
  small + blurred, holds sharp at full size, then scales up and blurs out as it 
  leaves. Words do not overlap visually; one leaves before the next arrives. 
  USE WHEN: the prompt asks for a sentence or thought that reveals in parts over 
  time ("three lines appearing one after another", "frases que aparecem em 
  sequência", "revelação narrativa em partes"), a standalone rotating hero title 
  with dissolve/scale, or "text rotation with blur" as a solo element. 
  DO NOT USE WHEN: the prompt describes a fixed prefix with a changing word 
  beside it ("Created for [X / Y / Z]" pattern) — use example-word-carousel. 
  PAIRS WITH: text-animations, typography.
- example-falling-spheres: 3D spheres falling with physics using ThreeJS. USE WHEN: the prompt describes "falling", "bouncing", "gravity", "3D spheres", "esferas caindo", "simulação de física". DO NOT USE WHEN: the prompt asks for a static 3D object or simple rotation — 3d guidance alone is enough. PAIRS WITH: 3d, timing.
- example-animated-shapes: bouncing and rotating SVG primitives (circle, triangle, rect, star). USE WHEN: the prompt asks for "shapes", "geometric animation", "bouncing circles and triangles", "formas geométricas", "animação de formas". DO NOT USE WHEN: the prompt requires real data-driven shapes (charts) or true 3D geometry. PAIRS WITH: timing.
- example-lottie: loading a Lottie animation from a URL into the composition. USE WHEN: the prompt references a Lottie JSON URL or asks for a "Lottie animation" scaffold. DO NOT USE WHEN: there is no Lottie reference — this example is tightly scoped. PAIRS WITH: lottie.
- example-gold-price-chart: labeled bar chart with real-world values and a month/time-series x-axis, with staggered bar entrances. USE WHEN: the prompt describes "bar chart of X by month", "sales from Jan to Dec", "stock price monthly", "gráfico de barras mensal", "evolução de preço ao longo do tempo". DO NOT USE WHEN: the prompt is an unlabeled distribution — use example-histogram. PAIRS WITH: charts, sequencing.
- example-typewriter-highlight: typewriter effect with cursor blink, natural pause, and word highlight. USE WHEN: the prompt asks for "typewriter", "typing animation", "cursor piscando", "digitação letra a letra com destaque". DO NOT USE WHEN: the prompt asks for words rotating or crossfading — use example-text-rotation or example-word-carousel. PAIRS WITH: text-animations, typography.
- example-word-carousel: a fixed prefix sitting beside a single slot where one 
  word cycles through a list, with a true crossfade (both words rendered 
  simultaneously during the swap — outgoing fades and blurs out while incoming 
  fades and blurs in). The slot width is locked to the longest word so the 
  prefix never shifts. USE WHEN: the prompt describes a tagline with a static 
  part and a rotating part ("Built for [Creators / Marketers / Everyone]", 
  "Feito para [X / Y / Z]", "[Static phrase] + rotating word", "hero line with a 
  cycling word at the end"). DO NOT USE WHEN: the prompt describes a multi-part 
  narrative revealing sequentially, or a lone hero word changing fullscreen — 
  use example-text-rotation. PAIRS WITH: text-animations, typography.

## Examples

User prompt: "loading bar from 0 to 100%"
→ ["charts", "example-progress-bar"]
Reasoning: explicit progress bar request; example-progress-bar matches the archetype exactly, and charts supplies the data-viz rules.

User prompt: "abertura motivacional para meu canal de academia, 30 segundos"
→ ["typography", "text-animations", "timing", "sequencing", "transitions", "light-leaks"]
Reasoning: motivational gym intro implies kinetic titles (typography + text-animations), percussive reveals (timing), a multi-beat arc (sequencing + transitions), and a gym-cinematic aesthetic (light-leaks).

User prompt: "3D rotating cube with colored faces"
→ ["3d"]
Reasoning: single clear intent; no text, no multi-scene, no data — one skill is enough.

## Output contract
Return a JSON object containing:
- \`skills\`: An array of skill names taken ONLY from the two lists above. Return an empty array only if the prompt is so abstract or unusual that no category applies.
- \`durationInFrames\`: Number of frames if the user explicitly requests a duration (e.g., "500 frames", "10 seconds" -> 300 frames if assuming 30fps). Null if not explicitly specified.
- \`width\`: The requested width in pixels if the user explicitly requests a dimension or aspect ratio (e.g., "1080x1920", "vertical video" -> 1080). Null if not explicitly specified.
- \`height\`: The requested height in pixels if the user explicitly requests a dimension or aspect ratio (e.g., "1080x1920", "vertical video" -> 1920). Null if not explicitly specified.`;