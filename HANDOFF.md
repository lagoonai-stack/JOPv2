# Handoff — Alinhamento movie-maker ↔ gerador Remotion

Estado em 30/09/2026. Documento para um agente de IA dar continuidade ao trabalho. Leia inteiro antes de mexer em código.

PRD completo (fonte das decisões, com seções numeradas citadas abaixo): https://claude.ai/code/artifact/5ebf94ef-4a8b-4348-8eb9-c59acc85cf18

---

## 1. Onde paramos, em uma frase

As Fases 0, 1 e 2 do PRD estão implementadas no working tree (nada commitado); o stack Docker foi recriado a partir desta cópia com a chave da OpenAI; **o próximo passo é configurar o `REMOTION_SHARED_SECRET` nos dois lados e subir o serviço Node, para rodar vídeos reais e coletar um baseline antes da Fase 3.**

---

## 2. O sistema, em 30 segundos

Aplicação Rails 8 ("One Prompt") em `JOPv2/` + serviço Node/Next.js (Remotion) em `JOPv2/template-remotion/`.

```
Usuário → Chat Rails → Agente A: movie-maker (OpenAI Responses API, 6 passos)
                          │  Passo 6: prosa + bloco ```json com a VideoSpec
                          ▼
         chat_controller extrai + valida a spec (app/services/video_spec.rb)
                          │  HTTP + HMAC (X-JOP-Signature)
                          ▼
         Node :3001  POST /api/v1/preview → Agente B: gerador de TSX
                          │  validação → detecção de skills → geração → lint/sintaxe → retry
                          ▼
         public/tmp/{token}.tsx → /embed/[token] (Player) → POST /api/v1/render (MP4)
```

- **Agente A (`movie-maker`)**: `config/initializers/openai_agents.rb`. Conduz o briefing e decide o vídeo.
- **Agente B (gerador)**: `template-remotion/src/lib/code-generator.ts`. Transforma o pedido em componente React/Remotion.
- O Rails roda em Docker (porta 3000). O Node roda **no host** via `npm run dev` (porta 3001); o Rails o alcança por `host.docker.internal:3001`.

---

## 3. O problema que o PRD resolve

Os dois agentes nunca foram desenhados juntos:

1. ~78% do prompt do Agente A (1.260 linhas originais) é direção técnica para quem escreve código — mas chegava ao Agente B como prosa dentro do prompt do usuário.
2. O system prompt do Agente B usado pelo SaaS tinha **31 linhas**; a UI Next interna usava uma versão de **201** com todas as invariantes de renderização.
3. O bloco JSON com `width/height/fps/moments` nunca era lido (o parser só aceitava mensagem 100% JSON, contradizendo o próprio prompt).
4. Defaults conflitantes: preview a 30fps, render final a **60fps** com o mesmo número de frames → vídeo final com metade da duração do preview aprovado. Vertical combinado podia sair horizontal.

Princípio da solução: **cada agente cuida do que é variável; o que é invariante vira código.** O system prompt carrega as regras; o user prompt carrega o vídeo específico. O contrato entre os dois é a `VideoSpec`.

---

## 4. Decisões

| # | Decisão | Status |
|---|---|---|
| 1 | Componentes estruturais (background, caption, card, anel, morph) como **biblioteca** real; componente visual de cada momento continua gerado | recomendado, **aguarda confirmação** |
| 2 | **O Agente A para de escrever CSS**, frames e estrutura React; passa a decidir e emitir spec. O entregável "colável no Cursor" deixa de existir | **DECIDIDO (24/09/2026)** — executa na Fase 3 |
| 3 | Minimalista e dinâmico continuam **um só agente**; regras de lettering injetadas conforme `mode` | recomendado, **aguarda confirmação** |
| 4 | FPS é **campo** do schema travado em 30; fórmulas calculam em segundos × fps | implementado assim |

Não reabra a decisão 2. Para 1 e 3, pergunte ao usuário antes da Fase 4 / enxugamento do Agente A.

---

## 5. O que já foi feito

Nada disso está commitado. `git status` mostra tudo como modificado/untracked. **Não faça commit sem o usuário pedir.**

### Fase 0 — Parar a sangria ✅

| Mudança | Arquivo |
|---|---|
| `VALIDATION_PROMPT`, `SYSTEM_PROMPT` (201 linhas) e `FOLLOW_UP_SYSTEM_PROMPT` extraídos para um único módulo, importado pelos dois caminhos de geração | `template-remotion/src/lib/prompts.ts` (novo), `code-generator.ts`, `src/app/api/generate/route.ts` |
| `VIDEO_DEFAULTS` único no Node | `template-remotion/src/lib/video-defaults.ts` (novo) |
| Precedência corrigida: **opções explícitas do chamador > detecção por LLM > defaults** (antes a detecção vencia) | `code-generator.ts` |
| `VIDEO_DEFAULTS` único no Rails (1080×1920, 30fps, 300f); `|| 60` e `|| 450` removidos | `app/services/remotion_service.rb`, `app/controllers/video_controller.rb` |
| Extração do bloco ```json por *fence*, com JSON puro como fallback; spec encontrada curto-circuita as heurísticas de regex | `app/controllers/chat_controller.rb` (`extract_video_spec`, `normalize_video_spec`) |
| `GET /api/v1/status` agora valida HMAC de verdade (antes só checava presença do header); comparação com `timingSafeEqual` | `template-remotion/src/helpers/auth.ts` (`validateSignedGet`), rota de status |

### Fase 1 — Rede de segurança no gerador ✅

| Mudança | Arquivo |
|---|---|
| Preparação de texto do código gerado extraída do compilador do browser para módulo compartilhado (servidor e browser inspecionam exatamente o mesmo texto) | `template-remotion/src/remotion/code-prepare.ts` (novo), `src/remotion/compiler.ts` |
| Checagem de sintaxe via Babel + 6 regras de lint em 2 severidades | `template-remotion/src/lib/code-validator.ts` (novo) |
| Loop de até 3 tentativas: código com problema `error` é regerado com a lista de problemas no prompt | `code-generator.ts` |
| `attempts` e `problems` sobem na resposta da API e são logados no Rails (`Rails.logger.warn`) — **é a telemetria do baseline** | `src/app/api/v1/preview/route.ts`, `remotion_service.rb` |

Regras de lint: `overlay-adjacent-transition`, `native-img`, `css-animation`, `tailwind-animation`, `r3f-use-frame` (todas `error`) e `interpolate-clamp` (`warning` — nunca dispara retry sozinha, só entra na correção quando já há retry).

### Fase 2 — O contrato ✅ (com desvio deliberado)

| Mudança | Arquivo |
|---|---|
| `VideoSpec` em Ruby: valida a spec do agente, aplica regras de sequência e **deriva** duração por momento, `start_frame`, `total_frames` e dimensões. Única implementação da derivação | `app/services/video_spec.rb` (novo) |
| Segunda camada em Zod: valida coerência (dimensão × format, timeline fecha, índices), responde **422** com lista de problemas, **nunca recalcula** | `template-remotion/src/lib/video-spec.ts` (novo), rota de preview |
| Bloco 14 do prompt do Agente A reescrito: contradição "prosa + JSON" × "apenas JSON" eliminada; agente não envia mais `width`, `height`, `start_frame` nem total; spec com 12 campos por momento | `config/initializers/openai_agents.rb` (linhas ~1215–1320) |
| Loop de correção invisível ao usuário: spec inválida volta ao agente uma vez com a lista de erros; se falhar de novo, mantém a primeira resposta e loga | `chat_controller.rb` (`repair_invalid_spec`, `merge_token_usage`) |
| Spec canônica persistida em `video_spec["canonical"]` (sem migration; as 4 chaves de topo continuam iguais) e enviada ao Node como `spec` | `chat_controller.rb`, `video_controller.rb`, `remotion_service.rb` |
| Bug pré-existente corrigido: a mensagem do usuário ia **duplicada** ao modelo (`api_messages` já a continha) | `chat_controller.rb` (`call_openai`) |

**Desvio:** o Passo 6 **ainda emite prosa junto com a spec**. Torná-lo spec-only antes de mover o conhecimento de design para o Agente B deixaria o gerador sem design system, tabela de morph e repertório. Isso se cumpre na Fase 3 (ver seção 7).

Tabela de duração implementada (vem do bloco "TIMING" do agente):
- minimalista: `1.0 + 0.5 × palavras` s → 2/3/4 palavras = 60/75/90 frames
- dinâmico: 2–4 palavras 2.0–2.5s · 5–8 palavras 2.5–3.5s · 9–12 palavras 3.5–4.5s
- clamp [2.0s, 4.5s]; `duration_frames` explícito do agente sobrescreve; `overlap_frames` das transições é descontado do total.

### Verificação feita

- `ruby -c` em todos os arquivos Ruby tocados: OK.
- `VideoSpec`: 15/15 casos (regras de negócio + tabelas de duração + overlap + override).
- Lint: 12/12 casos, incluindo 4 guardas de falso positivo.
- `npx tsc --noEmit` em `template-remotion/`: **limpo em tudo que foi escrito**. Restam 2 erros em `src/hooks/useMapboxCamera.ts` que são **baseline** (existem na árvore sem as mudanças — confirmado com `git stash`). Não é tarefa sua corrigir.
- Cross-check das duas camadas: spec canônica gerada em Ruby é aceita pelo Zod; 6 incoerências plantadas foram rejeitadas.

### Verificação que NÃO foi feita

- **Nenhuma geração real de vídeo** rodou desde as mudanças. Tudo acima é verificação estática/unitária.
- RSpec não roda localmente: `bundle install` no host falha no gem `haml-rails`. Rodar dentro do container (`docker exec jop-web-1 bundle exec rspec`).

---

## 6. Estado do ambiente

### Docker

- Stack recriado a partir de **`JOPv2/`** com nome de projeto **`jop`** (para reaproveitar volumes). Containers: `jop-web-1` (porta 3000), `jop-db-1`.
- Volumes preservados: `jop_postgres_data`, `jop_storage_data` — 3 usuários existentes continuam lá.
- **Em 30/09 o Docker Desktop estava desligado.** Ligue-o antes de qualquer coisa.
- Comando correto para subir (as duas env-files são necessárias para interpolar `DB_USER`/`DB_PASSWORD` no compose):

```bash
cd JOPv2
docker compose -p jop --env-file .env --env-file .env.local up -d --build
```

Não use `docker compose up` sem `-p jop`: o nome do projeto viraria `jopv2` e criaria volumes novos e vazios.
`docker compose restart` **não** relê `env_file`; para aplicar mudança de env use `up -d --force-recreate web`.

### Cópia antiga — não confundir

Existe `C:\Users\pieru\JOP`, uma cópia **anterior** à migração para OpenAI (`claude_service.rb`, sem `openai_agents.rb`, sem `template-remotion/`, git history diferente). Era ela que rodava no Docker até 25/09. **Não trabalhe nela.** A fonte da verdade é `C:\Users\pieru\OneDrive\Área de Trabalho\jop\JOPv2`.

### Variáveis de ambiente

| Variável | Onde | Status |
|---|---|---|
| `OPENAI_API_KEY` | `JOPv2/.env` | ✅ presente, conferida dentro do container |
| `DB_USER`, `DB_PASSWORD` | `JOPv2/.env.local` | ✅ `DB_PASSWORD` estava vazio; foi alinhado à senha do volume existente |
| `REMOTION_SHARED_SECRET` | `JOPv2/.env` | ❌ **ausente** — toda chamada de preview levanta `RemotionService::ConfigurationError` |
| `JOP_SHARED_SECRET`, `OPENAI_API_KEY` | `template-remotion/.env` | ❌ **arquivo não existe** — serviço Node não sobe configurado |

Os dois segredos HMAC (`REMOTION_SHARED_SECRET` no Rails, `JOP_SHARED_SECRET` no Node) **precisam ter o mesmo valor**. A cópia antiga (`C:\Users\pieru\JOP\.env`) tem um `REMOTION_SHARED_SECRET` que pode ser reaproveitado. Nunca imprima valores de segredos em log ou resposta; compare por hash.

### Plano ilimitado

Rake task (untracked): `lib/tasks/assign_unlimited_plan.rake`.
```bash
docker exec jop-web-1 ./bin/rails users:assign_unlimited_plan EMAIL=alguem@exemplo.com
```
Já aplicado a `lagoon.auto.ai@gmail.com` (#2) e `user@gmail.com` (#1).

### Alerta de segurança

`JOPv2/.env` está **versionado no git** e contém a chave da OpenAI e segredos Stripe. Antes de qualquer push: `git rm --cached .env` e garantir `.env` no `.gitignore`. Pergunte ao usuário antes de executar.

---

## 7. Plano restante

### Passo imediato — tornar o pipeline executável e medir (≈ meio dia)

Pendente de confirmação do usuário (a pergunta foi feita e ficou sem resposta).

1. Ligar o Docker Desktop e subir o stack (comando da seção 6).
2. Adicionar `REMOTION_SHARED_SECRET` em `JOPv2/.env`; recriar o `web` com `--force-recreate`.
3. Criar `template-remotion/.env.local` com `JOP_SHARED_SECRET` (mesmo valor) e `OPENAI_API_KEY`.
4. `cd template-remotion && npm run dev` (dependências já instaladas via `npm ci`).
5. Gerar 10–20 vídeos reais pelo chat em `localhost:3000/chat`.
6. Coletar do log: quantas gerações precisaram de retry (`attempts > 1`), quais regras de lint disparam mais, se a spec do agente valida de primeira ou cai em `repair_invalid_spec`, e se preview e render final têm a mesma duração.

Por que antes da Fase 3: a Fase 0 trocou o system prompt do gerador (31 → 201 linhas) e isso nunca foi medido. A Fase 3 muda o mesmo prompt de novo; sem baseline, uma regressão fica impossível de atribuir.

### Fase 3 — Mudança de residência do conhecimento (5–8 dias)

**Regra de ordem: conhecimento entra no Agente B ANTES de sair do Agente A.**

1. **Adicionar ao Agente B** (Agente A continua emitindo prosa; nada quebra):
   - Mover para o system prompt do gerador (via `src/lib/prompts.ts`) os blocos do Agente A: TIMING (fases por momento, regra de overlap), DESIGN SYSTEM (paleta Dark Premium + alternativas, escalas tipográficas), ESCALA E PROPORÇÃO, CONTAINER MORPHÁVEL (timeline de morph frame a frame), MODO B (direção oposta, stagger), ANIMAÇÕES (entradas/saídas/micro, regras de easing e clamp), CAPTION minimalista.
   - Mover o **texto sem reescrever** — só muda de arquivo. Reescrever perde nuance difícil de detectar.
   - Injetar condicionalmente por `mode` (regras de lettering minimalista × dinâmico), pelo mesmo mecanismo das skills.
   - Validar: mesma spec, gerar antes e depois, comparar o código.
2. **Extrair o repertório visual** (pode ir em paralelo com o item 1; não depende de nada):
   - As ~50 entradas conceito→componente das 4 categorias (Produto Digital, Abstrato Geométrico, Orgânico/Natural, Tipográfico/Simbólico) viram dado estruturado: `{ category, concept, component_id, description, composition_notes }`.
   - `component_id` em snake_case deve bater com os valores que o agente emite em `visual_component`.
   - Uso: o Agente A consulta para escolher; o Agente B recebe a entrada correspondente de cada momento.
3. **Renderizador determinístico spec → prompt** no Node: a spec canônica vira o user prompt do Agente B, momento a momento, com os campos derivados já calculados e a entrada do repertório de cada `visual_component`.
   - Com ele, a detecção de skills pode rodar sobre campos da spec (ou virar mapeamento por tabela) e a chamada `validatePrompt` pode ser removida quando há spec.
4. **O corte** (único ponto de risco real):
   - Rota de preview passa a usar o prompt renderizado da spec em vez da prosa.
   - Passo 6 do Agente A vira **spec-only**; remover do prompt dele os blocos movidos, o LIMITE/ESTRATÉGIA DE COMPACTAÇÃO (desnecessário sem prosa), o CHECKLIST PRÉ-ENTREGA (as regras mecânicas já são lint/validação) e o EXEMPLO longo (vira few-shot do B, se útil).
   - Ajustar `extract_generation_prompt` / `strip_generation_prompt` no `chat_controller`, que ainda assumem prosa.
   - Alvo: prompt do Agente A com ~400 linhas.
   - Se o código piorar sem a prosa, falta algo no item 1 — voltar é seguro.

Aceite: prompt do Agente A em ~400 linhas; duas gerações com a mesma spec produzem código com a mesma estrutura de design.

### Fase 4 — Componentes reais (depende da decisão 1)

Componentes em `template-remotion/src/remotion/design-system/`, expostos ao código gerado via `src/remotion/compiler.ts` (lista de nomes injetados em `new Function`):

1. `MorphContainer` — **primeiro**. Recebe forma de origem, forma de destino e janela de frames; interpola width/height/borderRadius/posição com `Easing.inOut(Easing.cubic)`. O Modo A (morph) é o conceito central da direção e hoje tem suporte zero no gerador.
2. `CaptionWordByWord` — o código já existe por extenso no prompt do Agente A (bottom 450px, 26px/300/ls2/uppercase, palavra a cada 5 frames a partir do frame 8).
3. `Background3Layers`, `PremiumCard`, `ProgressRing`.

O componente visual específico de cada momento **não** vira biblioteca — é onde mora a variedade.

Aceite: vídeo minimalista com legenda pixel-idêntica em todos os momentos.

### Fora de escopo (rodada seguinte)

Fila de render + cache de `bundle()` + status persistido (hoje `Map` em memória em `local-render-service.ts`); limpeza de `public/tmp/` e `public/renders/` (sem GC, arquivos públicos); unificação das duas UIs (chat Rails × UI Next); remoção de `template-remotion/index.ts` (cópia desatualizada de `src/skills/index.ts`) e dos ~28 diretórios espelhados de skills (`.claude/`, `.cursor/`, `.codex/`…).

---

## 8. Regras para quem continua

- Fonte da verdade: `JOPv2/`. Nunca `C:\Users\pieru\JOP`.
- Não commitar sem pedido. Não fazer push com `.env` versionado.
- Nunca imprimir segredos; comparar por hash (`sha256sum | cut -c1-12`).
- Derivação de timeline existe **só** em `app/services/video_spec.rb`. O Zod valida, não recalcula. Não duplique a fórmula.
- Prompts do gerador existem **só** em `template-remotion/src/lib/prompts.ts`. Não recrie cópias nas rotas.
- Preparação do código gerado existe **só** em `src/remotion/code-prepare.ts`.
- Ao mover blocos do prompt do Agente A: mover, não reescrever. Fazer backup antes (o arquivo é um heredoc Ruby `<<~PROMPT`; cuidado com `#{`, que interpola).
- O usuário é Guilherme; comunica-se em português. Prefere análise antes de mudança e recomendação com o porquê, não lista de opções.
- Atualize a seção de status do PRD (link no topo) ao concluir cada fase.

---

## 9. Índice de arquivos

Caminhos relativos a `JOPv2/`.

| Arquivo | Papel |
|---|---|
| `config/initializers/openai_agents.rb` | Agente A inteiro; contrato de saída JSON a partir da linha ~1215 |
| `app/services/video_spec.rb` | Contrato em Ruby: validação + derivação |
| `app/controllers/chat_controller.rb` | Extração/validação/reparo da spec; heurísticas legadas de prosa |
| `app/controllers/video_controller.rb` | `request_preview`, `approve`, `status` |
| `app/services/remotion_service.rb` | Transporte HMAC; `VIDEO_DEFAULTS`; log de `problems` |
| `app/services/openai_service.rb` | Chamada à Responses API do Agente A |
| `app/models/claude_conversation.rb` | Máquina de estados do vídeo; `api_messages` |
| `lib/tasks/assign_unlimited_plan.rake` | Plano ilimitado |
| `template-remotion/src/lib/prompts.ts` | Prompts do Agente B (fonte única) |
| `template-remotion/src/lib/code-generator.ts` | Pipeline do Agente B + loop de retry |
| `template-remotion/src/lib/code-validator.ts` | Sintaxe + lint |
| `template-remotion/src/lib/video-spec.ts` | Contrato em Zod |
| `template-remotion/src/lib/video-defaults.ts` | Defaults do Node |
| `template-remotion/src/remotion/code-prepare.ts` | Preparação de texto compartilhada |
| `template-remotion/src/remotion/compiler.ts` | Compilação no browser; lista de APIs injetadas |
| `template-remotion/src/skills/index.ts` | 21 guidance skills + 9 example skills + `SKILL_DETECTION_PROMPT` |
| `template-remotion/src/app/api/v1/preview/route.ts` | Entrada do Rails; valida spec; grava `public/tmp/{token}.tsx` |
| `template-remotion/src/app/api/v1/render/route.ts` | Render síncrono |
| `template-remotion/src/helpers/auth.ts` | HMAC (`validateRequest`, `validateSignedGet`) |
| `template-remotion/src/hooks/useAutoCorrection.ts` | Auto-correção da UI Next (referência do loop portado) |

---

## 10. Como verificar

```bash
# Ruby — sintaxe (no host)
ruby -c app/services/video_spec.rb app/controllers/chat_controller.rb

# Node — typecheck (esperado: só os 2 erros baseline de useMapboxCamera.ts)
cd template-remotion && npx tsc --noEmit -p tsconfig.json

# RSpec — dentro do container
docker exec jop-web-1 bundle exec rspec

# App no ar
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/
```
