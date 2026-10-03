# Próximos passos — One Prompt (JOPv2)

Estado em 30/09/2026, fim do dia. Guia para retomar a implementação numa conversa nova.

**Leia antes:** [HANDOFF.md](HANDOFF.md) (contexto completo das Fases 0–2, arquitetura, decisões e regras) e o PRD citado no topo dele. Este documento **complementa** o handoff: registra o que mudou depois dele e define a ordem do trabalho daqui para frente. Onde os dois divergirem, vale este.

---

## 1. Onde estamos

O pipeline roda de ponta a ponta com vídeo real: briefing no chat → spec validada → preview no player → aprovação → MP4 renderizado. Isso foi confirmado pelo Guilherme no navegador em 30/09.

Nada está commitado. Não faça commit sem pedido.

### O que foi feito nesta sessão (depois do HANDOFF)

| Mudança | Arquivo |
|---|---|
| Segredo HMAC gerado e configurado nos dois lados (mesmo valor, conferido por hash) | `.env` (`REMOTION_SHARED_SECRET`), `template-remotion/.env.local` (`JOP_SHARED_SECRET` + `OPENAI_API_KEY`) |
| **Bug corrigido:** quando a spec ficava pronta, o painel de preview existia duas vezes na página (fim do chat + dropdown do cabeçalho). O preview gerado ia para a cópia escondida e o botão de ver o vídeo nunca aparecia. Agora o painel vive só no dropdown do cabeçalho, igual ao que a página monta ao recarregar | `app/controllers/chat_controller.rb` (`turbo_stream.remove_all("#video_preview_panel")`) |
| **Bug corrigido:** falha no render final jogava a conversa em `error`, e o "Try again" desse estado **regerava o vídeo do zero** (tokens gastos, código aprovado descartado). Agora a conversa fica em `previewing` e tentar de novo = clicar em Approve & Render de novo, com o mesmo código | `app/controllers/video_controller.rb` (rescue do `approve`) |
| **Bug corrigido:** a mensagem de erro era enviada ao painel mas nunca exibida | `app/views/chat/_video_preview.html.haml` (bloco `local_assigns[:error]` no estado `previewing`) |

### Baseline parcial (2 vídeos)

| Conversa | Modo | Spec | Gerador | Render |
|---|---|---|---|---|
| 3 | minimalista | **rejeitada 2×** — legendas de 5–6 palavras (limite 4); caiu em `normalize_video_spec`, só `fps` sobreviveu, preview gerado a partir da prosa | 1 tentativa, `interpolate-clamp` (warning) | não aprovado |
| 4 | minimalista | **válida de primeira**; spec canônica enviada ao Node | 3 gerações, todas 1 tentativa, `interpolate-clamp` (warning) | falhou por ambiente (ver §2), depois **funcionou** |

Tempo de geração do preview: 2,5–3,5 min por vídeo.

---

## 2. Como subir o ambiente

```bash
# 1. Docker Desktop ligado. Depois, em JOPv2/:
docker compose -p jop --env-file .env --env-file .env.local up -d --build

# 2. Node — SEMPRE num terminal do próprio Guilherme, nunca em background do agente
cd template-remotion
npm run dev          # ou: npm run dev > node.log 2>&1  (para o agente ler o log depois)
```

- **Por que o Node não pode rodar em background do agente:** o background do Claude Code tem limite de 2 h. Ao atingir o limite, o processo principal do Next sobreviveu na porta 3001, mas todo processo filho novo (workers de compilação do Next, serviço do esbuild do Remotion) passou a morrer ao nascer. Sintomas: player com tela preta / `Jest worker encountered 2 child process exceptions` e render com `The service was stopped: write EPIPE`. Enquanto isso a rota de preview seguia respondendo 200, o que mascara o problema.
- Se aparecer um desses dois erros: encerrar a árvore de processos do Next (`taskkill /PID <pid-do-cmd-pai> /T /F`, ou fechar o terminal) e subir de novo. Os previews já gerados sobrevivem ao restart (ficam em `public/tmp/{token}.tsx`).
- Memória da máquina é apertada (0,6 GB livres de 15,7 GB com Docker + VS Code + Chrome). Render de MP4 é o momento mais pesado.
- Preview abre pelo botão **Preview** do cabeçalho do chat (dropdown), não mais no fim da conversa.

Checagem rápida: `curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/` e o mesmo para `:3001/`.

---

## 3. Decisões pendentes

| # | Decisão | Recomendação | Quando precisa |
|---|---|---|---|
| A | ✅ **DECIDIDO E APLICADO (30/09): manter o limite de 4.** Diagnóstico real: a regra já existia (linha ~289) e o agente a citava, mas **contava errado** (artigos/preposições). Aplicado: contagem explícita com exemplos no Passo 5 + checagem das legendas trazidas pelo usuário; `VideoSpec#caption_too_long?`; `repair_invalid_spec` autoriza encurtar legenda só quando esse é o erro. Backup: `config/initializers/openai_agents.rb.bak-decisaoA`. Texto original abaixo. — **Limite de 4 palavras por legenda no modo minimalista.** Hoje a regra só aparece no bloco do contrato JSON (`openai_agents.rb` ~linha 1269). No Passo 5, onde o agente escreve as legendas com o usuário, não há limite — o usuário aprova 6 palavras e a validação rejeita depois. O pedido de correção (`repair_invalid_spec`) ainda diz "não mude as decisões já acordadas", o que contradiz encurtar a legenda | **Manter o limite**, adicionar a regra no Passo 5 (linha ~263) e ajustar o texto de `repair_invalid_spec` para permitir encurtar legenda. Alternativa: aceitar mais palavras e estender a tabela de TIMING — o minimalista vira quase o dinâmico | Antes de continuar o baseline |
| B | Decisões 1 e 3 do HANDOFF (componentes como biblioteca; um agente só com lettering por `mode`) | Ver HANDOFF §4 | Antes da Fase 3, item 4 / Fase 4 |
| C | `.env` rastreado pelo git (chave OpenAI, Stripe) | `git rm --cached .env` antes de qualquer push. Guilherme pediu para **não mexer** por enquanto | Antes de qualquer push |
| D | Histórico de edições do vídeo (ver §4, Passo 3): coluna nova `video_edits jsonb` (migration) × guardar dentro de `video_spec` | Coluna nova — é dado de outra natureza e vira telemetria | Ao implementar o Passo 3 |

---

## 3b. Atualização 01/10/2026 — nova ordem (aprovada pelo Guilherme)

Baseline (6 conversas): gerador acertou de primeira em 100% (só `interpolate-clamp`); spec válida de primeira em 3/5; conv. 8 caiu no fallback de prosa (regra de `visual_category` repetida). Feedback do Guilherme: tudo funciona; o gargalo é a **qualidade do movimento** (transição entre cenas, lettering, linhas, pontilhismo, rabisco/sublinhado/tachado). Auditoria do código gerado: `evolvePath`, `@remotion/shapes` e `TransitionSeries` com **0 usos**; o prompt do gerador proíbe loops de partículas (mata pontilhismo); morph do Modo A sem suporte nenhum.

**Decisão 1 do HANDOFF confirmada: componentes como biblioteca.** Nova ordem: (1) biblioteca de movimento → (2) ensinar os dois agentes → (3) edição por conversa (o antigo Passo 3).

**(1) FEITO:** `template-remotion/src/remotion/design-system/` — `MorphContainer`/`useMorph`, `SceneTransition` (com `distance="full"` = empurrão contínuo; exige sobrepor os `Sequence` em `exitFrames`), `Stagger`, `StaggerText`, `Underline`, `Strike`, `Scribble`, `CircleAround`, `Highlighter`, `DotField`, `LineField`, `GridReveal`. Registro único em `design-system/index.ts`; `compiler.ts` injeta tudo (e pula nomes que o código gerado já declara). Painel `localhost:3001/motion-lab` compila cada demo pelo mesmo `compileCode`. Verificado: tsc limpo, lint das demos ok, quadros renderizados pelo bundle do render final e inspecionados.

**(2) FEITO (código), NÃO VALIDADO com geração real** — as duas chaves OpenAI (Rails `.env` e Node `.env.local`, valores diferentes) estão com `credit_balance_exhausted`:
- Spec: `accent {type, word}` e `texture` opcionais por momento — `VideoSpec::ACCENT_TYPES/TEXTURES` (Ruby, valida que `word` está na legenda) e Zod. Passam para a spec canônica.
- Agente A (backup `openai_agents.rb.bak-etapa2`): bloco "✍️ ACENTOS E TEXTURAS" antes do TIMING; Passo 5 propõe acento/textura; contrato com os campos novos; `direction` = lado DE ONDE o momento entra (o agente misturava as duas leituras); Modo B com `overlap_frames: 15` (com 0 o empurrão deixava um quadro preto).
- Gerador (`prompts.ts`): `MOTION_LIBRARY_PROMPT` + `DIRECTION_REFERENCE_PROMPT` (TIMING, CONTAINER MORPHÁVEL, MODO B, ANIMAÇÕES copiados verbatim — conferido por diff em runtime, 160 linhas idênticas; só a linha do overlap do Modo B foi alterada nos dois lados). Regras que contradiziam a biblioteca ajustadas (partículas → DotField/LineField; "nunca referencie componente sem definir" ganhou exceção; nomes reservados).
- `src/lib/motion-plan.ts`: spec → plano determinístico anexado ao prompt pela rota de preview. Agrupa momentos ligados por morph em GRUPOS DE CENA (um `MorphContainer` por grupo, keyframes em frames locais), transições direcionais entre grupos (push com `distance="full"` se overlap ≥ 8, senão shift), acento com `delay` calculado pela entrada palavra-a-palavra, textura por momento.
- Bug corrigido: falha da OpenAI no gerador devolvia 200 com código vazio (preview em branco). Agora `streamCode` lança erro com a causa → rota responde 500 com a mensagem.
- RSpec não carrega no container (`uninitialized constant FactoryBot` — pré-existente, ambiente).

**(3) FEITO (código), NÃO VALIDADO com IA — edição do vídeo por conversa** (decisão D: coluna nova, como recomendado):
- Node: laço geração→lint→retry extraído para `generateWithRetry` (comportamento da geração inalterado); `editComponentCode` (sem `validatePrompt`; skills da geração original com fallback para detecção; dimensões nunca redetectadas); `POST /api/v1/edit` com HMAC; `savePreview` compartilhado (`src/lib/preview-store.ts`); montagem do pedido de ajuste em `buildFollowUpUserPrompt`/`buildEditHistoryContext` (`prompts.ts`), usada também pela rota interna `/api/generate`.
- Rails: migration `video_edits jsonb default [] not null` (aplicada); `ClaudeConversation#edit_instructions`; `RemotionService.edit_preview` (+ `preview_result` compartilhado com `generate_preview`); rota `POST /conversations/:id/video/edit` → `VideoController#request_edit` — só em `previewing` com código; falha **nunca** sai de `previewing`; regenerar do zero zera `video_edits`. UI no estado `previewing`: campo + botão "Ajustar vídeo" (`data-turbo-submits-with` como estado de carregamento) + lista dos ajustes aplicados. Ajustes não entram em `api_messages`.
- Verificado: form renderiza; instrução vazia → 422; ajuste real sem crédito → 422 com mensagem, conversa continua `previewing`, código intacto, nenhum ajuste registrado; conversa de outro usuário → 404; conversa `done` → recusada; Node: sem assinatura/assinatura errada → 401, corpo inválido → 422.
- **Decisão de produto pendente (E):** limites do plano contam só tokens do Agente A (`User#total_claude_*` somam `claude_messages`). Geração e ajustes no Node não são contados — com ajustes ilimitados, o custo por usuário fica sem teto.
- **UX pendente:** o painel vive num dropdown que fecha ao clicar fora; o ajuste leva minutos. Funciona (a resposta substitui o painel), mas vale discutir tirar do dropdown.

**VALIDADO em 02/10 com IA (créditos recarregados; Rails e Node agora usam a mesma chave):**
- Etapa 2: geração real pela `/api/v1/preview` com a spec de teste (4 momentos, morph + 2 pushes, 4 acentos, 2 texturas) em 115s, 1 tentativa. O código usou exatamente o que o plano pediu — `MorphContainer`, 3 `SceneTransition` com `distance="full"`, `Scribble`/`CircleAround`/`Strike`/`Highlighter` nas palavras certas, `DotField`/`LineField` — e nenhuma reimplementação. Quadros renderizados pelo bundle do render final conferidos.
- Etapa 3: ajuste real pela `/api/v1/edit` ("legenda maior + fundo azul no momento 3") em 76s, 1 tentativa, sem problemas. Aplicou o pedido, mas mexeu no que não foi pedido (posição da legenda, paleta do momento 3) → regra "SCOPE OF THE CHANGE" no `FOLLOW_UP_SYSTEM_PROMPT`; refeito, o diff ficou só nas 3 linhas pedidas.
- Próximo: Guilherme gera e ajusta vídeos pelo chat (baseline "depois").

**Ao recarregar créditos (histórico):** rodar `node <scratchpad>/call_preview.mjs <spec.json> <out.tsx>` de dentro de `template-remotion/` (chama `/api/v1/preview` assinado) com a spec de teste, renderizar quadros e conferir se o gerador usa as peças; depois o Guilherme gera vídeos pelo chat (baseline "depois" contra os 5 vídeos de 30/09–01/10).

## 4. Ordem do trabalho (original — Passos 3–5 reordenados pela §3b)

### Passo 1 — Decisão A (≈ 1 h)

Se aprovada a recomendação:
1. Backup de `config/initializers/openai_agents.rb` (heredoc `<<~PROMPT`; cuidado com `#{`, que interpola).
2. No Passo 5 do prompt, acrescentar a regra: no modo minimalista cada legenda tem de 2 a 4 palavras (é o que a tabela de TIMING cobre).
3. Em `repair_invalid_spec` (`chat_controller.rb`), deixar claro que encurtar legenda para caber no limite é permitido e esperado.
4. `ruby -c` nos dois arquivos. Não há como validar sem vídeo real — o Passo 2 é o teste.

### Passo 2 — Fechar o baseline (10–20 vídeos, conduzidos pelo Guilherme no navegador)

Variar: minimalista × dinâmico, vertical × horizontal, curto × longo, e aprovar alguns até o render final.

O agente coleta depois:

```bash
# Spec: validou de primeira? caiu no reparo? reparo falhou?
docker logs --since 24h jop-web-1 2>&1 | grep -E 'Spec (inválida|ainda|corrigida)|Generation prompt detected'

# Gerador: tentativas e regras de lint
docker logs --since 24h jop-web-1 2>&1 | grep -E 'Generated component has'

# Duração preview × final: comparar durationInFrames do POST /preview com o do POST /render por conversa
docker logs --since 24h jop-web-1 2>&1 | grep -E 'POST /api/v1/(preview|render)' | grep -oE 'conversation=[0-9]+|durationInFrames: [0-9]+'
```

Do Node (terminal do Guilherme ou `node.log`): linhas `[CodeGenerator] attempt N/3 rejected` e `[Preview API] Preview saved` (`attempts`, `problems`).

Entregável: tabela por vídeo + agregado (% spec válida de primeira, % que precisou de retry no gerador, regras mais frequentes, divergências de duração). Registrar no PRD (seção de status) e aqui.

### Passo 3 — Edição do vídeo por conversa no Rails (≈ 1–2 dias)

**Contexto:** a edição por chat já existe no Node, mas só na UI interna do Next (`localhost:3001/generate` → `POST /api/generate` com `isFollowUp: true` + `currentCode`). Nunca foi ligada ao Rails. No Rails, "Regenerate Preview" gera do zero e, depois do render, a conversa acaba.

Hoje o `FOLLOW_UP_SYSTEM_PROMPT` (`src/lib/prompts.ts`) pede **reescrita completa** do componente (`type: "full"`), não edição por trechos — `critical-prompt-engineer-agent.md` descreve um modo `edit` com `old_string`/`new_string` que está desatualizado. Isso simplifica: a edição pode passar pelo mesmo laço de geração → lint → retry do gerador.

Por que antes da Fase 3: a edição usa o mesmo system prompt do gerador que a Fase 3 vai mudar. Com ela ligada, a Fase 3 é medida também em "o ajuste funcionou?".

**Node**
1. Em `src/lib/code-generator.ts`, extrair o laço de geração/inspeção/retry de `generateComponentCode` para uma função interna reutilizável (recebe system prompt e user content), sem mudar o comportamento atual.
2. Nova `editComponentCode(currentCode, instruction, options)`:
   - não chama `validatePrompt` (o pedido de ajuste não é um pedido de vídeo);
   - skills: as já detectadas na geração (Rails manda `detected_skills`), com fallback para `detectSkills(instruction)`;
   - system: `SYSTEM_PROMPT` + skills + `FOLLOW_UP_SYSTEM_PROMPT`;
   - user: `## CURRENT CODE` + últimos ajustes + `## USER REQUEST`. Montar esse texto num único helper usado também por `src/app/api/generate/route.ts`, para não duplicar (regra: prompts só em `prompts.ts`);
   - dimensões/fps/duração vêm das opções, nunca redetectadas.
3. Nova rota `POST /api/v1/edit`, assinada com HMAC (`validateRequest`, como `/api/v1/preview`). Grava novo token em `public/tmp/` com a mesma lógica da rota de preview (extrair um helper `savePreview` compartilhado). Resposta no mesmo formato do preview: `previewToken`, `previewUrl`, `componentCode`, `attempts`, `problems`.

**Rails**
4. Rota `POST /conversations/:conversation_id/video/edit` → `VideoController#request_edit`.
   - Só permitido em `previewing?` com `component_code` presente; `instruction` obrigatória.
   - `RemotionService.edit_preview(conversation, component_code, instruction, options)` com as opções de `video_spec` e `detected_skills`.
   - Sucesso: atualiza `component_code`, `preview_token`, `preview_token_expires_at`; registra o ajuste no histórico (decisão D).
   - Erro: **continua em `previewing`** e mostra a mensagem no painel (mesmo padrão do `approve` corrigido). Nunca `mark_error!`.
5. UI no estado `previewing` de `_video_preview.html.haml`: campo "O que você quer ajustar?" + botão "Ajustar vídeo", com estado de carregamento (a chamada leva minutos). Approve & Render continua renderizando o `component_code` atual, ou seja, a última versão ajustada — não precisa mudar.
6. Os ajustes **não** entram em `api_messages` (isso alimentaria o Agente A com conversa que não é dele).

**Verificar**
- Token de uso: confirmar se o consumo da OpenAI no Node (geração e edição) entra nos limites do plano. Hoje parece que só o Agente A é contado.
- RSpec do `request_edit` dentro do container. Teste real: gerar, ajustar 2–3 vezes ("deixa a legenda maior", "troca o fundo do momento 3"), aprovar, conferir que o MP4 tem o último ajuste.

**Observação de UX (não bloqueia):** o painel mora num dropdown que fecha ao clicar fora. Para um fluxo de ajuste com esperas de minutos, pode valer tirá-lo do dropdown. Discutir com o Guilherme antes.

### Passo 4 — Fechar o `/api/generate` (≈ 1 h)

`POST /api/generate` (UI interna do Next) **não tem autenticação**: quem alcança a porta 3001 gasta a chave da OpenAI. Irrelevante localmente, obrigatório antes de publicar. Depois do Passo 3 a UI interna deixa de ser necessária para editar; decidir com o Guilherme entre protegê-la ou desligá-la em produção.

### Passo 5 — Fase 3

Conforme HANDOFF §7 (conhecimento entra no Agente B antes de sair do Agente A; mover texto sem reescrever). Comparar cada etapa contra o baseline do Passo 2.

---

## 5. Backlog conhecido (não bloqueia)

| Problema | Onde |
|---|---|
| Rota de status responde `rendering 0.5` para qualquer `render_id` desconhecido — um render perdido fica "renderizando" para sempre | `template-remotion/src/app/api/v1/status/[renderId]/route.ts` |
| `RemotionService.healthy?` chama `/health`; a rota real é `/api/v1/health` (e exige assinatura). Nada usa o método hoje | `app/services/remotion_service.rb` |
| Aviso `interpolate-clamp` apareceu em 100% das gerações até agora — candidato a regra no prompt do gerador ou a virar `error` | `src/lib/code-validator.ts`, `src/lib/prompts.ts` |
| Itens "fora de escopo" do HANDOFF §7 (fila de render, GC de `public/tmp`, unificação das UIs, skills espelhadas) | — |

---

## 6. Regras (além das do HANDOFF §8)

- Guilherme prefere diagnóstico antes de mudança e recomendação com o porquê. Pergunte antes de decisões de produto (as da §3).
- Node sempre no terminal do Guilherme.
- Falha de render ou de edição **não** tira a conversa de `previewing`.
- Nunca imprimir segredos; comparar por hash.

## 7. Para começar a próxima conversa

> Leia `JOPv2/HANDOFF.md` e `JOPv2/PROXIMOS_PASSOS.md`. Confirme o ambiente no ar (§2) e comece pela decisão A da §3.
