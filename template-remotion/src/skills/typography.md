---
title: Typography Intelligence & Layout
impact: CRITICAL
impactDescription: Enforces premium typographic hierarchy, scale, and text-to-visual composition.
tags: typography, text, layout, hierarchy, composition
---

## 1. Separação Estrita: Tipografia Estrutural vs. Legendas (CRITICAL)

O LLM deve entender a diferença absoluta entre **Tipografia** (Headlines, Slogans, Data Points) e **Legendas/Captions** (Voiceover/Transcrição). 
As duas NUNCA devem competir por atenção.

Se houver uma "Tipografia Estrutural" (um Destaque) e "Captions" na mesma cena, force as Captions a ficarem muito menores e ancoradas no rodapé, permitindo que a Tipografia brilhe.

## 2. Direção Artística: Perfis Estéticos (CRITICAL)

O sistema deve adotar um Perfil Estético rigoroso antes de gerar qualquer texto. Não misture perfis.

### Perfil A: Premium / Cinematic
*   **Foco:** Elegância, espaço negativo, minimalismo (Documentários, Institucionais).
*   **Composição:** Fontes finas (`300`, `400`), espaçamento de letras positivo (ex: `letterSpacing: 2`). Cores monocromáticas.
*   **Hierarquia:** Destaque/Hero tem no máximo o dobro do tamanho do subtítulo.

### Perfil B: Kinetic / Statement
*   **Foco:** O texto é a própria arte visual (Openers, Slogans de impacto).
*   **Composição:** Fontes Grotescas/Brutalistas de peso massivo (`800`, `900`), espaçamento de letras negativo (ex: `letterSpacing: -2` a `-4`). Ocupa até 90% da largura da tela. 
*   **Restrição:** Frases curtíssimas (1 a 3 palavras). Cores impactantes ou contraste agressivo.

### Perfil C: Social / High-Retention
*   **Foco:** Dinâmico e retenção de atenção (Reels, TikToks, Shorts).
*   **Composição:** Fontes ultra legíveis. Uso obrigatório de contornos (`WebkitTextStroke`) ou sombras pesadas (`textShadow`). 
*   **Hierarquia:** Menos variação de tamanho, tudo precisa ser altamente visível no celular.

## 3. Hard Guardrails Ergonômicos e Posição

Todas as tipografias estruturais (Headlines e descrições) DEVEM aplicar os seguintes *guardrails* para evitar quebras de interface:

1.  **`lineHeight: 1.1`** (Nunca deixe o padrão do navegador, que cria espaços vazios gigantes entre as linhas de textos grandes).
2.  **`textWrap: 'balance'`** (Garante que os parágrafos ou títulos de múltiplas linhas quebrem de forma harmoniosa).
3.  **`maxWidth: '80ch'`** (Para blocos de texto) ou proporção da tela (ex: `maxWidth: '90%'`) para evitar encostar nas bordas horizontais.

O texto e o elemento visual devem formar um **BLOCO COESO**. Nunca coloque o texto colado no topo e o visual colado na base se eles pertencerem à mesma informação.
