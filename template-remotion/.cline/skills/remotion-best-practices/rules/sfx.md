---
name: sfx
description: Inteligência direcional para Efeitos Sonoros (SFX). Contém regras críticas de quando evitar o uso de sons.
metadata:
  tags: sfx, sound, effect, audio, silence
---

## 🚫 QUANDO NÃO USAR (Anti-Bias Rule)

> **CRÍTICO:** O modelo tende a adicionar som para "preencher o vazio". **O SILÊNCIO E O PACING SÃO ESCOLHAS DE DESIGN.**

**NÃO USE SFX SE:**
1. **A micro-animação for secundária:** Não adicione `mouse-click` ou `whoosh` para barras de progresso contínuas, contadores rápidos ou simples fades. Isso gera um "sujeira sonora".
2. **O arquétipo for `Editorial` ou `Minimalista`:** Estes temas exigem uma elegância orgânica. SFX como `vine-boom`, `bruh` ou `windows-xp-error` quebram completamente o tom de voz premium.
3. **Houver aglomeração ruidosa:** NUNCA toque mais de 2 SFX simultaneamente. O áudio obedece à mesma regra da hierarquia e do *negative space* que o design visual.

**QUANDO USAR:** Apenas para ancorar **grandes eventos narrativos** ou **cortes rítmicos marcados**:
- Uma revelação de texto heróica em `kinetic typography`.
- Uma transição de cena direcional muito acelerada (Modo B).
- Como acento funcional em overlays ou pop-ups de impacto crítico.

## Basic Usage

To include a sound effect, use the `<Audio>` tag:

```tsx
import { Audio } from "@remotion/sfx";

<Audio src={"https://remotion.media/whoosh.wav"} />;
```

The following sound effects are available:

- `https://remotion.media/whoosh.wav`
- `https://remotion.media/whip.wav`
- `https://remotion.media/page-turn.wav`
- `https://remotion.media/switch.wav`
- `https://remotion.media/mouse-click.wav`
- `https://remotion.media/shutter-modern.wav`
- `https://remotion.media/shutter-old.wav`
- `https://remotion.media/ding.wav`
- `https://remotion.media/bruh.wav`
- `https://remotion.media/vine-boom.wav`
- `https://remotion.media/windows-xp-error.wav`

For more sound effects, search the internet. A good resource is https://github.com/kapishdima/soundcn/tree/main/assets.
