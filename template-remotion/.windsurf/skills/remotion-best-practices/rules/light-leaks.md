---
name: light-leaks
description: Regras para uso de efeitos overlay de Light Leak. Contém diretrizes estritas de QUANDO NÃO USAR.
metadata:
  tags: light-leaks, overlays, effects, transitions
---

## 🚫 QUANDO NÃO USAR (Anti-Bias Rule)

> **CRÍTICO:** O LLM tem viés de adicionar `<LightLeak>` como "maquiagem visual" padrão em transições. **ISSO ESTÁ PROIBIDO.**

**NÃO USE LIGHT LEAKS SE:**
1. **O tema for `Minimalista` ou `Editorial`.** Nestes temas, transições devem ser limpas, baseadas em geometria, tipografia, máscaras de corte e opacidade. Um light leak destrói a elegância do estilo premium (Apple/Stripe/Linear).
2. **A transição for um Morph (Modo A).** Light leaks mascaram a interpolação do container. O container é o fio condutor visual; obscurecê-lo com um leak quebra a continuidade narrativa.
3. **O background já for claro ou chapado.** Light leaks funcionam bem apenas sobre composições majoritariamente dark (Premium Dark) e com profundidade de camadas (Cards nível 1, 2, 3).

**QUANDO USAR:** Apenas em temas `Neon/Glow` ou em momentos de transição direcional (Modo B) para impacto dramático, ou como overlay sutil constante em temas estéticos retro/cinematográficos com baixa opacidade.

## Light Leaks

This only works from Remotion 4.0.415 and up. Use `npx remotion versions` to check your Remotion version and `npx remotion upgrade` to upgrade your Remotion version.

`<LightLeak>` from `@remotion/light-leaks` renders a WebGL-based light leak effect. It reveals during the first half of its duration and retracts during the second half.

Typically used inside a `<TransitionSeries.Overlay>` to play over the cut point between two scenes. See the **transitions** rule for `<TransitionSeries>` and overlay usage.

## Prerequisites

```bash
npx remotion add @remotion/light-leaks
```

## Basic usage with TransitionSeries

```tsx
import { TransitionSeries } from "@remotion/transitions";
import { LightLeak } from "@remotion/light-leaks";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneA />
  </TransitionSeries.Sequence>
  <TransitionSeries.Overlay durationInFrames={30}>
    <LightLeak />
  </TransitionSeries.Overlay>
  <TransitionSeries.Sequence durationInFrames={60}>
    <SceneB />
  </TransitionSeries.Sequence>
</TransitionSeries>;
```

## Props

- `durationInFrames?` — defaults to the parent sequence/composition duration. The effect reveals during the first half and retracts during the second half.
- `seed?` — determines the shape of the light leak pattern. Different seeds produce different patterns. Default: `0`.
- `hueShift?` — rotates the hue in degrees (`0`–`360`). Default: `0` (yellow-to-orange). `120` = green, `240` = blue.

## Customizing the look

```tsx
import { LightLeak } from "@remotion/light-leaks";

// Blue-tinted light leak with a different pattern
<LightLeak seed={5} hueShift={240} />;

// Green-tinted light leak
<LightLeak seed={2} hueShift={120} />;
```

## Standalone usage

`<LightLeak>` can also be used outside of `<TransitionSeries>`, for example as a decorative overlay in any composition:

```tsx
import { AbsoluteFill } from "remotion";
import { LightLeak } from "@remotion/light-leaks";

const MyComp: React.FC = () => (
  <AbsoluteFill>
    <MyContent />
    <LightLeak durationInFrames={60} seed={3} />
  </AbsoluteFill>
);
```
