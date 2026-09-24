---
name: subtitles
description: subtitles, voiceover caption rules, and pacing
metadata:
  tags: subtitles, captions, remotion, pacing, safe-zones
---

All captions must be processed in JSON. The captions must use the `Caption` type which is the following:

```ts
import type { Caption } from "@remotion/captions";
```

This is the definition:

```ts
type Caption = {
  text: string;
  startMs: number;
  endMs: number;
  timestampMs: number | null;
  confidence: number | null;
};
```

## 1. Regra Estrita de Convivência Visual (CRITICAL)

Legendas de voz (*Voiceover Captions*) **NUNCA devem competir** com Headlines (*Tipografia Estrutural*). 
Se ambos existirem na mesma tela:
- As Captions devem ser reduzidas em tamanho.
- Devem ser alocadas de forma discreta na parte inferior.
- Não devem possuir caixas/backgrounds de alto contraste, para garantir que o Destaque visual (Headline) retenha a atenção.

## 2. Safe Zones (CRITICAL)

Textos vitais não podem ser cortados ou ficar cobertos pela UI dos aplicativos de redes sociais:
- **Perfil Social (Reels/TikTok/Shorts):** Qualquer legenda deve ficar **pelo menos 25% acima da base da tela** (ex: `bottom: '25%'` ou no mínimo `bottom: 250px` dependendo da resolução). Isso impede que os ícones do aplicativo tapem a legenda. Afaste-se das bordas laterais também (mínimo `5%` de padding horizontal).

## 3. Diretriz de Pacing (Ritmo e Estilos)

O ritmo (pacing) e o agrupamento das palavras na tela, bem como o visual da legenda, DEVEM seguir o Perfil Estético da composição:

### Perfil A: Premium / Cinematic (Minimal)
- **Pacing:** Frases agrupadas (ex: 4 a 6 palavras por vez usando funções como `combineTokensWithinMilliseconds`). O texto precisa ser sereno e legível.
- **Visual:** Estilo "Cinematic Fade". Fontes limpas, monocromáticas (geralmente branco com leve opacidade). Usa fade in/fade out. **Sem blocos coloridos de fundo.**

### Perfil B: Kinetic / Statement
- **Pacing:** Ausentes ou completamente invisíveis durante o clímax (quando a Tipografia/Headline é muito pesada). Se existirem em outras partes, devem sumir rapidamente.
- **Visual:** Textos grossos (brutalistas), sem animações contínuas, aparecem em "flashes".

### Perfil C: Social / High-Retention (Punchy)
- **Pacing:** Curto e agressivo. Apenas **1 a 3 palavras** na tela por vez. Agrupamento muito rápido.
- **Visual:** Estilo "Box / Highlight" ou "Karaoke". Fundo sólido (ex: um shape atrás da palavra atual) ou pinta a palavra ativa com `COLORS.accent`. Pulos elásticos (`scale: spring()`) quando a palavra entra. Uso obrigatório de contornos duros (stroke) ou sombras densas para contraste infalível.

## 4. Regra Absoluta de Contraste

- O LLM nunca deve assumir que o texto estará legível sobre qualquer imagem/vídeo. Aplique sempre sombras (`textShadow: '0px 4px 10px rgba(0,0,0,0.6)'`) ou um black gradient atrás da legenda. Amarre cores ao `THEME`.

---

## Technical Implementations

### Generating captions
To transcribe video and audio files to generate captions, load the [./transcribe-captions.md](./transcribe-captions.md) file for more instructions.

### Displaying captions
To display captions in your video, load the [./display-captions.md](./display-captions.md) file for more instructions.

### Importing captions
To import captions from a .srt file, load the [./import-srt-captions.md](./import-srt-captions.md) file for more instructions.
