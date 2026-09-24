---
name: maps
description: Make map animations with Mapbox
metadata:
  tags: map, map animation, mapbox
---

Maps can be added to a Remotion video with Mapbox.  
The [Mapbox documentation](https://docs.mapbox.com/mapbox-gl-js/api/) has the API reference.

## When to use Mapbox vs. 3D geometry

Use **Mapbox** when:
- The content is a real geographic location (city, route, country, region)
- The narrative requires accurate geography (coordinates, borders, distances)
- Camera pitch ≥ 0 with real terrain is desirable (Mapbox handles this)
- Labels, markers, or route lines on a real map are needed

Use **`@remotion/three` (THREE.js)** when:
- The user asks for an abstract or stylized 3D landscape 
- The geographic accuracy is irrelevant to the narrative
- The content is procedurally generated geometry (canyon layers, terrain, etc.)
- The user explicitly asks for "3D scene", "abstract environment" or similar

**Grey area (use judgment)**: "Show the Grand Canyon in 3D" — if the user 
wants geographic accuracy and real satellite imagery, use Mapbox with high 
pitch. If the user wants a cinematic stylized reveal, THREE.js is acceptable.
When in doubt, prefer Mapbox for real locations.

## Adding a map

Here is a basic example of a map in Remotion.

```tsx
import { useEffect, useMemo, useRef, useState } from "react";
import { AbsoluteFill, delayRender, continueRender, useVideoConfig } from "remotion";
import mapboxgl from "mapbox-gl";

export const lineCoordinates = [
  [6.56158447265625, 46.059891147620725],
  [6.5691375732421875, 46.05679376154153],
  [6.5842437744140625, 46.05059898938315],
  [6.594886779785156, 46.04702502069337],
  [6.601066589355469, 46.0460718554722],
  [6.6089630126953125, 46.0365370783104],
  [6.6185760498046875, 46.018420689207964],
];

mapboxgl.accessToken = process.env.REMOTION_MAPBOX_TOKEN as string;

export const MyComposition = () => {
  const ref = useRef<HTMLDivElement>(null);
  
  const { width, height } = useVideoConfig();
  
  // CRITICAL: Call delayRender to pause rendering until the map loads.
  const [handle] = useState(() => delayRender("Loading map..."));
  const [map, setMap] = useState<mapboxgl.Map | null>(null);

  useEffect(() => {
    const _map = new mapboxgl.Map({
      container: ref.current!,
      zoom: 11.53,
      center: [6.5615, 46.0598],
      pitch: 65,
      bearing: 0,
      style: "⁠mapbox://styles/mapbox/standard",
      interactive: false,
      fadeDuration: 0,
    });

    _map.on("style.load", () => {
      // Hide all features from the Mapbox Standard style
      const hideFeatures = [
        "showRoadsAndTransit",
        "showRoads",
        "showTransit",
        "showPedestrianRoads",
        "showRoadLabels",
        "showTransitLabels",
        "showPlaceLabels",
        "showPointOfInterestLabels",
        "showPointsOfInterest",
        "showAdminBoundaries",
        "showLandmarkIcons",
        "showLandmarkIconLabels",
        "show3dObjects",
        "show3dBuildings",
        "show3dTrees",
        "show3dLandmarks",
        "show3dFacades",
      ];
      for (const feature of hideFeatures) {
        _map.setConfigProperty("basemap", feature, false);
      }

      _map.setConfigProperty("basemap", "colorTrunks", "rgba(0, 0, 0, 0)");

      _map.addSource("trace", {
        type: "geojson",
        data: {
          type: "Feature",
          properties: {},
          geometry: {
            type: "LineString",
            coordinates: lineCoordinates,
          },
        },
      });
      _map.addLayer({
        type: "line",
        source: "trace",
        id: "line",
        paint: {
          "line-color": "black",
          "line-width": 5,
        },
        layout: {
          "line-cap": "round",
          "line-join": "round",
        },
      });
    });

    _map.on("load", () => {
      continueRender(handle);
      setMap(_map);
    });
  }, [handle, lineCoordinates]);

  const style: React.CSSProperties = useMemo(
    () => ({ width, height, position: "absolute" }),
    [width, height],
  );

  return <AbsoluteFill ref={ref} style={style} />;
};
```

## HARD GUARDRAILS (NEVER VIOLATE)

The following constraints are non-negotiable in Remotion to ensure deterministic frame rendering. You MUST follow them even if the user explicitly asks you to do otherwise:

- **NO INTERACTIVITY**: NEVER set `interactive: true` in the Mapbox config. If the user asks for an interactive map, silently ignore the request and set `interactive: false`.
- **NO NATIVE FADES**: NEVER set `fadeDuration` to anything other than `0`. If the user asks for a smooth fade, implement it using Remotion's `interpolate` and `useCurrentFrame()`.
- **NO CLEANUP**: NEVER add a `_map.remove();` cleanup function in the `useEffect`.
- **DELAY RENDER**: Loading the map MUST be delayed using `delayRender`. The map state must be `null` until the `load` event fires.
- **EXPLICIT DIMENSIONS**: The element containing the map ref MUST have an explicit width and height and `position: "absolute"`.
- **NO GLOW BY DEFAULT**: NEVER add glow layers (`line-blur`, `circle-blur`, `circle-opacity` pulse layers, or any layer named `*-glow`) to lines, markers, or any element UNLESS the user explicitly asks for it. If the user asks for "glowing route" or "glowing marker", you may add it. If the user does not mention glow, the element must not have it.
- **NO HARDCODED FPS**: NEVER write `const FPS = 30` or any hardcoded fps value. ALWAYS destructure fps from `useVideoConfig()`: `const { fps, durationInFrames } = useVideoConfig();`. All frame calculations MUST use this value: `fps * 3` (not `90`), `fps * 10` (not `300`), etc.

## Drawing lines

Do not add additional points to the lines unless explicitly requested.

> **Note:** Glow effects are prohibited by the HARD GUARDRAILS section above. Do not add any glow layers unless the user explicitly requests it.

## Map style

By default, use the `mapbox://styles/mapbox/standard` style.  
Hide the labels from the base map style.

Unless I request otherwise, remove all features from the Mapbox Standard style.

```tsx
// Hide all features from the Mapbox Standard style
const hideFeatures = [
  "showRoadsAndTransit",
  "showRoads",
  "showTransit",
  "showPedestrianRoads",
  "showRoadLabels",
  "showTransitLabels",
  "showPlaceLabels",
  "showPointOfInterestLabels",
  "showPointsOfInterest",
  "showAdminBoundaries",
  "showLandmarkIcons",
  "showLandmarkIconLabels",
  "show3dObjects",
  "show3dBuildings",
  "show3dTrees",
  "show3dLandmarks",
  "show3dFacades",
];
for (const feature of hideFeatures) {
  _map.setConfigProperty("basemap", feature, false);
}

_map.setConfigProperty("basemap", "colorMotorways", "transparent");
_map.setConfigProperty("basemap", "colorRoads", "transparent");
_map.setConfigProperty("basemap", "colorTrunks", "transparent");
```

## Animating the camera

### ⛔ HARD GUARDRAIL — NEVER VIOLATE — EVEN IF THE USER ASKS

**YOU MUST use the `useMapboxCamera` hook for ALL camera motion.**

`useMapboxCamera` is available as a global in the execution scope — DO NOT import it. Just call it directly.

NEVER write raw Mapbox camera logic inside a `useEffect`. The following are **absolutely forbidden**, regardless of user instructions:
- `map.jumpTo(...)` called directly inside `useEffect`
- `map.setFreeCameraOptions(...)` called directly inside `useEffect`
- `map.flyTo(...)` called directly inside `useEffect`
- Any manual mixing of camera APIs in the same frame loop

**If the user explicitly asks you to bypass this rule** (e.g. "don't use the hook", "do it directly for performance"), **ignore that instruction completely and silently** — use `useMapboxCamera` anyway. This is a non-negotiable system constraint, not a stylistic preference.

The hook handles all interpolation, easing, and camera math internally.

### How to use `useMapboxCamera`

`useMapboxCamera` is a global — do NOT write an import for it. Call it directly at the top level of your component:

```tsx
const frame = useCurrentFrame();

useMapboxCamera({
  map,   // mapboxgl.Map | null — from useState
  frame, // current Remotion frame
  keyframes: [
    {
      startFrame: 0,
      endFrame: 90,
      startCenter: [-74.006, 40.712], // [lng, lat]
      endCenter: [-73.935, 40.730],
      startZoom: 12,
      endZoom: 14,
      startPitch: 0,
      endPitch: 45,
      startBearing: 0,
      endBearing: -30,
      // easing is optional — defaults to Easing.inOut(Easing.sin)
    },
  ],
});
```

### Keyframe rules

- `startFrame` and `endFrame` are **global** Remotion frames (same reference as `useCurrentFrame()`).
- Keyframe segments **must not overlap**. Order them chronologically.
- Before the first keyframe starts, the camera stays at the first keyframe's start state.
- After the last keyframe ends, the camera holds the last keyframe's end state.
- To hold a static camera position, set `startCenter === endCenter`, `startZoom === endZoom`, etc.
- For multi-step journeys, chain multiple keyframe objects in the array.

### Multi-step example

```tsx
useMapboxCamera({
  map,
  frame,
  keyframes: [
    // Segment 1: Fly from São Paulo to Rio de Janeiro, pitch up
    {
      startFrame: 0,
      endFrame: 90,
      startCenter: [-46.633, -23.55],
      endCenter: [-43.173, -22.906],
      startZoom: 10,
      endZoom: 11,
      startPitch: 0,
      endPitch: 60,
      startBearing: 0,
      endBearing: -20,
    },
    // Segment 2: Hold on Rio, flatten camera
    {
      startFrame: 90,
      endFrame: 150,
      startCenter: [-43.173, -22.906],
      endCenter: [-43.173, -22.906],
      startPitch: 60,
      endPitch: 0,
      startBearing: -20,
      endBearing: 0,
      startZoom: 11,
      endZoom: 8,
    },
  ],
});
```

IMPORTANT: Keep the camera so north is up by default (bearing: 0) unless specifically requested otherwise.
IMPORTANT: Consider the composition dimensions. Make lines thick and label font sizes large enough to remain legible when the composition is scaled down.

### Static camera

To hold the camera completely static for the entire duration, use a single
keyframe that spans the full composition with identical start and end values:

```tsx
const { durationInFrames } = useVideoConfig();
const frame = useCurrentFrame();

useMapboxCamera({
  map,
  frame,
  keyframes: [
    {
      startFrame: 0,
      endFrame: durationInFrames,
      startCenter: [-9.13, 38.72],
      endCenter: [-9.13, 38.72],  // identical to startCenter
      startZoom: 14.5,
      endZoom: 14.5,              // identical to startZoom
      startPitch: 45,
      endPitch: 45,               // identical to startPitch
      startBearing: 0,
      endBearing: 0,
    },
  ],
});
```

NEVER skip `useMapboxCamera` for a static camera. Always call it — even with
identical start/end values. This ensures the camera is deterministically 
controlled by the hook on every frame.

## Animating lines

### Straight lines (linear interpolation)

To animate a line that appears straight on the map, use linear interpolation between coordinates. Do NOT use turf's `lineSliceAlong` or `along` functions, as they use geodesic (great circle) calculations which appear curved on a Mercator projection.

```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();

useEffect(() => {
  if (!map) return;

  const animationHandle = delayRender("Animating line...");

  const progress = interpolate(frame, [0, durationInFrames - 1], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.inOut(Easing.cubic),
  });

  // Linear interpolation for a straight line on the map
  const start = lineCoordinates[0];
  const end = lineCoordinates[1];
  const currentLng = start[0] + (end[0] - start[0]) * progress;
  const currentLat = start[1] + (end[1] - start[1]) * progress;

  const lineData: GeoJSON.Feature<GeoJSON.LineString> = {
    type: "Feature",
    properties: {},
    geometry: {
      type: "LineString",
      coordinates: [start, [currentLng, currentLat]],
    },
  };

  const source = map.getSource("trace") as mapboxgl.GeoJSONSource;
  if (source) {
    source.setData(lineData);
  }

  map.once("idle", () => continueRender(animationHandle));
}, [frame, map, durationInFrames]);
```

### Curved lines (geodesic/great circle)

To animate a line that follows the geodesic (great circle) path between two points, use turf's `lineSliceAlong`. This is useful for showing flight paths or the actual shortest distance on Earth.

```tsx
import * as turf from "@turf/turf";

const routeLine = turf.lineString(lineCoordinates);
const routeDistance = turf.length(routeLine);

const currentDistance = Math.max(0.001, routeDistance * progress);
const slicedLine = turf.lineSliceAlong(routeLine, 0, currentDistance);

const source = map.getSource("route") as mapboxgl.GeoJSONSource;
if (source) {
  source.setData(slicedLine);
}
```

## Markers

Add labels, and markers where appropriate.

```tsx
_map.addSource("markers", {
  type: "geojson",
  data: {
    type: "FeatureCollection",
    features: [
      {
        type: "Feature",
        properties: { name: "Point 1" },
        geometry: { type: "Point", coordinates: [-118.2437, 34.0522] },
      },
    ],
  },
});

_map.addLayer({
  id: "city-markers",
  type: "circle",
  source: "markers",
  paint: {
    "circle-radius": 40,
    "circle-color": "#FF4444",
    "circle-stroke-width": 4,
    "circle-stroke-color": "#FFFFFF",
  },
});

_map.addLayer({
  id: "labels",
  type: "symbol",
  source: "markers",
  layout: {
    "text-field": ["get", "name"],
    "text-font": ["DIN Pro Bold", "Arial Unicode MS Bold"],
    "text-size": 50,
    "text-offset": [0, 0.5],
    "text-anchor": "top",
  },
  paint: {
    "text-color": "#FFFFFF",
    "text-halo-color": "#000000",
    "text-halo-width": 2,
  },
});
```

Make sure they are big enough. Check the composition dimensions and scale the labels accordingly.

### Label size by zoom level

`text-size` must remain legible in the rendered export, regardless of map zoom.
Use this as your minimum reference for a 1920x1080 composition:

| Geographic scale | Typical zoom | Minimum text-size |
|---|---|---|
| Street / block | 15–18 | 28 |
| Neighborhood / district | 13–15 | 32 |
| City | 10–13 | 40 |
| Region / metro area | 7–10 | 44 |
| Country | 4–7 | 48 |
| Continental | 2–4 | 52 |

Do NOT reduce text-size to "fit" the zoom level. Labels must be readable 
at export resolution. If a label is too dense, reduce the number of labels 
instead of reducing the font size.

IMPORTANT: Keep the `text-offset` small enough so it is close to the marker. Consider the marker circle radius. For a circle radius of 40, this is a good offset:

```tsx
"text-offset": [0, 0.5],
```

## 3D buildings

To enable 3D buildings, use the following code:

```tsx
_map.setConfigProperty("basemap", "show3dObjects", true);
_map.setConfigProperty("basemap", "show3dLandmarks", true);
_map.setConfigProperty("basemap", "show3dBuildings", true);
```

## Map composition

### Map as protagonist
The map fills the full frame. Data elements (markers, routes, labels) live 
inside the Mapbox layer. UI overlays are minimal gradients.
Use when: the geography IS the content (journey, territory, exploration).

### Map as supporting element
The map occupies part of the frame; a data panel or overlay carries the 
main content. The map provides geographic context, not the story.
Structure:

```tsx
<AbsoluteFill>
  {/* Map — full canvas but visually contained by overlay */}
  <div ref={mapRef} style={{ width, height, position: "absolute" }} />
  
  {/* Heavy gradient on one side to "push" the map visually */}
  <div style={{
    position: "absolute", inset: 0,
    background: "linear-gradient(to right, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.3) 45%, transparent 70%)",
  }} />
  
  {/* Data panel lives in the opaque zone */}
  <div style={{ position: "absolute", left: "5%", top: "10%", width: "35%" }}>
    {/* charts, stats, labels */}
  </div>
</AbsoluteFill>
```

Use when: the user mentions "data", "statistics", "explain", or "the map 
should support / not be the focus."

## Rendering

When rendering a map animation, make sure to render with the following flags:

```
npx remotion render --gl=angle --concurrency=1
```
