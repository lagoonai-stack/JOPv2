---
title: Depth & Stack Primitive
description: Learn how to create dynamic 3D-like stacking effects (cards overlay, depth layering) for visual elements using scale, opacity, and translate without relying on external animation libraries.
---

# Depth & Stack Primitive

The Depth & Stack primitive introduces visual richness by adding physical scale and layering to elements like testimonials, feature cards, or images. Instead of presenting information in a flat, generic 2D grid, you can stack elements along the Z-axis (simulated) to create a premium, dynamic feel.

This technique is inspired by modern UI libraries but must be implemented purely using Remotion's math primitives (`spring`, `interpolate`) to ensure frame-perfect rendering and deterministic execution.

## ⚠️ Hard Guardrails

- **NEVER use Framer Motion or similar UI animation libraries.** They rely on DOM measurements and asynchronous updates that fail in Remotion's headless rendering environment.
- **Calculate depth deterministically.** The visual position (scale, Y offset, opacity) of every card must be calculable based on the `currentFrame` and its relative index to the active item.

## The Mathematical Approach

To create a stacking effect, you calculate the "distance" of each item from the currently active (front-most) item.

1. **Index Offset:** For each item, calculate how far away it is from the active item (`Math.abs(activeIndex - itemIndex)`).
2. **Scale:** Items further away (higher index offset) should be scaled down.
3. **Translation (Y or X):** Items further away should be pushed down (or to the side) to peek out behind the front item.
4. **Z-Index:** The active item gets the highest `z-index`.
5. **Opacity:** Items very far back should fade out.

## Code Example: Testimonial Stack

Here is how to create a dynamic stack of cards that animates the active card to the front.

```tsx
import React from 'react';
import { useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';

const TESTIMONIALS = [
  { id: 1, text: "Absolutely incredible service." },
  { id: 2, text: "Transformed our workflow entirely." },
  { id: 3, text: "A must-have for any modern team." },
  { id: 4, text: "Stunning results, delivered fast." }
];

export const DepthStack: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  
  // Define when the active card changes (e.g., every 60 frames)
  const framesPerCard = 60;
  
  // Calculate which card is currently the focal point
  // Math.floor ensures we stay on an integer index
  const rawActiveIndex = Math.floor(frame / framesPerCard);
  // Cap it at the last index so we don't go out of bounds
  const activeIndex = Math.min(rawActiveIndex, TESTIMONIALS.length - 1);

  // We use a spring to animate the *transition* between active states.
  // This value animates from 0 -> 1 -> 2 as the activeIndex changes.
  const animatedActiveIndex = spring({
    fps,
    frame,
    config: { damping: 14, mass: 0.8 },
    // We drive the spring based on the current integer activeIndex
    from: activeIndex === 0 ? 0 : activeIndex - 1,
    to: activeIndex,
  });

  return (
    <div style={{ position: 'relative', width: '400px', height: '300px', margin: '0 auto' }}>
      {TESTIMONIALS.map((testimonial, i) => {
        // Calculate dynamic distance from the animated active index
        // Use Math.max(0, ...) so items that have already passed (front) 
        // fall away differently, or just use Math.abs if you want them to stack in front.
        // Here we make past items fall down and fade out.
        
        const isPast = i < activeIndex;
        
        // The distance of THIS card from the 'focus' point
        const distance = Math.max(0, i - animatedActiveIndex);
        
        // Items further back scale down
        const scale = Math.max(0, 1 - distance * 0.05);
        
        // Items further back move down
        const translateY = distance * 20;
        
        // Items too far back fade out (keep max 3 visible)
        const opacity = interpolate(distance, [0, 2, 3], [1, 0.5, 0], {
          extrapolateRight: 'clamp'
        });

        // Special exit animation for items that are now in the past
        const pastDistance = isPast ? animatedActiveIndex - i : 0;
        const pastTranslateY = pastDistance * 100;
        const pastOpacity = interpolate(pastDistance, [0, 1], [1, 0]);

        return (
          <div
            key={testimonial.id}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              backgroundColor: '#ffffff',
              borderRadius: '24px',
              padding: '32px',
              boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              textAlign: 'center',
              fontSize: '24px',
              // Apply the calculated spatial properties
              transform: `translateY(${isPast ? pastTranslateY : translateY}px) scale(${scale})`,
              opacity: isPast ? pastOpacity : opacity,
              zIndex: TESTIMONIALS.length - i, // Front items have higher z-index
              transformOrigin: 'top center',
            }}
          >
            {testimonial.text}
          </div>
        );
      })}
    </div>
  );
};
```

### When to Use This Pattern

- **Testimonials & Reviews:** Stacking cards creates a physical, tactile feel.
- **Feature Highlights:** Showing multiple screenshots or app panes layered behind each other.
- **Image Galleries:** Creating depth instead of a flat grid.

### Aesthetic Guidance

- **Subtlety:** Keep the scale reduction minimal (e.g., `0.05` to `0.1` per level).
- **Shadows:** Soft, generous drop shadows are crucial for selling the illusion of depth between the stacked layers.
- **Spring Tuning:** Use a slightly bouncy spring (`damping: 12-14`) when snapping layers forward to give them physical weight.
