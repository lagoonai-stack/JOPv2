---
title: Scene Transitions
impact: HIGH
impactDescription: enables smooth scene changes and professional video flow
tags: transitions, fade, slide, wipe, scenes
---

## 1. Inteligência Decisória: Fade vs Slide

NUNCA escolha transições aleatoriamente.
*   **Fade (`fade()`):** Use para temas mais calmos (PREMIUM DARK, EDITORIAL, CORPORATE), ou quando houver uma transição de tempo/mood (ex: passagem de tempo longo). Cria uma respiração entre cenas.
*   **Slide (`slide()`):** Use para temas dinâmicos (NEON, SOCIAL, PUNCHY) ou quando houver direção de leitura contínua. **REGRA DE INÉRCIA:** O slide DEVE respeitar a inércia do movimento de saída da cena anterior. Se a Cena A tem elementos saindo para a esquerda, o Slide da Cena B deve vir da direita (`direction: "from-right"`), "empurrando" a Cena A para fora.

## 2. Regra Estrita de Orçamento de Frames (Frame Budget)

Transições reduzem o tempo total da composição, pois causam sobreposição (overlap) entre as cenas. Você DEVE calcular essa perda corretamente.
*   **A matemática:** Se você tem Cena A (60 frames) + Cena B (60 frames) separadas por uma transição de 15 frames, o tempo total **não é 120**, é **105**.
*   **A Regra:** Ao configurar a `durationInFrames` da `<Composition>`, some a duração de todas as `Sequence`s e **SUBTRAIA** a duração total de todas as transições. Não fazer isso resultará em frames finais vazios ou vídeo cortado.

## 3. TransitionSeries for Scene ChangesUse TransitionSeries to animate between multiple scenes or clips.

**Incorrect (abrupt scene cuts):**

```tsx
<Sequence from={0} durationInFrames={60}>
  <SceneA />
</Sequence>
<Sequence from={60} durationInFrames={60}>
  <SceneB />
</Sequence>
```

**Correct (smooth transitions):**

```tsx
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneA />
  </TransitionSeries.Sequence>
  <TransitionSeries.Transition
    presentation={fade()}
    timing={linearTiming({ durationInFrames: 15 })}
  />
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneB />
  </TransitionSeries.Sequence>
</TransitionSeries>;
```

## Available Transition Types

Import transitions from their respective modules:

```tsx
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";
import { flip } from "@remotion/transitions/flip";
import { clockWipe } from "@remotion/transitions/clock-wipe";
```

## Slide Transition with Direction

Specify slide direction for enter/exit animations.

```tsx
import { slide } from "@remotion/transitions/slide";

<TransitionSeries.Transition
  presentation={slide({ direction: "from-left" })}
  timing={linearTiming({ durationInFrames: 20 })}
/>;
```

Directions: `"from-left"`, `"from-right"`, `"from-top"`, `"from-bottom"`

## Transition Discipline: Cinematic Wipes & Overlaps

As part of the **Premium Motion Grammar**, basic fades are discouraged for structural changes. Instead, use cinematic wipes and overlaps. 

**Rule of Transition Discipline:** Structural transitions (like wipes or grid reveals) must have mandatory visual overlap and use `clipPath` or masks rather than just opacity fades.

**Cinematic Wipe Code Example:**
Instead of a simple fade, you can create a directional, cinematic wipe using a custom transition or overlay:

```tsx
import { spring, useVideoConfig } from 'remotion';

// Example of a dynamic mask for a Cinematic Wipe (to be applied in a custom transition component)
const { fps } = useVideoConfig();
// frame is passed into your custom transition component
const progress = spring({ fps, frame, config: { damping: 14 } });

// This creates a wipe from left to right using a polygon mask
const clipPath = `polygon(0 0, ${progress * 100}% 0, ${progress * 100}% 100%, 0 100%)`;

// Apply to your wrapper: style={{ clipPath }}
```

## Custom Crossfade Without TransitionSeries

For simple opacity crossfades within a single component:

```tsx
const TRANSITION_START = 60;
const TRANSITION_DURATION = 15;

const scene1Opacity = interpolate(
  frame,
  [TRANSITION_START, TRANSITION_START + TRANSITION_DURATION],
  [1, 0],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);

const scene2Opacity = interpolate(
  frame,
  [TRANSITION_START, TRANSITION_START + TRANSITION_DURATION],
  [0, 1],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);

<AbsoluteFill style={{ opacity: scene1Opacity }}><SceneA /></AbsoluteFill>
<AbsoluteFill style={{ opacity: scene2Opacity }}><SceneB /></AbsoluteFill>
```

## Timing Options

```tsx
import { linearTiming, springTiming } from "@remotion/transitions";

// Linear timing - constant speed
linearTiming({ durationInFrames: 20 });

// Spring timing - organic motion
springTiming({ config: { damping: 200 }, durationInFrames: 25 });
```

## Overlay Example

Any React component can be used as an overlay in `TransitionSeries` (e.g. for light leaks, flashes, or custom visual elements that sit on top of the cut without shortening the timeline).

```tsx
import { TransitionSeries } from "@remotion/transitions";
import { LightLeak } from "@remotion/light-leaks";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneA />
  </TransitionSeries.Sequence>
  <TransitionSeries.Overlay durationInFrames={20}>
    <LightLeak />
  </TransitionSeries.Overlay>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneB />
  </TransitionSeries.Sequence>
</TransitionSeries>;
```

## Mixing Transitions and Overlays

Transitions and overlays can coexist in the same `<TransitionSeries>`, mas **um overlay NÃO PODE ser adjacente a uma transition ou outro overlay**.

> [!WARNING]
> **REGRA CRÍTICA:** Se o usuário pedir um `fade()` ou transição suave E também um overlay (ex: `LightLeak`) na **mesma virada de cena**, você **NÃO PODE** colocar `<TransitionSeries.Transition>` e `<TransitionSeries.Overlay>` juntos. Isso causa o erro fatal: `A <TransitionSeries.Overlay /> component must not be followed by a <TransitionSeries.Transition />`.
> 
> **Como resolver:** Use **APENAS** o `<TransitionSeries.Overlay>` na virada. O corte da cena por baixo será "seco", mas o pico de brilho do lightleak ou efeito cobrirá o corte. Nunca tente colocar os dois tags adjacentes.

```tsx
// CORRETO: Usando Overlay e Transition em cortes DIFERENTES
<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneA />
  </TransitionSeries.Sequence>
  
  {/* Corte 1: Usando apenas Overlay (corte seco por baixo) */}
  <TransitionSeries.Overlay durationInFrames={30}>
    <LightLeak />
  </TransitionSeries.Overlay>
  
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneB />
  </TransitionSeries.Sequence>
  
  {/* Corte 2: Usando apenas Transition (suave) */}
  <TransitionSeries.Transition
    presentation={fade()}
    timing={linearTiming({ durationInFrames: 15 })}
  />
  
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneC />
  </TransitionSeries.Sequence>
</TransitionSeries>;
```

## Duration Calculation (Precise Math)

Transitions overlap adjacent scenes, so the total composition length is **shorter** than the sum of all sequence durations. Overlays do **not** affect the total duration.

Use `getDurationInFrames()` to get the exact duration of a transition timing, especially important for `springTiming` which calculates duration based on physics:

```tsx
import { linearTiming, springTiming } from "@remotion/transitions";

const linearDuration = linearTiming({
  durationInFrames: 20,
}).getDurationInFrames({ fps: 30 }); // Returns 20

const springDuration = springTiming({
  config: { damping: 200 },
}).getDurationInFrames({ fps: 30 }); // Returns calculated frames

// Total Composition Duration Math:
const scene1Duration = 60;
const scene2Duration = 60;
const scene3Duration = 60;

const transition1Duration = linearTiming({ durationInFrames: 15 }).getDurationInFrames({ fps: 30 });
const transition2Duration = linearTiming({ durationInFrames: 20 }).getDurationInFrames({ fps: 30 });

const totalDuration =
  scene1Duration + scene2Duration + scene3Duration -
  transition1Duration - transition2Duration;
```
