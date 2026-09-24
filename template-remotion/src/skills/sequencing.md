---
title: Scene Choreography & Sequencing
impact: CRITICAL
impactDescription: Establishes rules for narrative continuity, overlaps, and scene-to-scene connection modes.
tags: sequence, choreography, transition, overlap, continuity
---

## 1. Filosofia de Continuidade (CRITICAL)

O vídeo é uma **NARRATIVA CONTÍNUA**, não um conjunto de slides isolados no PowerPoint. Elementos não devem piscar ou desaparecer abruptamente. Quando mudar de cena, utilize um dos dois modos de conexão:

### MODO A: Morphing (Prioridade)
O container principal da cena atua como fio condutor. Ele muda de forma/tamanho/posição para se adequar à próxima cena, enquanto o conteúdo interno antigo faz *fade out* e o novo faz *fade in*.
*   **Uso:** Quando as cenas compartilham elementos estruturais (ex: Card -> Card menor -> Barra de progresso).

### MODO B: Transição Direcional (Continuidade)
Quando o Morph não faz sentido, mantenha a inércia visual. Se os elementos da Cena 1 saem para a ESQUERDA, os elementos da Cena 2 DEVEM entrar da DIREITA. Se saem para BAIXO, entram de CIMA.

## 2. Anatomia do Timing de uma Cena

Não coloque animações acontecendo uma após a outra de forma mecânica. Use **OVERLAPS** fortes. A cena é dividida em 3 fases:

1.  **FASE 1 - Entrada:** O elemento principal ou container entra (usando `spring` ou `Easing.out`).
2.  **FASE 2 - Estabilidade + Build-up:** As micro-animações (números subindo, itens de uma lista) devem começar **DURANTE** a entrada. Regra Absoluta: As animações internas devem iniciar logo após o início da Fase 1, não mecânicamente depois.
3.  **FASE 3 - Conexão/Saída:** Em Modo A, o conteúdo novo começa a entrar enquanto a morph ainda está acontecendo. Em Modo B, aplique Stagger para saírem elegantemente com `Easing.in`.

## 3. A Fonte da Verdade para Overlap e Stagger

PARE DE CHUTAR delays aleatórios (`10`, `15`, `20` frames). Você DEVE utilizar as constantes do sistema de tokens: `TIMING.BASE` (geralmente 30 ou 60 frames) e `TIMING.STAGGER` (atraso entre elementos). O `THEME.pacing` vai ditar o valor de `TIMING.STAGGER` (ex: 2 para pacing "fast", 5 para pacing "calm"), então usar as constantes garante herança automática do ritmo estético.

*   **Overlap de Transição:** Quando uma cena se sobrepõe a outra, use `TIMING.BASE / 2` ou `TIMING.BASE / 3` como regra de offset negativo ou delay interno.
*   **Stagger de Entrada/Saída:** Múltiplos elementos aparecendo (ex: itens de lista, barras de gráfico)? Use `TIMING.STAGGER * index`. NUNCA invente números fixos como `index * 5` ou `index * 10`.

## 3. Uso Técnico de Sequences e Offset

*   **Para Cenas Independentes:** Use `Sequence` e garanta o orçamento de duração matemática (`from` e `durationInFrames`). 
*   **Lembrete Crítico:** Dentro de uma `Sequence`, `useCurrentFrame()` é sempre local (0 a N).
*   **Sobreposição de Cenas (Overlap):** Para criar conexões contínuas (Modo B), uma cena deve iniciar frames antes da cena anterior terminar. Se estiver renderizando múltiplas `Sequence` no mesmo componente pai, calcule os `from` de forma a criar overlaps (ex: Cena 2 tem `from = FIM_CENA_1 - 15`).

## 4. Micro-animações Obrigatórias

Durante a Fase Estável de uma cena, ela nunca deve ficar morta. Adicione pequenas oscilações:
*   Use `Math.sin(frame * 0.025)` para floats verticais muito sutis.
*   Use `interpolate(Math.sin(frame * X), [-1, 1], [0.8, 1])` para pulsações sutis de scale ou opacity.
