---
name: charts
description: Regras de design premium para renderização de gráficos, painéis e visualizações de dados, abandonando a estética "Excel" em favor do sistema de THEME e COLORS.
metadata:
  tags: charts, data, visualization, bar-chart, pie-chart, line-chart, stock-chart, svg-paths, graphs, premium-ui
---

# Premium Charts & Data Viz em Remotion

> **CRÍTICO - INTELIGÊNCIA DECISÓRIA:** NUNCA crie gráficos com estética corporativa padrão (Excel-style). Em Remotion, gráficos devem parecer componentes nativos de um **app SaaS Premium** (como Linear, Vercel ou Stripe).

## Regras Absolutas de Estética para Charts

1. **PROIBIDO uso de cores hardcoded** arbitrárias para barras ou linhas. Utilize APENAS as variáveis do sistema (ex: `COLORS.accent`, `COLORS.textMuted`, `COLORS.border`).
2. **Camadas de Profundidade:** Um gráfico NUNCA fica solto na tela. Ele DEVE estar ancorado em um **Premium Card** (compostas pelas cores de superfície `COLORS.surface1` ou similares e box-shadow de múltiplos níveis).
3. **Animação Orientada a Frame:** Desative TODAS as animações de bibliotecas de terceiros se as usar. Todas as animações devem ser derivadas de `useCurrentFrame()`.
4. **Hierarquia Tipográfica:** As legendas dos eixos usam sempre o tom rebaixado `COLORS.textMuted` e fontes pequenas (`11-13px`, uppercase). O valor hero do gráfico deve usar tipografia massiva e bold com `COLORS.text`.

## Bar Chart (Linear-style)

Em vez de retângulos simples, crie barras com bordas arredondadas e track de fundo subjacente para passar sensação tátil.

```tsx
const STAGGER_DELAY = 5;
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

// Simulação das cores do THEME injetadas via prompt
const accentColor = '#34D399'; // COLORS.accent
const trackColor = 'rgba(255, 255, 255, 0.06)'; // COLORS.border

const bars = data.map((item, i) => {
  const progress = spring({
    frame,
    fps,
    delay: i * STAGGER_DELAY,
    config: { damping: 200 },
  });
  
  return (
    // Track (o "caminho" da barra, visível)
    <div style={{ height: MAX_HEIGHT, width: 40, backgroundColor: trackColor, borderRadius: 8, overflow: 'hidden', position: 'relative' }}>
      // Fill (o valor crescendo de baixo para cima)
      <div style={{ 
        position: 'absolute', bottom: 0, width: '100%', 
        height: progress * item.value, 
        backgroundColor: accentColor,
        boxShadow: `0 0 12px ${accentColor}40` // Glow premium
      }} />
    </div>
  );
});
```

## Premium Ring/Pie Chart (Apple Health style)

Círculos perfeitos com stroke arredondado. Animação de `strokeDashoffset`.

```tsx
const progress = interpolate(frame, [0, 60], [0, 1], { extrapolateRight: 'clamp', easing: Easing.out(Easing.cubic) });
const circumference = 2 * Math.PI * radius;
const segmentLength = (value / total) * circumference;
const offset = interpolate(progress, [0, 1], [circumference, circumference - segmentLength]);

// Track base (opaco)
<circle
  r={radius} cx={center} cy={center}
  fill="none" stroke="rgba(255, 255, 255, 0.06)" strokeWidth={24}
/>

// Arco animado com Glow
<circle
  r={radius} cx={center} cy={center}
  fill="none" stroke={COLORS.accent} strokeWidth={24} strokeLinecap="round"
  strokeDasharray={circumference}
  strokeDashoffset={offset}
  transform={`rotate(-90 ${center} ${center})`}
  filter="url(#glow)" // Reference a filter def for premium look
/>
```

## Line Chart / Path Animation (Stripe-style)

Use `@remotion/paths` para gráficos de linha elegantes (ascendentes). NUNCA desenhe eixos grossos. Deixe a linha brilhar sozinha.

Install: `npx remotion add @remotion/paths`

```tsx
import { evolvePath } from "@remotion/paths";

// O path deve ser gerado pelo seu script de dados
const path = "M 100 200 L 200 150 L 300 180 L 400 100";
const progress = interpolate(frame, [15, 75], [0, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
  easing: Easing.out(Easing.quad),
});

const { strokeDasharray, strokeDashoffset } = evolvePath(progress, path);

<path
  d={path}
  fill="none"
  stroke={COLORS.accent}
  strokeWidth={6}
  strokeLinecap="round"
  strokeLinejoin="round"
  strokeDasharray={strokeDasharray}
  strokeDashoffset={strokeDashoffset}
  style={{ filter: `drop-shadow(0 8px 16px ${COLORS.accent}60)` }} // Sombreamento crucial
/>
```

### Indicador Flutuante
Se for adicionar um marcador na linha ascendente, anime-o ao longo da curva com `getPointAtLength`.

```tsx
import { getLength, getPointAtLength } from "@remotion/paths";

const pathLength = getLength(path);
const point = getPointAtLength(path, progress * pathLength);

<div style={{
  position: 'absolute',
  left: point.x - 10, top: point.y - 10,
  width: 20, height: 20,
  borderRadius: '50%',
  backgroundColor: '#FFFFFF',
  border: `4px solid ${COLORS.accent}`,
  boxShadow: '0 0 20px rgba(0,0,0,0.5)'
}} />
```
