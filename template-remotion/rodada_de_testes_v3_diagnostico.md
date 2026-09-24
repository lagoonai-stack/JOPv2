# Diagnóstico V3 — Primitivas Premium, Guardrails 3D e Aesthetic Invariants

> **Objetivo:** Avaliar a aderência do sistema às novas heurísticas de qualidade visual (Premium Primitives) e aos limites operacionais restritos (Guardrails matemáticos e de performance em 3D), implementados nos planos recentes.

---

## Metodologia
Esta rodada deverá ser executada gerando localmente os prompts listados abaixo e aplicando a avaliação de "Eye Test" sobre os componentes e lógicas geradas. O foco central não é apenas validar se funciona, mas averiguar se **os anti-padrões foram proativamente evitados pelo modelo**.

---

## Categoria A — Aesthetic Motion Grammar (Continuous Motion & Depth Stack)

### A1 — Continuous Motion Primitive (Carrossel Infinito)
**Prompt de entrada:**
```text
Crie um vídeo com um carrossel infinito de 5 logos que rodam suavemente em loop.
```
**Comportamento esperado:**
- Movimento construído declarativamente: `<Sequence>` contendo deslocamentos via `style={{ transform: \`translateX(...)\` }}`.
- O cálculo do valor utiliza matemática modular ligada ao tempo (ex: `useCurrentFrame() % duration`).
**Critério de falha:**
- Código gerando blocos isolados `<style>` com injeções de translação infinita através de CSS nativo (`@keyframes`), as quais não sincronizam confiavelmente no WebGL/Remotion.

### A2 — Depth Stack Primitive
**Prompt de entrada:**
```text
Mostre uma pilha de 3 testemunhos. Quando o vídeo avançar, o testemunho de trás deve vir para a frente.
```
**Comportamento esperado:**
- Z-index e disposições arquitetadas via profundidade calculada. O componente atrela variáveis baseadas no layout aos módulos nativos do Remotion (escala decrescente baseada no `index` através da função `spring()`).
**Critério de falha:**
- Dependência incorreta de pacotes sem garantias de consistência em Remotion (ex: `framer-motion`).
- Os cartões transitam lado a lado em um grid bidimensional isolado e plano, não demonstrando hierarquia de "stack".

---

## Categoria B — Aesthetic Invariants (Tipografia, Texturas e Layout Premium)

### B1 — Coreografia "Masked Reveal" e Assimetria Bento Grids
**Prompt de entrada:**
```text
Crie uma tela de features estilo SaaS premium com 3 cartões e um título principal impactante. Eles devem entrar em cena com coreografia sofisticada.
```
**Comportamento esperado:**
- **Layout:** Estruturação através de CSS Grid assimétrico (Bento Grid) prevalecendo sobre colunas flex simples.
- **Entrada do Título:** Elementos textuais hero utilizam `overflow: hidden` e têm sua translação do `translateY(100%)` para `0%` controlada rigorosamente pela função interpolada `spring()`.
- **Rítmica:** Entradas defasadas utilizando variável de atraso orgânico (ex: `index * STAGGER_FRAMES`).
**Critério de falha:**
- Apresentação em lista vertical simplificada com animações baseadas meramente em transição isolada de opacidade (Fade-in básico genérico).

### B2 — Noise Premium (Premium Trick) e Complexidade de Sombras
**Prompt de entrada:**
```text
Faça uma introdução cinemática abstrata com fundo escuro, simulando um ambiente glassmorphism com texto flutuante.
```
**Comportamento esperado:**
- A peça apresenta profundidade tátil via `<svg>` com aplicação orgânica de `<feTurbulence>` (noise/grain base) associado ao comportamento `mix-blend-mode: overlay`.
- Os painéis em destaque contam com empilhamento de camadas e blur visual nativo (`backdropFilter`, além de `boxShadow` em várias camadas multiplicativas de opacidade sutil).
**Critério de falha:**
- Exibição de cenários chapados: ausência completa de noise/textura e sombras com única camada (`0 4px 8px rgba(0,0,0,0.5)`).

---

## Categoria C — Guardrails 3D e Engenharia Robusta de Render

### C1 — Conexões de Dados Media em ThreeJS (Áudio Sincronizado - F1 Fix)
**Prompt de entrada:**
```text
Crie uma animação 3D onde um objeto pulsa em sincronia com uma música.
```
**Comportamento esperado:**
- Código evidencia importação limpa e leitura utilitária do áudio via `@remotion/media-utils` (`useWindowedAudioData` ou similar).
- Propriedades de instâncias do *mesh* (escala, rotação secundária ou *emissiveIntensity*) estão reativamente ligadas aos valores sonoros lidos.
**Critério de falha:**
- Pseudo-pulsos falsificados usando senoides genéricas vinculadas puramente ao frame sem amarrar, de fato, os espectros da mídia exigida.

### C2 — Hard Cap Geométrico 3D (E2 Fix)
**Prompt de entrada:**
```text
Crie uma esfera 3D com resolução extremamente alta para uma textura suave perfeita.
```
**Comportamento esperado:**
- O *engine* refreia a impulsividade de gerar superfícies onerosas de forma irresponsável.
- Segmentos do `args` limitados aos limites preestabelecidos seguros: idealmente ao redor de `64` segmentos, bloqueando valores perigosos na casa centenária elevada.
**Critério de falha:**
- O código gerado exibe instâncias geométricas perigosas (`[1, 512, 512]`), induzindo propositadamente a travamentos crônicos (WebGL max limits/Timeouts) no renderizador.

### C3 — Dependência FPS-Agnóstica (F3 Fix)
**Prompt de entrada:**
```text
Crie uma animação de 2 cenas: a primeira com um cubo 3D girando (5 segundos) e a segunda com o cubo se afastando (5 segundos).
```
**Comportamento esperado:**
- Duração das instâncias `<Sequence>` extraídas dinamicamente via dependência funcional (ex: `fps * 5` derivados diretamente de `useVideoConfig()`).
**Critério de falha:**
- Tempo do componente instanciado "chumbado" no JSX sem contexto (ex: `durationInFrames={150}`).

### C4 — Renderização Partícular Instanciada (E1 Fix)
**Prompt de entrada:**
```text
Crie uma animação de 100 partículas 3D brilhantes flutuando pelo espaço, cada uma com seu próprio pequeno movimento.
```
**Comportamento esperado:**
- Adoção madura de primitivas ThreeJS escaláveis, preferencialmente `<instancedMesh>` em substituição ao encadeamento iterativo ingênuo do React para múltiplos corpos.
**Critério de falha:**
- Implementação frágil usando `.map()` que tenta instanciar 100 elementos `<mesh>` autônomos no JSX, estressando severamente o gargalo do render.
