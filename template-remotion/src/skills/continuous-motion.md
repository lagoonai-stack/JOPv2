---
title: Continuous Motion Primitive
description: Learn how to create deterministic, seamless infinite loops (like sliders and carousels) in Remotion without relying on CSS keyframes.
---

# Continuous Motion Primitive

Creating seamless loops, such as infinite sliders, carousels, or logo strips, is a common requirement for premium video compositions. In standard web development, this is often achieved using CSS `@keyframes` with infinite loops. **However, in Remotion, this is a strict anti-pattern.**

To ensure deterministic rendering and frame-perfect exports, you must calculate the continuous motion mathematically using `useCurrentFrame()` and `interpolate()`.

## ⚠️ Hard Guardrails

- **NEVER use CSS `@keyframes` with `infinite` for motion.** It will break the video export because Remotion cannot synchronize headless browser rendering with non-deterministic CSS animations.
- **NEVER use `setInterval` or `requestAnimationFrame` for motion.**
- **ALWAYS base motion on `useCurrentFrame()`.** The position of elements must be fully calculable given any specific frame number.

## The Mathematical Approach

To create a seamless infinite loop, you need to:

1. **Duplicate the Content:** Render the list of items multiple times (at least twice) so that as the first set scrolls out of view, the second set seamlessly replaces it.
2. **Calculate the Cycle:** Define how many frames it takes for one complete cycle (e.g., sliding exactly the width of one set of items).
3. **Use Modulo (`%`):** Use the modulo operator on the current frame to find the progress within the current cycle.
4. **Interpolate:** Map the progress to a translation value (e.g., `0` to `-100%`).

## Code Example: Infinite Logo Slider

Here is the correct, deterministic way to build a continuous horizontal slider in Remotion:

```tsx
import React from 'react';
import { useCurrentFrame, interpolate } from 'remotion';

const LOGOS = ['Logo A', 'Logo B', 'Logo C', 'Logo D', 'Logo E'];

// To make the loop seamless, we need enough items to fill the screen twice.
// If the list is short, duplicate it multiple times.
const ITEMS_TO_RENDER = [...LOGOS, ...LOGOS]; 

export const ContinuousSlider: React.FC = () => {
  const frame = useCurrentFrame();
  
  // Define how many frames it takes to slide exactly ONE full set of the original logos
  const cycleDuration = 120; // e.g., 4 seconds at 30fps
  
  // Calculate progress within the current cycle (0 to 1)
  const progress = (frame % cycleDuration) / cycleDuration;
  
  // Interpolate progress to translation. 
  // We move from 0 to -50% because ITEMS_TO_RENDER contains two sets.
  // When it reaches -50%, it snaps back to 0 perfectly seamlessly.
  const translateX = interpolate(progress, [0, 1], [0, -50]);

  return (
    <div style={{ width: '100%', overflow: 'hidden', whiteSpace: 'nowrap', display: 'flex' }}>
      <div 
        style={{ 
          display: 'flex', 
          gap: '40px',
          // Apply the calculated translation deterministically
          transform: `translateX(${translateX}%)` 
        }}
      >
        {ITEMS_TO_RENDER.map((logo, index) => (
          <div 
            key={index} 
            style={{
              padding: '20px 40px',
              backgroundColor: '#f0f0f0',
              borderRadius: '12px',
              fontSize: '24px',
              fontWeight: 'bold',
            }}
          >
            {logo}
          </div>
        ))}
      </div>
    </div>
  );
};
```

### When to Use This Pattern

Use this Continuous Motion pattern for:
- Logo grids or strips that scroll continuously.
- Long lists of text (like stock tickers).
- Constellations of elements that drift seamlessly.
- Background textures or patterns that pan infinitely.

### Aesthetic Guidance

- **Speed:** Keep the motion smooth and relatively slow. High speeds can cause strobing effects. Adjust `cycleDuration` based on the content width.
- **Direction:** For vertical sliders (e.g., a scrolling list of features), apply the same math to `translateY`.
- **Easing:** Continuous sliders usually *should not* have easing. They should move at a constant linear speed (`[0, 1]` mapped directly). If you add easing, the loop will noticeably "pulse" at the seam.
