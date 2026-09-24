# Diagnóstico V4 — Validação de Áudio e Sandboxing Dinâmico

> **Objetivo:** Avaliar se a injeção do pacote `@remotion/media-utils` no motor dinâmico (`compiler.ts`) foi bem-sucedida e se a IA consegue gerar visualizações reativas a áudio sem disparar erros de `ReferenceError` no *runtime* (como estava ocorrendo com `useWindowedAudioData`).

---

## Metodologia
Copie os prompts abaixo e cole na interface da sua aplicação SaaS para gerar os componentes dinâmicos. O foco é confirmar que a compilação passa com sucesso e que a renderização visual reage ao áudio.

---

### Teste 1: Visualização Básica de Áudio 2D (Ondas/Barras)
**Prompt de entrada:**
```text
Crie um visualizador de áudio 2D minimalista com barras verticais que reagem às frequências de uma música. O visual deve ser dinâmico e premium.
```
**Comportamento esperado:**
- O código gerado invoca `useAudioData` ou `useWindowedAudioData` e utiliza `visualizeAudio` para captar os valores.
- O componente renderiza as barras perfeitamente sem o erro `useWindowedAudioData is not defined` quebrar a tela.

### Teste 2: Áudio 3D Sincronizado (O Culpado Original)
**Prompt de entrada:**
```text
Crie uma animação 3D onde um objeto central (como um icosaedro ou cubo) pulsa sua escala e brilho em sincronia com uma música. A iluminação deve reagir aos picos do áudio.
```
**Comportamento esperado:**
- O código combina primitivas do `@remotion/three` (`<ThreeCanvas>`, `<mesh>`) com utilidades de áudio (`useAudioData`).
- A escala do objeto 3D e a intensidade da luz (`emissiveIntensity` ou equivalente) variam baseadas nos valores de áudio do frame.
- O renderizador não sofre *crash* ao resolver as funções importadas.

### Teste 3: Waveform Avançado (SVG Path)
**Prompt de entrada:**
```text
Crie um visualizador de áudio estilo "waveform" usando um caminho (path) SVG contínuo que se desenha e ondula suavemente na tela de acordo com a música, usando cores gradientes.
```
**Comportamento esperado:**
- O código faz uso das funções avançadas injetadas: `visualizeAudioWaveform`, `getWaveformPortion` ou `createSmoothSvgPath`.
- O compilador dinâmico resolve todas as referências sem problemas e a linha vetorial é montada no *preview*.

---

## Critérios de Sucesso da Rodada
1. Nenhuma geração resulta em tela branca por falha no `Babel/new Function` dentro de `compiler.ts`.
2. Os vídeos tocam e apresentam reatividade clara, atestando que os dados do áudio estão fluindo do `@remotion/media-utils` para as propriedades CSS/WebGL do componente renderizado.
