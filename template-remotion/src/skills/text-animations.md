---
name: text-animations
description: Typography and text animation patterns based on Aesthetic Profiles.
metadata:
  tags: typography, text, animation, motion, kinetic
---

## Inteligência de Decisão: Animações por Perfil Estético

O modelo não deve apenas "animar texto porque sim". A escolha do *Motion* deve seguir estritamente o **Perfil Estético** ativo para a composição:

### Perfil A: Premium / Cinematic (Motion Primitives)
- **Estética:** Foco em suavidade, respiração e elegância.
- **Técnicas Restritas:**
  - **Blur Reveals:** Animar de `filter: 'blur(10px)'` e `opacity: 0` para blur 0 e opacity 1. (Ideal para documentários e moods reflexivos).
  - **Slow Fades:** Opacidade com transições muito longas (ex: 2 a 3 segundos).
  - **Invisible Masks (Y-Translate Clip):** Revelar o texto surgindo de baixo para cima (`translateY`) através de um contêiner com `overflow: hidden`, sem o uso de fundos coloridos ou bounciness.

### Perfil B: Kinetic / Statement (React Bits)
- **Estética:** Agressiva, focada na palavra, ritmada, digital.
- **Técnicas Restritas:**
  - **Text Scramble:** Efeito hacker/decodificação para palavras curtas. Use `useCurrentFrame` e substituição de strings usando caracteres aleatórios durante a revelação.
  - **True Focus / Highlighter:** A palavra central é nítida, o resto desfocado; ou o uso de um *Highlighter Sweep* que pinta o fundo de uma única palavra principal.
  - **Text Pressure:** Letras com larguras variáveis/animadas.
  - **Word Carousel / Morph:** Troca rápida de palavras de impacto usando `translateY` rápido com opacidade em containers mascarados.

### Perfil C: Social / High-Retention (React Video Editor)
- **Estética:** Extrema energia, "pula" na tela, prende a atenção.
- **Técnicas Restritas:**
  - **Bouncy Springs:** Molas elásticas com *overshoot*. Use `spring` do Remotion configurado com `stiffness` alto e baixo `damping` (ex: `damping: 12`, `stiffness: 200`) acoplado a `scale`.
  - **Typewriter (Rápido):** String slicing agressivo (`text.slice(0, typedChars)`).

## Guardrails Técnicos de Motion

- **Typewriter Correctness:** Sempre use *string slicing* baseado no `useCurrentFrame()`. Nunca use animação de opacidade por caractere para simular o efeito.
- **Shimmer Sweep:** Se usar *Shimmer*, atrele ao `currentFrame` varrendo o texto de -100% a 200%. Use-o com extrema parcimônia e APENAS para destacar elementos "premium", não como um efeito contínuo padrão em todo texto.
