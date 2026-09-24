# Rodada de Testes V5: Inteligência Tipográfica, Motion e Legendas

## Objetivo
Validar se o modelo consegue aderir rigorosamente aos três Perfis Estéticos implementados nas skills (`typography.md`, `text-animations.md`, `subtitles.md`), aplicando a hierarquia visual correta, animações aderentes à intenção criativa, e regras rigorosas de convivência e _safe zones_ para legendas.

---

## Teste 1: Perfil A - Premium / Cinematic
**Objetivo:** Avaliar a execução do minimalismo, uso de fontes finas, *blur reveals* e ausência de fundos nas legendas de estilo documentário.

**Prompt de Teste:**
> "Gere um vídeo no estilo 'Documentário / Institucional Premium'. A composição deve ter uma proporção 16:9. A cena 1 deve mostrar uma citação inspiradora (Headline) sobre 'O futuro do design'. A cena 2 deve conter um Voiceover longo explicando o conceito. Utilize a estética Cinematic/Premium, com fontes finas, blur reveals suaves para os títulos, espaçamento de letras positivo e um 'cinematic fade' para as legendas, que devem ser agrupadas em blocos calmos de 4 a 6 palavras. A paleta deve ser monocromática e extremamente elegante."

**Critérios de Avaliação:**
- [ ] Fontes finas (weight 300/400) com `letterSpacing` positivo.
- [ ] Título utilizando a animação de "Blur Reveal" (`opacity` + `blur`).
- [ ] Legendas agrupadas (4 a 6 palavras por vez).
- [ ] Legendas com fade de `opacity` suave, SEM caixas/fundos coloridos.

---

## Teste 2: Perfil B - Kinetic / Statement
**Objetivo:** Avaliar o texto como a própria arte visual, fontes grotescas gigantes, espaçamento negativo e animações impactantes.

**Prompt de Teste:**
> "Crie um opener de impacto de 5 segundos no formato 1:1, com foco total na tipografia. O vídeo é um 'Manifesto de Produto'. Use estritamente a estética 'Kinetic / Statement'. O slogan central é 'CONSTRUA. RÁPIDO.' com palavras preenchendo quase toda a tela (fontes massivas peso 900, espaçamento negativo). Utilize uma animação agressiva como Text Scramble ou Highligher/Focus na palavra principal. Não coloque voiceovers ou textos passivos."

**Critérios de Avaliação:**
- [ ] Fonte massiva (weight 800/900) preenchendo grande parte da largura da tela (`maxWidth` dinâmico).
- [ ] Espaçamento negativo (`letterSpacing: -2` a `-4`).
- [ ] Aplicação correta de animações restritas (Text scramble, Word morph/carousel ou destaque Highlighter).
- [ ] Ausência completa de descrições genéricas competindo com a Headline.
- [ ] Presença dos Hard Guardrails ergonômicos (`lineHeight: 1.1`, `textWrap: 'balance'`).

---

## Teste 3: Perfil C - Social / High-Retention e Convivência Visual
**Objetivo:** Avaliar a obediência às *Safe Zones* para celular, agitação rítmica das legendas e convivência pacífica (mas separada) entre o Headline e as Captions.

**Prompt de Teste:**
> "Crie um Short/Reel (9:16) super dinâmico no estilo TikTok focado em retenção de audiência. O tema é '3 dicas de marketing'. No topo da tela (longe das bordas), coloque o Headline 'Dica de Ouro'. Na parte inferior, gere legendas simulando um voiceover acelerado. Siga estritamente o perfil Social: pule as palavras na tela em blocos de 1 a 3 palavras com bouncy springs (efeito de mola no Remotion), use cores contrastantes com contorno/sombra duras nas letras. Garanta obrigatoriamente que a legenda respeite a Safe Zone, ficando fixada a 25% da base da tela."

**Critérios de Avaliação:**
- [ ] Composição alocando o Headline no topo superior e as legendas isoladas na parte inferior.
- [ ] Respeito absoluto à Safe Zone (Legendas posicionadas a no mínimo `bottom: 25%` ou `250px`).
- [ ] Pacing de legenda acelerado (1 a 3 palavras).
- [ ] Presença do efeito de mola (`spring`) nas legendas ao entrarem em tela.
- [ ] Uso de sombra pesada (`textShadow`) ou Stroke para legibilidade máxima nas palavras.
- [ ] A *Headline* no topo tem proporções diferentes e não concorre diretamente na animação frenética com a legenda.

---

## Como Executar
1. Cole os prompts de teste (um de cada vez) neste chat ou na interface principal do seu sistema de IA.
2. Analise o código TypeScript/React gerado pela IA (verifique se os Hard Guardrails como `textWrap: 'balance'`, restrições de sombra, e manipulação correta da propriedade animada do Remotion estão lá).
3. Visualize o resultado final via `localhost:3000` (npm run dev) e faça a auditoria visual em tela usando as checkboxes.
