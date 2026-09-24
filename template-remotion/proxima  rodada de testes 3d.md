\# Diagnóstico 3D — Rodada V2

\> Baseada nos gaps de cobertura da V1.  
\> V1 cobriu geração limpa de prompts diretos. V2 cobre o que V1 não foi capaz de medir.

\---

\#\# O que V1 deixou descoberto

| Dimensão | Por que V1 não cobriu |  
|---|---|  
| Anti-padrões técnicos | V1 só testou se o sistema fazia coisas certas, nunca se evitava coisas erradas |  
| Edição incremental em código 3D | V1 só testou geração inicial, nunca follow-up/edit |  
| Prompts ambíguos que deveriam recusar 3D | T5.1 era óbvio (card Instagram). V2 testa casos onde a linha é tênue |  
| 3D \+ outras skills (áudio, captions, transitions) | Nunca testado |  
| Reprodutibilidade do FAIL de T4.2 | Não sabemos se é consistente ou acidental |  
| Stress de performance além de 50 objetos | 50 meshes compilou — mas 100? 200? |  
| Animações que dependem de \`useRef\` | Padrão proibido no Remotion, e 3D induz tentação de usá-lo |  
| Guardrails para interatividade (OrbitControls) | Não testado explicitamente |

\---

\#\# Metodologia dos testes V2

Idêntica à V1:  
\- \*\*Prompt de entrada\*\* — input enviado ao sistema  
\- \*\*Comportamento esperado\*\* — o que o sistema deveria fazer  
\- \*\*Critério de falha\*\* — o que constitui gap real  
\- \*\*Categoria\*\* — técnica / estética / decisória / reliability  
\- \*\*Métrica alvo\*\* — indicador do Critical Prompt Engineer

\---

\#\# Categoria A — Reprodução e Isolamento do FAIL T4.2

\> Objetivo: entender se o erro de Easing é consistente, contextual ou aleatório.

\#\#\# A1 — Reprodução direta do T4.2

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma cena 3D com perspectiva dramática, como uma câmera baixa olhando para cima.  
\`\`\`  
\*(Prompt idêntico ao T4.2)\*

\*\*Comportamento esperado:\*\*  
\- Mesma compilação ou novo erro — queremos saber se é reproduzível

\*\*Critério de falha:\*\*  
\- Se erro se reproduz → é consistente, confirma gap no \`SYSTEM\_PROMPT\`  
\- Se compila → erro foi acidental, diagnóstico muda

\*\*Categoria:\*\* Reliability    
\*\*Métrica alvo:\*\* Taxa de compilação sem erro / previsibilidade entre gerações

\---

\#\#\# A2 — Mesmo intent, wording diferente

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação 3D onde a câmera está posicionada rente ao chão olhando para um objeto acima, com FOV amplo para efeito dramático.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Camera \`position\` com Y muito baixo (ex: \`\[0, \-2, 3\]\`)  
\- \`fov\` entre 90–110  
\- Compilação sem erro

\*\*Critério de falha:\*\*  
\- Mesmo runtime error de \`easing is not a function\`  
\- Camera em posição default sem ajuste de ângulo  
\- FOV inalterado (\`75\`)

\*\*Nota:\*\* Se A1 falha e A2 passa, o problema é o wording — o modelo usa Easing somente quando o prompt menciona "perspectiva dramática". Se ambos falham, o problema é estrutural no \`SYSTEM\_PROMPT\`.

\*\*Categoria:\*\* Reliability / Técnica    
\*\*Métrica alvo:\*\* Consistência entre gerações

\---

\#\#\# A3 — Isolamento: interpolate sem Easing

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma cena 3D onde um objeto aparece com fade-in suave e a câmera está levemente inclinada.

\`\`\`  
\*\*Comportamento esperado:\*\*  
\- Fade-in via \`interpolate(frame, \[0, 30\], \[0, 1\])\` simples, sem Easing  
\- Camera com Y ou X não-zero para inclinação  
\- Compilação limpa

\*\*Critério de falha:\*\*  
\- Modelo usa \`Easing.bezier()\` ou \`Easing.out()\` mesmo sem necessidade → confirma que o modelo tende a adicionar Easing automaticamente em cenas 3D

\*\*Nota:\*\* Esse teste isola se o problema é o uso de Easing em geral, ou só quando combinado com perspectiva 3D complexa.

\*\*Categoria:\*\* Reliability    
\*\*Métrica alvo:\*\* Taxa de compilação sem erro

\---

\#\# Categoria B — Anti-padrões técnicos

\> Objetivo: verificar se o sistema cai em armadilhas que quebram o Remotion determinístico.

\#\#\# B1 — OrbitControls (interatividade proibida)

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma cena 3D com controles de câmera onde o usuário pode orbitar ao redor do objeto.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Sistema recusa ou substitui por câmera orbital automática (sin/cos no frame)  
\- Output usa \`frame\` para animar a câmera, não interatividade do usuário  
\- Sem importação de \`OrbitControls\` de \`@react-three/drei\`

\*\*Critério de falha:\*\*  
\- \`import { OrbitControls } from '@react-three/drei'\` aparece no código  
\- Câmera com interação via mouse/touch → quebra render determinístico  
\- Código compila mas render estático não capta o movimento

\*\*Nota diagnóstica:\*\* \`OrbitControls\` é o anti-padrão 3D mais perigoso no Remotion — torna o render não-determinístico. A skill atual não menciona isso. Se o sistema gera \`OrbitControls\` sem instrução de guardrail, é um gap crítico.

\*\*Categoria:\*\* Técnica / Reliability    
\*\*Métrica alvo:\*\* Taxa de compilação sem erro / estabilidade de render

\---

\#\#\# B2 — useRef para objetos Three.js

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma cena 3D com um objeto que muda de cor gradualmente durante a animação.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Cor calculada via \`interpolate(frame, ...)\` passada como prop do material  
\- Ou \`new THREE.Color().lerp(...)\` calculado a partir do frame  
\- \*\*Sem\*\* \`useRef\` para manipular o material diretamente

\*\*Critério de falha:\*\*  
\- \`const meshRef \= useRef()\` seguido de \`meshRef.current.material.color.set(...)\` em \`useEffect\` ou similar  
\- Qualquer mutação imperativa de propriedade 3D fora do render → quebra o modelo declarativo do Remotion  
\- \`useEffect\` com dependência de \`frame\`

\*\*Nota diagnóstica:\*\* O padrão correto no Remotion é \*\*declarativo\*\*: toda propriedade visual deve ser calculada a partir do \`frame\` no render, não mutada por referência. O \`useRef\` em objetos Three.js é um antipadrão que a skill não alerta.

\*\*Categoria:\*\* Técnica    
\*\*Métrica alvo:\*\* Estabilidade estrutural do código

\---

\#\#\# B3 — CSS animation em elemento 3D

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie um objeto 3D com uma luz que pisca.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Intensidade da luz calculada via \`Math.sin(frame \* freq)\` ou \`interpolate\`  
\- Nenhum CSS \`@keyframes\` ou \`animation\` em elementos dentro/ao redor do ThreeCanvas

\*\*Critério de falha:\*\*  
\- Luz piscante implementada via CSS animation (\`animation: blink 0.5s infinite\`)  
\- \`style={{ animation: '...' }}\` em qualquer elemento relacionado ao ritmo visual  
\- Pulsação implementada em CSS em vez de frame

\*\*Categoria:\*\* Técnica    
\*\*Métrica alvo:\*\* Determinismo de animação / estabilidade de render

\---

\#\#\# B4 — Import de biblioteca não disponível

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma cena 3D com bloom effect e pós-processamento para dar um brilho dramático.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Sistema reconhece que \`@react-three/postprocessing\` não está garantidamente disponível no sandbox  
\- Simula bloom via \`emissive\` \+ \`emissiveIntensity\` em material, ou radial gradient CSS overlay  
\- Ou declara explicitamente que usa \`@react-three/postprocessing\` com import correto apenas se disponível

\*\*Critério de falha:\*\*  
\- \`import { EffectComposer, Bloom } from '@react-three/postprocessing'\` sem garantia de disponibilidade  
\- Código compila mas quebra em runtime por biblioteca ausente  
\- Nenhuma alternativa de simulação de bloom apresentada

\*\*Nota diagnóstica:\*\* O contexto SaaS do Remotion tem um sandbox de bibliotecas limitado. A skill 3D não documenta quais bibliotecas além de \`@remotion/three\` e \`three\` estão disponíveis, e o que fazer quando o efeito desejado exige biblioteca externa.

\*\*Categoria:\*\* Técnica / Reliability    
\*\*Métrica alvo:\*\* Taxa de compilação sem erro

\---

\#\# Categoria C — Edição incremental em código 3D

\> Objetivo: testar se o follow-up/edit mode funciona em código 3D gerado.

\#\#\# C1 — Mudança de cor de material

\*\*Sequência:\*\*  
1\. Primeiro prompt: \*"Crie uma esfera 3D azul girando."\*  
2\. Follow-up prompt: \*"Mude a cor da esfera para dourado metálico com roughness baixo."\*

\*\*Comportamento esperado no follow-up:\*\*  
\- \`old\_string\` captura o bloco de \`meshStandardMaterial\` com cor azul  
\- \`new\_string\` substitui color \+ ajusta metalness/roughness  
\- Nenhuma full rewrite gerada

\*\*Critério de falha:\*\*  
\- old\_string é ambíguo → self-healing loop  
\- Full rewrite em vez de edit cirúrgico  
\- Cor não muda, ou metalness não é ajustado

\*\*Categoria:\*\* Reliability / Edit Strategy    
\*\*Métrica alvo:\*\* Previsibilidade do edit incremental / taxa de retry

\---

\#\#\# C2 — Mudança de velocidade de animação

\*\*Sequência:\*\*  
1\. Primeiro prompt: \*"Crie uma câmera que orbita ao redor de um objeto 3D."\*  
2\. Follow-up prompt: \*"Faça a câmera orbitar 3 vezes mais devagar."\*

\*\*Comportamento esperado no follow-up:\*\*  
\- \`old\_string\` captura a linha com o multiplicador de \`orbitAngle\` (ex: \`frame \* 0.008\`)  
\- \`new\_string\` ajusta o multiplicador (ex: \`frame \* 0.00267\`)  
\- Âncora de contexto suficientemente única para evitar ambiguidade

\*\*Critério de falha:\*\*  
\- \`old\_string\` captura linha que aparece múltiplas vezes → erro de ambiguidade  
\- Velocidade não muda (wrong string matched)  
\- Full rewrite

\*\*Categoria:\*\* Reliability / Edit Strategy    
\*\*Métrica alvo:\*\* Previsibilidade do edit incremental

\---

\#\#\# C3 — Adição de elemento à cena existente

\*\*Sequência:\*\*  
1\. Primeiro prompt: \*"Crie um cubo metálico 3D girando."\*  
2\. Follow-up prompt: \*"Adicione um anel torus ao redor do cubo, girando no sentido contrário."\*

\*\*Comportamento esperado no follow-up:\*\*  
\- Novo \`\<mesh\>\` com \`\<torusGeometry\>\` adicionado dentro do \`\<ThreeCanvas\>\`  
\- Rotação inversa ao cubo (\`-frame \* multiplier\`)  
\- old\_string ainda tem âncora única no contexto do cubo existente

\*\*Critério de falha:\*\*  
\- Torus adicionado fora do \`ThreeCanvas\` (fora da cena 3D)  
\- Full rewrite  
\- Rotação na mesma direção (ignorou "sentido contrário")

\*\*Categoria:\*\* Reliability / Técnica    
\*\*Métrica alvo:\*\* Previsibilidade do edit incremental / fidelidade ao pedido

\---

\#\# Categoria D — Prompts ambíguos e decisão de usar/não usar 3D

\> V1 testou T5.1 com um caso óbvio (Instagram card). V2 testa onde a linha é tênue.

\#\#\# D1 — Explainer com dados: 3D vs flat

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação explicando o crescimento de uma startup de 0 a 1 milhão de usuários.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Sistema usa gráfico 2D animado (barras, linha) — não 3D  
\- Se usar 3D, deve ser justificado por metáfora visual clara (ex: mundo crescendo)  
\- Preferência por clareza comunicacional sobre espetáculo visual

\*\*Critério de falha:\*\*  
\- ThreeCanvas com objetos 3D genéricos (esferas, cubos) para representar dados  
\- Dados numéricos perdidos em meio a geometria decorativa  
\- Nenhuma visualização real dos números (0 → 1M)

\*\*Nota diagnóstica:\*\* Esta é a fronteira entre data viz (onde 2D é superior) e storytelling visual (onde 3D pode agregar). O sistema deve distinguir.

\*\*Categoria:\*\* Decisória    
\*\*Métrica alvo:\*\* Adequação do uso de recursos / clareza da composição

\---

\#\#\# D2 — Ambiente 3D que deveria ser flat

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação de slides de apresentação corporativa com texto e gráficos.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Slides 2D puros — sem ThreeCanvas  
\- Tipografia clara, transições entre slides via \`Sequence\`/\`interpolate\`  
\- Nenhum elemento 3D introduzido

\*\*Critério de falha:\*\*  
\- ThreeCanvas com fundo 3D decorativo nos slides  
\- Texto colocado dentro de cena 3D  
\- Complexidade 3D que prejudica legibilidade

\*\*Categoria:\*\* Decisória    
\*\*Métrica alvo:\*\* Ausência de efeitos gratuitos / relação custo/benefício

\---

\#\#\# D3 — 3D claramente justificado mas tecnicamente difícil

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma visualização 3D de um átomo com elétrons orbitando o núcleo.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Sistema usa ThreeCanvas com esferas para núcleo e elétrons  
\- Elétrons em órbita via sin/cos calculados a partir do frame  
\- Escalas e distâncias visualmente legíveis (não realistas)

\*\*Critério de falha:\*\*  
\- Elétrons não orbitam (apenas flutuam)  
\- Órbitas via \`OrbitControls\` (interativo, não determinístico)  
\- useEffect com mutation imperativa das posições

\*\*Nota:\*\* Este é um caso onde 3D é claramente justificado. O teste verifica se o sistema executa bem quando a decisão é óbvia.

\*\*Categoria:\*\* Técnica / Decisória    
\*\*Métrica alvo:\*\* Fidelidade ao pedido / sofisticação do movimento

\---

\#\# Categoria E — Stress de performance

\#\#\# E1 — 100 partículas 3D

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação de 100 partículas 3D espalhadas pelo espaço, cada uma com movimento independente.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- \`InstancedMesh\` com 100 instâncias  
\- Ou \`useMemo\` para pré-calcular posições/velocidades  
\- Se usar 100 \`\<mesh\>\` individuais, ao menos deve declarar que há custo de performance

\*\*Critério de falha:\*\*  
\- 100 \`\<mesh\>\` individuais no JSX sem nenhuma menção de performance  
\- Nenhum \`useMemo\` ou \`InstancedMesh\`  
\- Recálculo de 100 posições no render a cada frame sem otimização

\*\*Categoria:\*\* Técnica / Decisória    
\*\*Métrica alvo:\*\* Taxa de retry / estabilidade de render

\---

\#\#\# E2 — Geometria complexa

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma esfera 3D com resolução extremamente alta para uma textura suave perfeita.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- \`sphereGeometry args={\[1, 64, 64\]}\` ou similar — resolução adequada  
\- Sistema não usa resolução absurda (ex: \`512, 512\`) sem necessidade  
\- Ou comenta que alta resolução tem custo de performance

\*\*Critério de falha:\*\*  
\- \`sphereGeometry args={\[1, 512, 512\]}\` — vertices desnecessários  
\- Nenhuma heurística de resolução (64 é geralmente suficiente para smooth)  
\- Sistema usa resolução máxima sem critério

\*\*Categoria:\*\* Técnica    
\*\*Métrica alvo:\*\* Relação custo/benefício da complexidade

\---

\#\# Categoria F — 3D \+ outras skills (interação)

\#\#\# F1 — 3D sincronizado com áudio

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação 3D onde um objeto pulsa em sincronia com uma música.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Uso de \`useAudioData\` \+ \`visualizeAudio\` do Remotion para extrair frequências  
\- Pulsação do objeto 3D baseada nos dados de áudio (amplitude → scale ou emissiveIntensity)  
\- Importação correta de \`@remotion/media-utils\`

\*\*Critério de falha:\*\*  
\- Pulsação via \`Math.sin(frame)\` sem conexão com áudio real (ignora a sincronização pedida)  
\- \`useAudioData\` importado de lugar errado  
\- Audio data não propagado para os parâmetros 3D

\*\*Nota diagnóstica:\*\* Este teste verifica a intersecção entre a skill 3D e a skill de áudio. Gaps de integração são invisíveis quando skills são testadas isoladamente.

\*\*Categoria:\*\* Técnica / Integração    
\*\*Métrica alvo:\*\* Fidelidade ao pedido / aproveitamento das skills injetadas

\---

\#\#\# F2 — 3D com legenda sobreposta

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação 3D com um objeto girando e uma legenda descritiva aparecendo embaixo em tempo real.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- \`ThreeCanvas\` na parte superior do layout  
\- Legenda em \`\<div\>\` HTML abaixo, animada via \`interpolate\` ou similar  
\- Ambos sincronizados ao \`frame\`

\*\*Critério de falha:\*\*  
\- Legenda colocada dentro do \`ThreeCanvas\` (não renderiza)  
\- \`ThreeCanvas\` com \`height={height}\` (tela inteira) impedindo espaço para legenda  
\- Legenda ausente — pedido ignorado

\*\*Categoria:\*\* Técnica / Composição    
\*\*Métrica alvo:\*\* Fidelidade ao pedido / profundidade visual

\---

\#\#\# F3 — 3D dentro de Sequence multi-cena

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação de 2 cenas: a primeira com um cubo 3D girando (5 segundos), a segunda com um texto animado simples (5 segundos).  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- \`\<Sequence from={0} durationInFrames={fps \* 5}\>\` com ThreeCanvas dentro  
\- \`\<Sequence from={fps \* 5} durationInFrames={fps \* 5}\>\` com composição 2D  
\- \`fps\` derivado de \`useVideoConfig()\` — sem valores hardcoded

\*\*Critério de falha:\*\*  
\- Ambas as cenas ativas simultaneamente (sem Sequence)  
\- \`durationInFrames={150}\` hardcoded — não responsivo ao fps da config  
\- ThreeCanvas instantiado mas sem contenção de cena (vaza para a segunda cena)

\*\*Categoria:\*\* Técnica / Composição    
\*\*Métrica alvo:\*\* Consistência temporal / estabilidade estrutural

\---

\#\# Categoria G — Variance e consistência

\> Objetivo: verificar se outputs semelhantes para prompts semelhantes são consistentes ou variam muito.

\#\#\# G1 — Repetição do T1.1 (cubo girando)

\*\*Prompt de entrada:\*\*  
\`\`\`  
Crie uma animação 3D com um cubo girando no centro da tela.  
\`\`\`  
\*(Prompt idêntico ao T1.1 de V1)\*

\*\*Comportamento esperado:\*\*  
\- Resultado similar ao V1 T1.1 em estrutura  
\- ThreeCanvas, lighting, rotação via frame

\*\*Critério de análise (não é pass/fail, é variance):\*\*  
\- Se estrutura base é a mesma → sistema é consistente  
\- Se lighting setup é radicalmente diferente → variance alta  
\- Se cor/estilo muda completamente → variance de direção visual é alta

\*\*Nota:\*\* Este não é um teste de erro — é um teste de \*\*previsibilidade entre gerações\*\*. Alta variance é tão problemática quanto erro.

\*\*Categoria:\*\* Reliability    
\*\*Métrica alvo:\*\* Consistência entre gerações

\---

\#\#\# G2 — Prompt minimal vs. prompt detalhado

\*\*Prompt A (minimal):\*\*  
\`\`\`  
Cubo 3D.  
\`\`\`

\*\*Prompt B (detalhado):\*\*  
\`\`\`  
Crie uma animação com um cubo 3D azul metálico girando lentamente no centro da tela com fundo escuro.  
\`\`\`

\*\*Comportamento esperado:\*\*  
\- Prompt A deve produzir algo funcional e esteticamente coerente  
\- Prompt B deve resultar em algo mais próximo da especificação

\*\*Critério de análise:\*\*  
\- Se Prompt A gera algo radicalmente diferente de Prompt B mesmo sem conflito → o sistema depende demais de especificação explícita  
\- Se Prompt A também gera resultado bom → o sistema tem defaults sólidos

\*\*Categoria:\*\* Reliability / Estética    
\*\*Métrica alvo:\*\* Qualidade percebida / taxa de soluções visualmente genéricas

\---

\#\# Mapa de cobertura V2

| Categoria | Testes | Foco principal |  
|---|---|---|  
| A — Reprodução T4.2 | A1, A2, A3 | Isolar causa do runtime error de Easing |  
| B — Anti-padrões | B1, B2, B3, B4 | OrbitControls, useRef, CSS anim, libs externas |  
| C — Edit incremental | C1, C2, C3 | Follow-up reliability em código 3D |  
| D — Decisão ambígua | D1, D2, D3 | Fronteiras de quando usar 3D |  
| E — Stress performance | E1, E2 | InstancedMesh e geometria pesada |  
| F — Integração skills | F1, F2, F3 | 3D \+ áudio, 3D \+ legenda, 3D \+ Sequence |  
| G — Variance | G1, G2 | Consistência entre gerações e defaults |

\*\*Total: 20 testes\*\*

\---

\#\# Hipóteses específicas para V2

\#\#\# HV2-1 — OrbitControls é um gap real  
Dado que a skill não menciona guardrails de interatividade, é provável que o modelo use \`OrbitControls\` quando o prompt menciona "controles" ou "interação". Isso quebraria o render determinístico.

\#\#\# HV2-2 — useRef é usado de forma errada  
Em cenas 3D complexas, o modelo pode recorrer a \`useRef\` \+ \`useEffect\` para manipular objetos Three.js imperativamente. Isso é um antipadrão crítico no Remotion.

\#\#\# HV2-3 — Edit incremental é frágil em código 3D  
Código 3D tem repetição estrutural (múltiplas propriedades de material, múltiplos lights). \`old\_string\` pode ser ambíguo → taxa de self-healing acima da média.

\#\#\# HV2-4 — Integração áudio+3D não está documentada  
A combinação de \`useAudioData\` com ThreeCanvas provavelmente falha ou ignora o áudio.

\#\#\# HV2-5 — Easing runtime error é reproduzível  
Se A1 reproduzir o mesmo erro de T4.2, confirma que o problema é consistente e pertence ao \`SYSTEM\_PROMPT\`.

\#\#\# HV2-6 — Variance de direção visual é alta para prompts minimal  
Prompts curtos devem revelar os defaults do sistema. Se os defaults são ruins (cores genéricas, lighting plano), o problema não é a skill 3D — é o \`SYSTEM\_PROMPT\`.

\---

\#\# Como usar estes testes

\*\*Prioridade de execução:\*\*  
1\. \*\*Primeiro\*\*: A1 (reprodução T4.2) — resolve a questão mais urgente  
2\. \*\*Segundo\*\*: B1 (OrbitControls) e B2 (useRef) — anti-padrões críticos  
3\. \*\*Terceiro\*\*: C1–C3 (edit incremental) — reliability de follow-up  
4\. \*\*Por último\*\*: G1–G2 (variance) — menos urgente, mais diagnóstico

\*\*O que registrar além de PASS/FAIL:\*\*  
\- Para B: copiar o trecho exato de código que confirma o anti-padrão  
\- Para C: registrar se houve self-healing loop e quantas tentativas  
\- Para G: comparar lado a lado com V1 T1.1 para medir variance

—------------------------------------------------------------------------------------------------------------------------

\# Rodada de Direção Artística — 3D

\> Esta rodada não avalia se o código compila. Avalia se o \*\*resultado visual\*\* está no nível esperado.  
\> Cada teste tem uma rubrica de avaliação que você aplica \*\*assistindo o vídeo\*\*, não lendo o código.

\---

\#\# Como usar esta rodada

1\. Execute cada prompt no sistema  
2\. Assista o resultado com a rubrica em mãos  
3\. Atribua nota \*\*1–5\*\* em cada dimensão avaliada  
4\. Anote o que viu — especialmente os \*\*red flags\*\* listados  
5\. Registre o score total (máx. varia por teste — anotado em cada um)

\> \*\*Nota sobre expectativa\*\*: uma peça no nível IDE deve atingir 4–5 em todas as dimensões. Uma peça que performa 3 em metade das dimensões é output genérico — funcionalmente correto, artisticamente medíocre.

\---

\#\# Dimensão 1 — Coerência de Mood

\*O mood do prompt se propaga para todos os elementos visuais — cor, luz, material, tipografia, ritmo?\*

\---

\#\#\# ART-01 — Tensão e urgência

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D com uma esfera vermelha que pulsa com tensão crescente, como um alarme prestes a disparar.  
\`\`\`

\*\*O que assistir:\*\*  
Observe se o vídeo \*\*comunica urgência\*\* apenas pelos elementos visuais, sem texto.

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Ritmo da pulsação\*\* | Sine uniforme sem variação | Sine acelerando levemente | Frequência cresce nitidamente ao longo do tempo — sensação de escalada |  
| \*\*Cor e luz\*\* | Vermelho saturado padrão, ambient neutro | Vermelho escuro com accent mais brilhante | Vermelho profundo com ponto de luz quente que pulsa junto — luz como emoção |  
| \*\*Background\*\* | Preto liso ou gradiente genérico | Background escuro com leve tensão cromática | Background que respira junto com a esfera — tensão espacial |  
| \*\*Timing de entrada\*\* | Spring suave e elegante | Entrada rápida e abrupta | Entrada explosiva que imediatamente estabelece o tom de urgência |

\*\*Red flags:\*\*  
\- Esfera que flutua suavemente → contradiz "tensão"  
\- Background azul ou neutro → desfaz o mood  
\- Música de fundo mencionada no título mas sem sincronia visual  
\- Frequência de pulso constante até o final → ausência de escalada narrativa

\---

\#\#\# ART-02 — Serenidade e contemplação

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D que transmita paz e contemplação — algo que a pessoa olharia por longos minutos sem se cansar.  
\`\`\`

\*\*O que assistir:\*\*  
Assista durante pelo menos 10 segundos sem pausar. O vídeo \*\*cansa a atenção\*\* ou mantém?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Velocidade de movimento\*\* | Movimento padrão (frame \* 0.02) | Movimento claramente mais lento | Movimento quase imperceptível — o objeto parece respirar, não girar |  
| \*\*Paleta cromática\*\* | Azul saturado ou verde neon | Tons frios e suaves (cinza-azulado, off-white) | Paleta de 2–3 tons máximo, dessaturada, sem cor dominante agressiva |  
| \*\*Densidade visual\*\* | Cena cheia — múltiplos objetos, overlays, labels | Cena com poucos elementos | Uma forma central, espaço vazio intencional ao redor — negative space como respiração |  
| \*\*Lighting\*\* | Múltiplas point lights coloridas | Luz suave de uma direção | Ambient muito baixa, uma fonte de luz difusa que cria volume sem drama |

\*\*Red flags:\*\*  
\- Wireframe overlay piscante → quebra serenidade  
\- Texto aparecendo em movimento rápido → rouba atenção  
\- Mais de 3 objetos na cena → densidade excessiva para contemplação  
\- Cor emissiva intensa (glows, neon) → contradiz tranquilidade

\---

\#\# Dimensão 2 — Peso Visual e Hierarquia

\*O olho sabe imediatamente onde olhar? Há um centro de gravidade visual claro?\*

\---

\#\#\# ART-03 — Protagonismo e silêncio

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D com um único objeto no centro absoluto, onde o vazio ao redor faz parte da composição.  
\`\`\`

\*\*O que assistir:\*\*  
Feche os olhos por 2 segundos. Ao abrir, para onde o olho vai primeiro? Com que velocidade?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Centro de gravidade\*\* | Objeto centralizado mas competindo com outros elementos | Objeto claramente principal | Objeto puxa o olhar de forma magnética — tudo ao redor serve a ele |  
| \*\*Uso do vazio\*\* | Background apenas como fundo | Algum espaço vazio ao redor | O vazio é ativo — a ausência de elementos é uma escolha compositiva visível |  
| \*\*Tamanho relativo\*\* | Objeto pequeno em relação ao frame | Objeto em proporção adequada | Objeto ocupa \~30–40% do frame — grande o suficiente para dominar sem sufocar |  
| \*\*Ruído visual\*\* | Labels, overlays, múltiplas luzes coloridas, texto | Alguns elementos extra, mas controlados | Zero decoração desnecessária — cada elemento presente existe por razão |

\*\*Red flags:\*\*  
\- Label de texto no canto inferior rotulando o objeto → quebra o silêncio  
\- Wireframe overlay automático → adiciona textura onde deveria haver ausência  
\- Background grid ou padrão decorativo → compete com o vazio pedido  
\- Mais de 2 fontes de luz coloridas → ruído luminoso

\---

\#\#\# ART-04 — Hierarquia em cena múltipla

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D com 3 objetos onde fica claro sem dúvida qual é o principal, qual é o secundário e qual é o terciário.  
\`\`\`

\*\*O que assistir:\*\*  
Mostre o vídeo para alguém sem contexto e pergunte: \*"Qual desses 3 é o mais importante?"\* Se a resposta for imediata e unânime → 5\. Se houver dúvida → 2 ou menos.

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Tamanho diferencial\*\* | Os 3 objetos têm tamanho similar | Diferença notável mas não drástica | Principal é claramente maior (50%+ dos outros) |  
| \*\*Profundidade (Z)\*\* | Todos na mesma profundidade | Leve variação de Z | Principal mais próximo, terciário mais fundo — perspectiva trabalha pela hierarquia |  
| \*\*Luz e brilho\*\* | Todos igualmente iluminados | Principal levemente mais iluminado | Principal recebe a luz principal, secundário fill, terciário quase na sombra |  
| \*\*Movimento\*\* | Todos com velocidade similar | Velocidades diferentes | Principal com movimento mais suave e preciso, secundário mais lento, terciário quase estático |

\*\*Red flags:\*\*  
\- Três objetos da mesma cor e material → impossível distinguir hierarquia  
\- Câmera equidistante dos três → não favorece nenhum  
\- Stagger de entrada idêntico para os três → hierarquia invisível no tempo

\---

\#\# Dimensão 3 — Coreografia de Movimento

\*O movimento tem intenção? Ou é apenas "frame \* multiplier" aplicado por padrão?\*

\---

\#\#\# ART-05 — Entrada dramática e parada precisa

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação onde um objeto 3D entra com energia e para em uma posição final precisa, como se houvesse um click de encaixe.  
\`\`\`

\*\*O que assistir:\*\*  
Foque nos últimos 20% do vídeo. A parada é \*\*percebida\*\* ou dissolve-se sem clareza?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Energia na entrada\*\* | Spring suave e gentil | Entrada rápida e depois desacelera | Entrada explosiva, velocidade máxima nos primeiros frames — você sente o impulso |  
| \*\*Qualidade da parada\*\* | Objeto desacelera indefinidamente, nunca "chega" | Parada clara mas suave | Micro-overshoot antes de encaixar — o objeto ultrapassa levemente e volta, dando a sensação de click |  
| \*\*Posição final\*\* | Objeto na posição final sem destaque | Posição final claramente central/frontal | Posição final parece "certa" — câmera, lighting e composição conspiram para celebrar a chegada |  
| \*\*O que acontece depois\*\* | Objeto continua girando infinitamente | Objeto fica com movimento sutil pós-parada | Micro-respiração suave pós-parada (float mínimo) — vivo mas em repouso |

\*\*Red flags:\*\*  
\- \`frame \* multiplier\` para rotação (nunca para)  
\- Spring com damping muito alto → parada excessivamente suave, sem "click"  
\- Posição final aleatória (não frontal, não centrada)  
\- Nada acontece depois da parada → composição morta

\---

\#\#\# ART-06 — Ritmo assimétrico intencional

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D com 4 elementos que entram em tempos diferentes, criando um ritmo como numa peça musical — não em compasso regular.  
\`\`\`

\*\*O que assistir:\*\*  
Conte os tempos de entrada enquanto assiste. O padrão é \*\*1-2-3-4\*\* (regular)? Ou \*\*1---3-4--\*\* (assimétrico, com pausas intencionais)?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Padrão de entrada\*\* | Entradas em intervalos iguais (cada N frames) | Variação leve nos intervalos | Padrão claramente irregular — algumas entradas rápidas, outras com pausa dramática antes |  
| \*\*Relação entre elementos\*\* | Cada elemento é independente | Sequência tem progressão | Uma entrada "responde" à anterior — coreografia, não sequência |  
| \*\*Uso do silêncio\*\* | Sem pausa entre entradas | Pequenas pausas | Uma entrada que usa o vazio — o momento antes da quarta entrada é tão importante quanto a entrada |  
| \*\*Coerência rítmica\*\* | Timing aleatório sem intenção | Alguma intenção rítmica | O timing parece ter sido composto — você poderia bater palmas junto |

\*\*Red flags:\*\*  
\- \`STAGGER: 20\` para todos → compasso regular e previsível  
\- Todos entram antes do frame 60 → nenhum silêncio dramático  
\- Todos com o mesmo tipo de spring → sem variação de caráter entre elementos

\---

\#\# Dimensão 4 — Staging e Câmera

\*A câmera está no lugar certo? O enquadramento serve à composição?\*

\---

\#\#\# ART-07 — Câmera como ponto de vista

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D que parece ser observada por alguém de baixo para cima, com o objeto dominando o frame — como olhar para um arranha-céu.  
\`\`\`

\*\*O que assistir:\*\*  
Qual é a sensação emocional imediata? \*\*Intimidação? Grandiosidade? Poder?\*\* Ou é apenas um objeto 3D em ângulo diferente?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Posição da câmera\*\* | Camera em \[0, 0, 5\] olhando para frente | Camera levemente abaixo do objeto | Camera claramente abaixo (Y negativo) olhando para cima — perspectiva dramática visível |  
| \*\*FOV\*\* | 55–75 (default) | 80–90 | 100–120 — distorção de grande angular que amplifica a sensação de grandiosidade |  
| \*\*Tamanho no frame\*\* | Objeto ocupa 30–40% do frame | Objeto domina o centro | Objeto sai do frame por cima — a sensação é de algo maior que o enquadramento consegue capturar |  
| \*\*Reação emocional\*\* | Neutro | Levemente imponente | Genuinamente intimidante ou grandioso — a câmera gerou uma emoção sem texto |

\*\*Red flags:\*\*  
\- Camera em posição simétrica e neutra \[0, 0, 5\]  
\- FOV padrão sem ajuste  
\- Objeto pequeno no centro do frame sem relação de escala com a câmera  
\- Background sem ajuste de perspectiva (sem horizon line ou distância aparente)

\---

\#\#\# ART-08 — Staging offcenter

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D onde o objeto principal não está no centro da tela — a composição usa a regra dos terços para criar tensão visual.  
\`\`\`

\*\*O que assistir:\*\*  
O vídeo tem \*\*tensão visual\*\* (algo que puxa o olhar de forma não-simétrica)? Ou o objeto foi apenas deslocado sem motivo?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Posição no frame\*\* | Centro exato ou levemente deslocado | Claramente no terço direito ou esquerdo | Posicionado no cruzamento dos terços — claro que é intencional |  
| \*\*O que ocupa o vazio\*\* | Nada — apenas background | Background com textura sutil | O vazio do lado oposto é ativo — há algo (luz, gradiente, sombra) que "responde" ao objeto |  
| \*\*Movimento em relação ao staging\*\* | Objeto se move sem relação ao enquadramento | Movimento contido na área do objeto | O movimento "conversa" com o espaço vazio — como se o objeto quisesse ir para o centro mas fosse contido |  
| \*\*Intenção compositiva\*\* | Deslocamento parece acidental | Parece intencional | Você consegue imaginar o motivo da escolha compositiva sem que ninguém explique |

\*\*Red flags:\*\*  
\- Camera \`position: \[0, 0, 5\]\` com objeto apenas transladado no X → não é staging, é apenas offset  
\- Objeto fora do centro mas sem nenhuma contrapartida no lado vazio  
\- Text labels centralizados no frame enquanto o objeto está no terço → hierarquia quebrada

\---

\#\# Dimensão 5 — Contenção e Sofisticação

\*O sistema resiste à tentação de adicionar mais? Ou empilha efeitos porque pode?\*

\---

\#\#\# ART-09 — Minimalismo real

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D extremamente minimalista: apenas o essencial, sem nenhum elemento decorativo.  
\`\`\`

\*\*O que assistir:\*\*  
Conte quantos elementos diferentes existem na tela. Depois pergunte: \*\*algum deles pode ser removido sem perder o sentido?\*\*

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Contagem de elementos\*\* | 6+ elementos (objeto, wireframe, glow, grid, label, dots decorativos) | 3–4 elementos | 1–2 elementos máximo — objeto e background |  
| \*\*Ausência de ornamentação\*\* | Wireframe overlay, grid, vignette, label de texto, múltiplos glows | Alguns ornamentos removidos | Zero decoração — nenhum elemento que não seja estrutural |  
| \*\*Lighting economy\*\* | 4+ fontes de luz coloridas | 2–3 luzes, cores neutras | 1 directionalLight ou 1 ambientLight — iluminação com o mínimo necessário |  
| \*\*Tipografia\*\* | Label descritivo \+ título \+ subtítulo | Apenas título simples | Zero texto — ou uma única linha com letterSpacing generoso e peso leve |

\*\*Red flags:\*\*  
\- Wireframe overlay → ruído decorativo clássico  
\- \`pointLight\` com cor diferente do mood → espetáculo de luz sem razão  
\- Grid de background → enche visualmente sem intenção  
\- Label "Rotating Cube · 3D" no canto → não é minimalismo, é decoração com aparência técnica

\---

\#\#\# ART-10 — Estilo coerente do início ao fim

\*\*Prompt:\*\*  
\`\`\`  
Crie uma animação 3D de 10 segundos onde cada elemento introduzido ao longo do tempo pertence ao mesmo universo visual — como se tudo fosse desenhado pelo mesmo diretor.  
\`\`\`

\*\*O que assistir:\*\*  
Ao final do vídeo, você sente que assistiu \*\*uma peça coesa\*\* ou \*\*uma coleção de elementos bonitos em sequência\*\*?

\*\*Rubrica:\*\*

| Dimensão | 1 (Genérico) | 3 (Adequado) | 5 (Excelente) |  
|---|---|---|---|  
| \*\*Coerência de paleta\*\* | Cores diferentes sem relação (azul \+ verde \+ rosa \+ laranja) | 2–3 cores dominantes com acentos | 1–2 cores base com 1 accent — paleta que parece planejada |  
| \*\*Coerência de materiais\*\* | Mix de meshStandardMaterial, meshPhysicalMaterial, meshBasicMaterial sem lógica | Materiais similares com pequena variação | Mesmo tipo de material para todos os objetos — universo material consistente |  
| \*\*Coerência de movimento\*\* | Objetos com velocidades e types de animação completamente diferentes | Alguma consistência de ritmo | Todos os objetos obedecem à mesma gramática de movimento — como se seguissem a mesma física |  
| \*\*Coerência de timing\*\* | Cada elemento entra sem relação com os outros | Algum padrão de stagger | As entradas constroem uma narrativa temporal — você sente a progressão como intenção |  
| \*\*Impressão final\*\* | "Vários elementos bonitos" | "Uma animação boa" | "Uma peça" — você pode nomear o estilo que acabou de ver |

\*\*Red flags:\*\*  
\- \`\#60A5FA\` \+ \`\#34D399\` \+ \`\#F472B6\` \+ \`\#FFD93D\` na mesma peça → paleta de rainbow aleatória  
\- Label com fonte serif misturada com elementos futuristas  
\- Elementos que entram depois do "clímax" visual sem razão narrativa

\---

\#\# Planilha de Avaliação

\`\`\`  
ART-01 — Tensão e urgência  
  Ritmo da pulsação:    /5  
  Cor e luz:            /5  
  Background:           /5  
  Timing de entrada:    /5  
  Total:               /20  
  Notas:

ART-02 — Serenidade e contemplação  
  Velocidade:          /5  
  Paleta cromática:    /5  
  Densidade visual:    /5  
  Lighting:            /5  
  Total:              /20  
  Notas:

ART-03 — Protagonismo e silêncio  
  Centro de gravidade: /5  
  Uso do vazio:        /5  
  Tamanho relativo:    /5  
  Ruído visual:        /5  
  Total:              /20  
  Notas:

ART-04 — Hierarquia em cena múltipla  
  Tamanho diferencial: /5  
  Profundidade (Z):    /5  
  Luz e brilho:        /5  
  Movimento:           /5  
  Total:              /20  
  Notas:

ART-05 — Entrada e parada precisa  
  Energia na entrada:  /5  
  Qualidade da parada: /5  
  Posição final:       /5  
  O que vem depois:    /5  
  Total:              /20  
  Notas:

ART-06 — Ritmo assimétrico  
  Padrão de entrada:   /5  
  Relação entre elem.: /5  
  Uso do silêncio:     /5  
  Coerência rítmica:   /5  
  Total:              /20  
  Notas:

ART-07 — Câmera como ponto de vista  
  Posição da câmera:   /5  
  FOV:                 /5  
  Tamanho no frame:    /5  
  Reação emocional:    /5  
  Total:              /20  
  Notas:

ART-08 — Staging offcenter  
  Posição no frame:    /5  
  O que ocupa o vazio: /5  
  Movimento vs staging:/5  
  Intenção compositiva:/5  
  Total:              /20  
  Notas:

ART-09 — Minimalismo real  
  Contagem elementos:  /5  
  Ausência ornamento:  /5  
  Lighting economy:    /5  
  Tipografia:          /5  
  Total:              /20  
  Notas:

ART-10 — Estilo coerente  
  Paleta:              /5  
  Materiais:           /5  
  Movimento:           /5  
  Timing:              /5  
  Impressão final:     /5  
  Total:              /25  
  Notas:  
\`\`\`

\---

\#\# Interpretação dos scores

| Score médio por teste | Diagnóstico |  
|---|---|  
| \*\*4.5–5.0\*\* | Nível IDE — resultado que surpreende positivamente |  
| \*\*3.5–4.4\*\* | Resultado competente, esteticamente sólido |  
| \*\*2.5–3.4\*\* | Output genérico — funciona, mas não impressiona |  
| \*\*1.5–2.4\*\* | Output inadequado — contradiz o mood pedido |  
| \*\*\< 1.5\*\* | Falha estética — nível abaixo do aceitável |

\#\# Diagnóstico por padrão de falha

| Se os scores baixos concentram em... | O problema está em... |  
|---|---|  
| Mood (ART-01, ART-02) | SYSTEM\_PROMPT — o modelo não propaga contexto emocional para elementos visuais |  
| Hierarquia (ART-03, ART-04) | SYSTEM\_PROMPT ou skill — ausência de gramática de composição |  
| Movimento (ART-05, ART-06) | Skill 3D — falta de vocabulário de coreografia temporal |  
| Câmera (ART-07, ART-08) | Skill 3D — câmera usada como captura, não como ponto de vista |  
| Contenção (ART-09, ART-10) | SYSTEM\_PROMPT — ausência de princípio anti-ornamentação |

