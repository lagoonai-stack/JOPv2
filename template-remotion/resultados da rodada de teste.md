prompt:

Crie uma cena 3D com perspectiva dramática, como uma câmera baixa olhando para cima.

resultado: 

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
 \* Dramatic low-angle 3D scene with a camera looking upward.  
 \* Features towering geometric structures, cinematic lighting, and dynamic camera motion.  
 \* Creates a sense of scale and power through perspective manipulation.  
 \*/

const TowerMesh: React.FC\<{  
  frame: number;  
  fps: number;  
  position: \[number, number, number\];  
  color: string;  
  height: number;  
  delay: number;  
}\> \= ({ frame, fps, position, color, height, delay }) \=\> {  
  const scaleY \= spring({  
    frame: Math.max(0, frame \- delay),  
    fps,  
    config: { damping: 18, stiffness: 60 },  
  });

  return (  
    \<mesh position={\[position\[0\], position\[1\] \+ (height \* scaleY) / 2 \- height / 2, position\[2\]\]} scale={\[1, scaleY, 1\]}\>  
      \<boxGeometry args={\[0.8, height, 0.8\]} /\>  
      \<meshStandardMaterial color={color} metalness={0.6} roughness={0.3} /\>  
    \</mesh\>  
  );  
};

const FloatingRing: React.FC\<{ frame: number; radius: number; speed: number; y: number }\> \= ({  
  frame,  
  radius,  
  speed,  
  y,  
}) \=\> {  
  const rotation \= frame \* speed;  
  return (  
    \<mesh position={\[0, y, 0\]} rotation={\[Math.PI / 2 \+ Math.sin(frame \* 0.01) \* 0.2, rotation, 0\]}\>  
      \<torusGeometry args={\[radius, 0.04, 12, 80\]} /\>  
      \<meshStandardMaterial color="\#60A5FA" emissive="\#1D4ED8" emissiveIntensity={0.5} metalness={0.9} roughness={0.1} /\>  
    \</mesh\>  
  );  
};

const Scene3D: React.FC\<{ frame: number; fps: number }\> \= ({ frame, fps }) \=\> {  
  const cameraY \= interpolate(frame, \[0, 120\], \[-1.5, \-2.2\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  const cameraFOV \= interpolate(frame, \[0, 60\], \[85, 65\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.quad),  
  });

  const towers \= \[  
    { position: \[0, 0, 0\] as \[number, number, number\], color: "\#1E40AF", height: 8, delay: 0 },  
    { position: \[-2.2, 0, \-1\] as \[number, number, number\], color: "\#1E3A5F", height: 6, delay: 8 },  
    { position: \[2.2, 0, \-1\] as \[number, number, number\], color: "\#1E3A5F", height: 6.5, delay: 6 },  
    { position: \[-4.2, 0, \-2\] as \[number, number, number\], color: "\#0F2040", height: 5, delay: 14 },  
    { position: \[4.2, 0, \-2\] as \[number, number, number\], color: "\#0F2040", height: 5.5, delay: 12 },  
    { position: \[-1.1, 0, 1\] as \[number, number, number\], color: "\#172554", height: 4.5, delay: 18 },  
    { position: \[1.1, 0, 1\] as \[number, number, number\], color: "\#172554", height: 4, delay: 20 },  
  \];

  return (  
    \<ThreeCanvas  
      width={1920}  
      height={1080}  
      camera={{ position: \[0, cameraY, 5\], fov: cameraFOV, rotation: \[0.35, 0, 0\] }}  
    \>  
      {/\* Ambient light \*/}  
      \<ambientLight intensity={0.15} color="\#0a1628" /\>

      {/\* Key light from above \*/}  
      \<directionalLight position={\[0, 12, 2\]} intensity={1.4} color="\#60A5FA" castShadow /\>

      {/\* Rim light \*/}  
      \<directionalLight position={\[-5, 8, \-3\]} intensity={0.6} color="\#93C5FD" /\>

      {/\* Dramatic low fill \*/}  
      \<pointLight position={\[0, \-2, 4\]} intensity={1.2} color="\#1D4ED8" distance={12} /\>

      {/\* Accent glow \*/}  
      \<pointLight position={\[0, 5, 0\]} intensity={0.8} color="\#BFDBFE" distance={15} /\>

      {/\* Ground plane \*/}  
      \<mesh position={\[0, \-0.01, 0\]} rotation={\[-Math.PI / 2, 0, 0\]}\>  
        \<planeGeometry args={\[40, 40\]} /\>  
        \<meshStandardMaterial color="\#050D1A" metalness={0.9} roughness={0.2} /\>  
      \</mesh\>

      {/\* Grid lines on ground \*/}  
      \<gridHelper args={\[40, 30, "\#0F2D5E", "\#0A1E3F"\]} position={\[0, 0, 0\]} /\>

      {/\* Towers \*/}  
      {towers.map((tower, i) \=\> (  
        \<TowerMesh  
          key={i}  
          frame={frame}  
          fps={fps}  
          position={tower.position}  
          color={tower.color}  
          height={tower.height}  
          delay={tower.delay}  
        /\>  
      ))}

      {/\* Floating rings \*/}  
      \<FloatingRing frame={frame} radius={1.5} speed={0.008} y={3} /\>  
      \<FloatingRing frame={frame} radius={2.5} speed={-0.005} y={5} /\>  
      \<FloatingRing frame={frame} radius={0.8} speed={0.015} y={1.5} /\>

      {/\* Top beacon \*/}  
      \<pointLight  
        position={\[0, 8, 0\]}  
        intensity={interpolate(frame, \[0, 90, 120, 150\], \[0, 0, 1.5, 0.8\], {  
          extrapolateLeft: "clamp",  
          extrapolateRight: "clamp",  
        })}  
        color="\#93C5FD"  
        distance={10}  
      /\>  
    \</ThreeCanvas\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Dramatic low-angle 3D perspective scene.  
   \* A cinematic camera positioned below looks upward at towering structures.  
   \* Dynamic lighting, metallic materials, and floating rings create depth and atmosphere.  
   \*/  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  // ─── Theme ───────────────────────────────────────────────────────────  
  const THEME \= { archetype: "premium\_dark", pacing: "cinematic" };  
  const COLORS \= {  
    bg: "\#020912",  
    surface1: "\#0A1628",  
    text: "\#FFFFFF",  
    textMuted: "\#60A5FA",  
    accent: "\#3B82F6",  
  };  
  const TIMING \= { FADE\_IN: 20, TITLE\_IN: 40, SUB\_IN: 70 };

  // ─── Calculations ─────────────────────────────────────────────────────  
  const titleOpacity \= interpolate(frame, \[TIMING.TITLE\_IN, TIMING.TITLE\_IN \+ 30\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });  
  const titleY \= interpolate(frame, \[TIMING.TITLE\_IN, TIMING.TITLE\_IN \+ 30\], \[30, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  const subOpacity \= interpolate(frame, \[TIMING.SUB\_IN, TIMING.SUB\_IN \+ 25\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  const vignetteOpacity \= interpolate(frame, \[0, 30\], \[1, 0.6\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleSize \= Math.max(36, Math.round(width \* 0.055));  
  const subSize \= Math.max(14, Math.round(width \* 0.018));

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg }}\>  
      {/\* 3D Scene \*/}  
      \<AbsoluteFill\>  
        \<Scene3D frame={frame} fps={fps} /\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at center, transparent 30%, rgba(2,9,18,${vignetteOpacity}) 100%)\`,  
          zIndex: 2,  
        }}  
      /\>

      {/\* Bottom gradient for text readability \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`linear-gradient(to top, rgba(2,9,18,0.9) 0%, rgba(2,9,18,0.3) 40%, transparent 70%)\`,  
          zIndex: 3,  
        }}  
      /\>

      {/\* Top gradient \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`linear-gradient(to bottom, rgba(2,9,18,0.5) 0%, transparent 30%)\`,  
          zIndex: 3,  
        }}  
      /\>

      {/\* UI Text Layer \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          flexDirection: "column",  
          justifyContent: "flex-end",  
          alignItems: "flex-start",  
          padding: \`0 ${Math.round(width \* 0.06)}px ${Math.round(height \* 0.1)}px\`,  
          zIndex: 10,  
        }}  
      \>  
        {/\* Eyebrow label \*/}  
        \<div  
          style={{  
            opacity: subOpacity,  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(10, Math.round(width \* 0.011)),  
            fontWeight: 500,  
            letterSpacing: "0.25em",  
            color: COLORS.accent,  
            textTransform: "uppercase" as const,  
            marginBottom: Math.round(height \* 0.015),  
          }}  
        \>  
          Perspectiva Dramática  
        \</div\>

        {/\* Main title \*/}  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            fontFamily: "Inter, sans-serif",  
            fontSize: titleSize,  
            fontWeight: 800,  
            letterSpacing: "-0.02em",  
            lineHeight: 1.05,  
            color: COLORS.text,  
            maxWidth: Math.round(width \* 0.55),  
            marginBottom: Math.round(height \* 0.02),  
          }}  
        \>  
          OLHANDO{" "}  
          \<span  
            style={{  
              background: \`linear-gradient(135deg, \#60A5FA, \#93C5FD, \#BFDBFE)\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            PARA O ALTO  
          \</span\>  
        \</div\>

        {/\* Subtitle \*/}  
        \<div  
          style={{  
            opacity: subOpacity,  
            fontFamily: "Inter, sans-serif",  
            fontSize: subSize,  
            fontWeight: 400,  
            letterSpacing: "0.01em",  
            lineHeight: 1.5,  
            color: COLORS.textMuted,  
            maxWidth: Math.round(width \* 0.4),  
          }}  
        \>  
          Câmera baixa · Ângulo dramático · Iluminação cinematográfica  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Scan line accent \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          overflow: "hidden",  
        }}  
      \>  
        \<div  
          style={{  
            position: "absolute",  
            left: Math.round(width \* 0.06),  
            top: "50%",  
            right: Math.round(width \* 0.06),  
            height: 1,  
            background: \`linear-gradient(to right, transparent, ${COLORS.accent}44, transparent)\`,  
            opacity: interpolate(frame, \[80, 100, 150, 170\], \[0, 0.4, 0.4, 0\], {  
              extrapolateLeft: "clamp",  
              extrapolateRight: "clamp",  
            }),  
          }}  
        /\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D onde a câmera está posicionada rente ao chão olhando para um objeto acima, com FOV amplo para efeito dramático.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import \* as THREE from "three";

/\* Floating monolith scene viewed from ground level with dramatic wide-angle camera.  
   A towering geometric monolith rises above the camera with atmospheric depth effects.  
   The camera is positioned at ground level looking upward for a cinematic, awe-inspiring composition. \*/

const MonolithScene: React.FC\<{ frame: number; fps: number }\> \= ({ frame, fps }) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 60, mass: 1.2 },  
    durationInFrames: 90,  
  });

  const floatY \= Math.sin(frame \* 0.025) \* 0.18;  
  const rotationY \= frame \* 0.008;  
  const glowPulse \= Math.sin(frame \* 0.04) \* 0.5 \+ 0.5;

  // Rings rotation  
  const ring1Rot \= frame \* 0.015;  
  const ring2Rot \= \-frame \* 0.012;  
  const ring3Rot \= frame \* 0.009;

  const monolithH \= 5 \* scaleProgress;  
  const monolithY \= 2.5 \* scaleProgress \+ floatY \+ 0.8;

  return (  
    \<\>  
      {/\* Ambient \+ directional lighting \*/}  
      \<ambientLight intensity={0.15} color="\#0a0a2a" /\>  
      \<directionalLight position={\[3, 8, 2\]} intensity={1.2} color="\#a78bfa" /\>  
      \<directionalLight position={\[-4, 6, \-3\]} intensity={0.6} color="\#60a5fa" /\>  
      \<pointLight position={\[0, monolithY, 0\]} intensity={2.5 \+ glowPulse \* 1.5} color="\#c4b5fd" distance={18} decay={2} /\>  
      \<pointLight position={\[0, 0.3, 0\]} intensity={1.8 \+ glowPulse \* 0.8} color="\#818cf8" distance={10} decay={2} /\>  
      \<spotLight  
        position={\[0, 12, 0\]}  
        angle={0.3}  
        penumbra={0.8}  
        intensity={3}  
        color="\#e9d5ff"  
        target-position={\[0, 0, 0\]}  
      /\>

      {/\* Ground plane \*/}  
      \<mesh rotation={\[-Math.PI / 2, 0, 0\]} position={\[0, 0, 0\]} receiveShadow\>  
        \<planeGeometry args={\[60, 60, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color="\#050510"  
          metalness={0.9}  
          roughness={0.1}  
          envMapIntensity={1}  
        /\>  
      \</mesh\>

      {/\* Ground glow disc \*/}  
      \<mesh rotation={\[-Math.PI / 2, 0, 0\]} position={\[0, 0.01, 0\]}\>  
        \<circleGeometry args={\[3, 64\]} /\>  
        \<meshBasicMaterial  
          color="\#7c3aed"  
          transparent  
          opacity={0.12 \+ glowPulse \* 0.08}  
        /\>  
      \</mesh\>

      {/\* Main monolith \*/}  
      \<mesh position={\[0, monolithY, 0\]} rotation={\[0, rotationY, 0\]} castShadow\>  
        \<boxGeometry args={\[1.1, monolithH, 0.5\]} /\>  
        \<meshStandardMaterial  
          color="\#1e1b4b"  
          metalness={0.95}  
          roughness={0.05}  
          envMapIntensity={2}  
        /\>  
      \</mesh\>

      {/\* Monolith face glow strip \*/}  
      \<mesh position={\[0, monolithY, 0.255 \+ 0.001\]} rotation={\[0, rotationY, 0\]}\>  
        \<planeGeometry args={\[0.08, monolithH \* 0.85\]} /\>  
        \<meshBasicMaterial  
          color="\#a78bfa"  
          transparent  
          opacity={0.6 \+ glowPulse \* 0.3}  
        /\>  
      \</mesh\>

      {/\* Orbital rings \*/}  
      \<mesh position={\[0, monolithY, 0\]} rotation={\[Math.PI / 3, ring1Rot, 0\]}\>  
        \<torusGeometry args={\[1.8, 0.025, 16, 80\]} /\>  
        \<meshBasicMaterial color="\#818cf8" transparent opacity={0.7} /\>  
      \</mesh\>

      \<mesh position={\[0, monolithY, 0\]} rotation={\[Math.PI / 6, ring2Rot, Math.PI / 4\]}\>  
        \<torusGeometry args={\[2.4, 0.018, 16, 80\]} /\>  
        \<meshBasicMaterial color="\#c4b5fd" transparent opacity={0.5} /\>  
      \</mesh\>

      \<mesh position={\[0, monolithY, 0\]} rotation={\[Math.PI / 2, ring3Rot, Math.PI / 6\]}\>  
        \<torusGeometry args={\[3.0, 0.012, 16, 80\]} /\>  
        \<meshBasicMaterial color="\#60a5fa" transparent opacity={0.35} /\>  
      \</mesh\>

      {/\* Floating particles around monolith \*/}  
      {\[...Array(8)\].map((\_, i) \=\> {  
        const angle \= (i / 8\) \* Math.PI \* 2 \+ frame \* 0.02;  
        const r \= 1.2 \+ Math.sin(i \* 1.3) \* 0.4;  
        const py \= monolithY \+ Math.sin(frame \* 0.03 \+ i \* 0.8) \* 1.2;  
        return (  
          \<mesh key={i} position={\[Math.cos(angle) \* r, py, Math.sin(angle) \* r\]}\>  
            \<sphereGeometry args={\[0.04, 8, 8\]} /\>  
            \<meshBasicMaterial  
              color={i % 2 \=== 0 ? "\#a78bfa" : "\#60a5fa"}  
              transparent  
              opacity={0.7 \+ Math.sin(frame \* 0.05 \+ i) \* 0.3}  
            /\>  
          \</mesh\>  
        );  
      })}

      {/\* Ground grid lines \*/}  
      {\[-6, \-4, \-2, 0, 2, 4, 6\].map((x, i) \=\> (  
        \<mesh key={\`gx-${i}\`} position={\[x, 0.005, 0\]} rotation={\[-Math.PI / 2, 0, 0\]}\>  
          \<planeGeometry args={\[0.012, 30\]} /\>  
          \<meshBasicMaterial color="\#312e81" transparent opacity={0.4} /\>  
        \</mesh\>  
      ))}  
      {\[-6, \-4, \-2, 0, 2, 4, 6\].map((z, i) \=\> (  
        \<mesh key={\`gz-${i}\`} position={\[0, 0.005, z\]} rotation={\[-Math.PI / 2, 0, Math.PI / 2\]}\>  
          \<planeGeometry args={\[0.012, 30\]} /\>  
          \<meshBasicMaterial color="\#312e81" transparent opacity={0.4} /\>  
        \</mesh\>  
      ))}

      {/\* Fog sphere for atmosphere \*/}  
      \<mesh position={\[0, 0, 0\]}\>  
        \<sphereGeometry args={\[25, 16, 16\]} /\>  
        \<meshBasicMaterial  
          color="\#050510"  
          transparent  
          opacity={0.5}  
          side={THREE.BackSide}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\* Camera positioned at ground level (y=0.18) looking upward at a towering monolith.  
     Wide FOV of 95° creates dramatic perspective distortion and sense of scale.  
     Atmospheric purple/indigo lighting enhances the cinematic, otherworldly mood. \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ─── THEME TOKENS ───  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0b0b1e",  
    text: "\#FFFFFF",  
    textMuted: "\#a5b4fc",  
    accent: "\#a78bfa",  
    accentAlt: "\#60a5fa",  
  };  
  const TIMING \= { FADE\_IN: 20, TITLE\_START: 40, TITLE\_FADE: 30 };  
  const TEXT \= {  
    eyebrow: "YEAR 2247",  
    title: "THE MONOLITH",  
    sub: "First Contact Initiative",  
  };

  // ─── CALCULATIONS ───  
  const titleFontSize \= Math.max(36, Math.round(width \* 0.075));  
  const eyebrowSize \= Math.max(11, Math.round(width \* 0.014));  
  const subSize \= Math.max(13, Math.round(width \* 0.018));

  const bgOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleOpacity \= interpolate(  
    frame,  
    \[TIMING.TITLE\_START, TIMING.TITLE\_START \+ TIMING.TITLE\_FADE\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const titleY \= interpolate(  
    frame,  
    \[TIMING.TITLE\_START, TIMING.TITLE\_START \+ TIMING.TITLE\_FADE\],  
    \[30, 0\],  
    {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
      easing: Easing.out(Easing.cubic),  
    }  
  );

  const eyebrowOpacity \= interpolate(  
    frame,  
    \[TIMING.TITLE\_START \+ 15, TIMING.TITLE\_START \+ 45\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const subOpacity \= interpolate(  
    frame,  
    \[TIMING.TITLE\_START \+ 25, TIMING.TITLE\_START \+ 55\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const scanlineY \= interpolate(frame, \[0, durationInFrames\], \[0, height \* 1.5\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const vignetteOpacity \= 0.55 \+ Math.sin(frame \* 0.015) \* 0.05;  
  const glowPulse \= Math.sin(frame \* 0.04) \* 0.5 \+ 0.5;

  return (  
    \<AbsoluteFill style={{ backgroundColor: COLORS.bg, opacity: bgOpacity }}\>  
      {/\* 3D Scene \*/}  
      \<AbsoluteFill style={{ zIndex: 0 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{  
            position: \[0, 0.18, 2.2\],  
            fov: 95,  
            near: 0.01,  
            far: 100,  
            rotation: \[-0.08, 0, 0\],  
          }}  
        \>  
          \<MonolithScene frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          background:  
            "radial-gradient(ellipse at center, transparent 30%, rgba(5,5,16,0.75) 80%, rgba(5,5,16,0.95) 100%)",  
          pointerEvents: "none",  
          opacity: vignetteOpacity,  
        }}  
      /\>

      {/\* Scanline atmosphere \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 6,  
          overflow: "hidden",  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            position: "absolute",  
            left: 0,  
            right: 0,  
            top: scanlineY \- 120,  
            height: 120,  
            background:  
              "linear-gradient(to bottom, transparent 0%, rgba(167,139,250,0.03) 50%, transparent 100%)",  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* Horizontal accent lines \*/}  
      \<AbsoluteFill style={{ zIndex: 7, pointerEvents: "none" }}\>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.25),  
            left: Math.round(width \* 0.05),  
            right: Math.round(width \* 0.05),  
            height: 1,  
            background:  
              "linear-gradient(to right, transparent, rgba(167,139,250,0.4), transparent)",  
            opacity: eyebrowOpacity,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* UI Text Overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 10,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-end",  
          paddingBottom: Math.round(height \* 0.1),  
          pointerEvents: "none",  
        }}  
      \>  
        {/\* Eyebrow \*/}  
        \<div  
          style={{  
            opacity: eyebrowOpacity,  
            marginBottom: Math.round(height \* 0.012),  
            display: "flex",  
            alignItems: "center",  
            gap: 10,  
          }}  
        \>  
          \<div  
            style={{  
              width: Math.round(width \* 0.04),  
              height: 1,  
              background: COLORS.accentAlt,  
              opacity: 0.8,  
            }}  
          /\>  
          \<span  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: eyebrowSize,  
              fontWeight: 600,  
              letterSpacing: "0.25em",  
              color: COLORS.accentAlt,  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.eyebrow}  
          \</span\>  
          \<div  
            style={{  
              width: Math.round(width \* 0.04),  
              height: 1,  
              background: COLORS.accentAlt,  
              opacity: 0.8,  
            }}  
          /\>  
        \</div\>

        {/\* Main Title \*/}  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            marginBottom: Math.round(height \* 0.015),  
          }}  
        \>  
          \<h1  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: titleFontSize,  
              fontWeight: 800,  
              letterSpacing: "-0.02em",  
              lineHeight: 1.05,  
              margin: 0,  
              textAlign: "center",  
              background: \`linear-gradient(135deg, \#FFFFFF 0%, ${COLORS.accent} 50%, ${COLORS.accentAlt} 100%)\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            {TEXT.title}  
          \</h1\>  
        \</div\>

        {/\* Subtitle \*/}  
        \<div  
          style={{  
            opacity: subOpacity,  
            display: "flex",  
            alignItems: "center",  
            gap: 8,  
          }}  
        \>  
          \<div  
            style={{  
              width: 4,  
              height: 4,  
              borderRadius: "50%",  
              backgroundColor: COLORS.accent,  
              opacity: 0.7 \+ glowPulse \* 0.3,  
            }}  
          /\>  
          \<span  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: subSize,  
              fontWeight: 400,  
              letterSpacing: "0.12em",  
              color: COLORS.textMuted,  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.sub}  
          \</span\>  
          \<div  
            style={{  
              width: 4,  
              height: 4,  
              borderRadius: "50%",  
              backgroundColor: COLORS.accent,  
              opacity: 0.7 \+ glowPulse \* 0.3,  
            }}  
          /\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Corner HUD elements \*/}  
      \<AbsoluteFill style={{ zIndex: 10, pointerEvents: "none", opacity: eyebrowOpacity }}\>  
        {/\* Top-left \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.05),  
            left: Math.round(width \* 0.05),  
            display: "flex",  
            flexDirection: "column",  
            gap: 4,  
          }}  
        \>  
          \<div style={{ width: 24, height: 2, backgroundColor: COLORS.accent, opacity: 0.6 }} /\>  
          \<div style={{ width: 2, height: 20, backgroundColor: COLORS.accent, opacity: 0.6 }} /\>  
        \</div\>  
        {/\* Top-right \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.05),  
            right: Math.round(width \* 0.05),  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "flex-end",  
            gap: 4,  
          }}  
        \>  
          \<div style={{ width: 24, height: 2, backgroundColor: COLORS.accent, opacity: 0.6 }} /\>  
          \<div style={{ width: 2, height: 20, backgroundColor: COLORS.accent, opacity: 0.6, alignSelf: "flex-end" }} /\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Coordinate readout \*/}  
      \<AbsoluteFill style={{ zIndex: 10, pointerEvents: "none", opacity: subOpacity }}\>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.05),  
            left: Math.round(width \* 0.05),  
            fontFamily: "monospace",  
            fontSize: Math.max(9, Math.round(width \* 0.011)),  
            color: COLORS.textMuted,  
            opacity: 0.5,  
            letterSpacing: "0.05em",  
          }}  
        \>  
          CAM 0.00° 0.18Y · FOV 95° · WIDE  
        \</div\>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.05),  
            right: Math.round(width \* 0.05),  
            fontFamily: "monospace",  
            fontSize: Math.max(9, Math.round(width \* 0.011)),  
            color: COLORS.textMuted,  
            opacity: 0.5,  
            letterSpacing: "0.05em",  
          }}  
        \>  
          OBJ.ALT \+{(5.5 \+ Math.sin(frame \* 0.025) \* 0.18).toFixed(2)}m  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma cena 3D onde um objeto aparece com fade-in suave e a câmera está levemente inclinada.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
  A cinematic 3D scene featuring a geometric object with a smooth fade-in entrance.  
  The camera is slightly tilted for a dramatic, premium composition.  
  Soft ambient and directional lighting create depth and surface detail.  
\*/

const FloatingGem \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 200, stiffness: 100 },  
    durationInFrames: 90,  
  });

  const rotationY \= frame \* 0.012;  
  const rotationX \= Math.sin(frame \* 0.018) \* 0.15;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.12;

  return (  
    \<\>  
      {/\* Lighting rig \*/}  
      \<ambientLight intensity={0.3} color="\#8080FF" /\>  
      \<directionalLight position={\[5, 8, 5\]} intensity={1.2} color="\#FFFFFF" /\>  
      \<directionalLight position={\[-4, \-2, \-3\]} intensity={0.4} color="\#60A5FA" /\>  
      \<pointLight position={\[0, 0, 4\]} intensity={0.6} color="\#34D399" /\>

      {/\* Main icosahedron gem \*/}  
      \<mesh  
        rotation={\[rotationX, rotationY, 0.25\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<icosahedronGeometry args={\[1.2, 1\]} /\>  
        \<meshStandardMaterial  
          color="\#1A1A2E"  
          metalness={0.85}  
          roughness={0.1}  
          emissive="\#2244AA"  
          emissiveIntensity={0.3}  
        /\>  
      \</mesh\>

      {/\* Inner wireframe \*/}  
      \<mesh  
        rotation={\[rotationX, rotationY \* 1.3, 0.25\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleProgress \* 1.04, scaleProgress \* 1.04, scaleProgress \* 1.04\]}  
      \>  
        \<icosahedronGeometry args={\[1.2, 1\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" wireframe opacity={0.25} transparent /\>  
      \</mesh\>

      {/\* Outer halo ring \*/}  
      \<mesh  
        rotation={\[1.2, rotationY \* 0.6, 0\]}  
        position={\[0, floatY \* 0.5, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<torusGeometry args={\[1.9, 0.025, 8, 64\]} /\>  
        \<meshBasicMaterial color="\#34D399" opacity={0.5} transparent /\>  
      \</mesh\>

      {/\* Secondary halo ring \*/}  
      \<mesh  
        rotation={\[0.4, rotationY \* 0.4 \+ 1.0, 0.8\]}  
        position={\[0, floatY \* 0.3, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<torusGeometry args={\[2.15, 0.015, 8, 64\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" opacity={0.3} transparent /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const ThreeDScene \= () \=\> {  
  /\*  
    Main composition component that orchestrates the 3D scene, background,  
    and overlay text elements with coordinated fade-in timing.  
  \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // ─── Theme Tokens ───────────────────────────────────────────────  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accentGreen: "\#34D399",  
  };  
  const TIMING \= { FADE\_IN: 40, HOLD: 60, TEXT\_DELAY: 50 };

  // ─── Derived values ──────────────────────────────────────────────  
  const sceneOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleOpacity \= interpolate(  
    frame,  
    \[TIMING.TEXT\_DELAY, TIMING.TEXT\_DELAY \+ 30\],  
    \[0, 1\],  
    {  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    }  
  );

  const titleY \= interpolate(  
    frame,  
    \[TIMING.TEXT\_DELAY, TIMING.TEXT\_DELAY \+ 40\],  
    \[24, 0\],  
    {  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    }  
  );

  const subtitleOpacity \= interpolate(  
    frame,  
    \[TIMING.TEXT\_DELAY \+ 20, TIMING.TEXT\_DELAY \+ 50\],  
    \[0, 1\],  
    {  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    }  
  );

  const subtitleY \= interpolate(  
    frame,  
    \[TIMING.TEXT\_DELAY \+ 20, TIMING.TEXT\_DELAY \+ 55\],  
    \[16, 0\],  
    {  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    }  
  );

  const badgeScale \= spring({  
    frame: frame \- (TIMING.TEXT\_DELAY \+ 40),  
    fps,  
    config: { damping: 12, stiffness: 150 },  
  });

  // Tilted camera offset (simulated via scene tilt)  
  const cameraX \= 0.4;  
  const cameraY \= 0.6;  
  const cameraZ \= 4.5;

  const titleFontSize \= Math.max(28, Math.round(width \* 0.048));  
  const subtitleFontSize \= Math.max(14, Math.round(width \* 0.018));  
  const badgeFontSize \= Math.max(11, Math.round(width \* 0.013));

  return (  
    \<AbsoluteFill style={{ backgroundColor: COLORS.bg, overflow: "hidden" }}\>  
      {/\* ── Background gradient ── \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 80% 60% at 55% 45%, \#0D1B3E 0%, \#050510 65%)\`,  
          opacity: sceneOpacity,  
        }}  
      /\>

      {/\* ── Subtle grid overlay ── \*/}  
      \<AbsoluteFill  
        style={{  
          opacity: sceneOpacity \* 0.08,  
          backgroundImage: \`  
            linear-gradient(rgba(96, 165, 250, 0.6) 1px, transparent 1px),  
            linear-gradient(90deg, rgba(96, 165, 250, 0.6) 1px, transparent 1px)  
          \`,  
          backgroundSize: \`${Math.round(width \* 0.06)}px ${Math.round(width \* 0.06)}px\`,  
        }}  
      /\>

      {/\* ── 3D Canvas ── \*/}  
      \<AbsoluteFill style={{ opacity: sceneOpacity }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{  
            position: \[cameraX, cameraY, cameraZ\],  
            fov: 60,  
            up: \[0, 1, 0\],  
          }}  
        \>  
          \<FloatingGem frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* ── Vignette ── \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 100% 100% at 50% 50%, transparent 40%, rgba(5, 5, 16, 0.7) 100%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* ── Text overlay ── \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          flexDirection: "column",  
          justifyContent: "flex-end",  
          alignItems: "flex-start",  
          padding: \`${Math.round(height \* 0.07)}px ${Math.round(width \* 0.06)}px\`,  
          pointerEvents: "none",  
        }}  
      \>  
        {/\* Badge \*/}  
        \<div  
          style={{  
            opacity: subtitleOpacity,  
            transform: \`scale(${badgeScale})\`,  
            transformOrigin: "left center",  
            marginBottom: Math.round(height \* 0.018),  
          }}  
        \>  
          \<div  
            style={{  
              display: "inline-flex",  
              alignItems: "center",  
              gap: 8,  
              background: "rgba(52, 211, 153, 0.12)",  
              border: "1px solid rgba(52, 211, 153, 0.35)",  
              borderRadius: 100,  
              padding: \`6px 16px\`,  
            }}  
          \>  
            \<div  
              style={{  
                width: 7,  
                height: 7,  
                borderRadius: "50%",  
                backgroundColor: COLORS.accentGreen,  
              }}  
            /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: badgeFontSize,  
                fontWeight: 600,  
                letterSpacing: "0.1em",  
                textTransform: "uppercase",  
                color: COLORS.accentGreen,  
              }}  
            \>  
              3D Preview  
            \</span\>  
          \</div\>  
        \</div\>

        {/\* Title \*/}  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            marginBottom: Math.round(height \* 0.012),  
          }}  
        \>  
          \<h1  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: titleFontSize,  
              fontWeight: 800,  
              letterSpacing: "-0.02em",  
              lineHeight: 1.1,  
              color: COLORS.text,  
              margin: 0,  
              padding: 0,  
            }}  
          \>  
            Geometric{" "}  
            \<span  
              style={{  
                background: \`linear-gradient(90deg, ${COLORS.accent}, ${COLORS.accentGreen})\`,  
                WebkitBackgroundClip: "text",  
                WebkitTextFillColor: "transparent",  
              }}  
            \>  
              Crystal  
            \</span\>  
          \</h1\>  
        \</div\>

        {/\* Subtitle \*/}  
        \<div  
          style={{  
            opacity: subtitleOpacity,  
            transform: \`translateY(${subtitleY}px)\`,  
          }}  
        \>  
          \<p  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: subtitleFontSize,  
              fontWeight: 400,  
              letterSpacing: "0.01em",  
              lineHeight: 1.5,  
              color: COLORS.textMuted,  
              margin: 0,  
              padding: 0,  
              maxWidth: Math.round(width \* 0.4),  
            }}  
          \>  
            Cinematic 3D composition with a tilted camera perspective and smooth  
            fade-in entrance.  
          \</p\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* ── Top-right corner accent ── \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          justifyContent: "flex-end",  
          alignItems: "flex-start",  
          padding: \`${Math.round(height \* 0.05)}px ${Math.round(width \* 0.05)}px\`,  
          pointerEvents: "none",  
          opacity: subtitleOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "flex-end",  
            gap: 6,  
          }}  
        \>  
          \<div  
            style={{  
              width: Math.round(width \* 0.025),  
              height: 2,  
              background: \`linear-gradient(90deg, transparent, ${COLORS.accent})\`,  
              borderRadius: 2,  
            }}  
          /\>  
          \<div  
            style={{  
              width: Math.round(width \* 0.015),  
              height: 2,  
              background: \`linear-gradient(90deg, transparent, ${COLORS.accentGreen})\`,  
              borderRadius: 2,  
            }}  
          /\>  
          \<div  
            style={{  
              width: Math.round(width \* 0.01),  
              height: 2,  
              background: \`linear-gradient(90deg, transparent, ${COLORS.accent})\`,  
              opacity: 0.5,  
              borderRadius: 2,  
            }}  
          /\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma cena 3D com controles de câmera onde o usuário pode orbitar ao redor do objeto.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
  A premium 3D scene featuring a rotating geometric object with simulated camera orbit.  
  The camera smoothly orbits around a detailed geometric centerpiece using frame-based animation.  
  The scene includes dynamic lighting, particle accents, and a cinematic dark aesthetic.  
\*/

const OrbitalRings \= ({ frame }: { frame: number }) \=\> {  
  const ring1Rotation \= frame \* 0.015;  
  const ring2Rotation \= \-frame \* 0.012;  
  const ring3Rotation \= frame \* 0.009;

  return (  
    \<\>  
      {/\* Ring 1 \- horizontal \*/}  
      \<mesh rotation={\[Math.PI / 2, ring1Rotation, 0\]}\>  
        \<torusGeometry args={\[2.5, 0.04, 8, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#60A5FA"  
          emissive="\#60A5FA"  
          emissiveIntensity={0.6}  
          metalness={0.8}  
          roughness={0.2}  
        /\>  
      \</mesh\>

      {/\* Ring 2 \- tilted \*/}  
      \<mesh rotation={\[Math.PI / 4, ring2Rotation, 0\]}\>  
        \<torusGeometry args={\[3.2, 0.03, 8, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#34D399"  
          emissive="\#34D399"  
          emissiveIntensity={0.5}  
          metalness={0.8}  
          roughness={0.2}  
        /\>  
      \</mesh\>

      {/\* Ring 3 \- other tilt \*/}  
      \<mesh rotation={\[-Math.PI / 5, ring3Rotation, Math.PI / 6\]}\>  
        \<torusGeometry args={\[3.8, 0.025, 8, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#A78BFA"  
          emissive="\#A78BFA"  
          emissiveIntensity={0.4}  
          metalness={0.8}  
          roughness={0.2}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

const CoreObject \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const rotX \= frame \* 0.008;  
  const rotY \= frame \* 0.018;  
  const rotZ \= frame \* 0.005;

  return (  
    \<group rotation={\[rotX, rotY, rotZ\]} scale={\[scaleProgress, scaleProgress, scaleProgress\]}\>  
      {/\* Core icosahedron \*/}  
      \<mesh\>  
        \<icosahedronGeometry args={\[1, 1\]} /\>  
        \<meshStandardMaterial  
          color="\#1A1A2E"  
          emissive="\#2D2D5E"  
          emissiveIntensity={0.3}  
          metalness={0.9}  
          roughness={0.1}  
          wireframe={false}  
        /\>  
      \</mesh\>

      {/\* Wireframe overlay \*/}  
      \<mesh\>  
        \<icosahedronGeometry args={\[1.01, 1\]} /\>  
        \<meshStandardMaterial  
          color="\#60A5FA"  
          emissive="\#60A5FA"  
          emissiveIntensity={1}  
          wireframe={true}  
          transparent  
          opacity={0.7}  
        /\>  
      \</mesh\>

      {/\* Inner glow sphere \*/}  
      \<mesh\>  
        \<sphereGeometry args={\[0.6, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color="\#60A5FA"  
          emissive="\#60A5FA"  
          emissiveIntensity={2}  
          transparent  
          opacity={0.15}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const FloatingCubes \= ({ frame }: { frame: number }) \=\> {  
  const cubes \= \[  
    { pos: \[2.8, 0.5, 1.2\] as \[number, number, number\], size: 0.15, speed: 0.025, color: "\#34D399" },  
    { pos: \[-2.5, \-0.8, 1.5\] as \[number, number, number\], size: 0.12, speed: 0.02, color: "\#60A5FA" },  
    { pos: \[1.5, 2.2, \-1.8\] as \[number, number, number\], size: 0.18, speed: 0.03, color: "\#A78BFA" },  
    { pos: \[-1.8, 1.8, 2.0\] as \[number, number, number\], size: 0.1, speed: 0.022, color: "\#F472B6" },  
    { pos: \[2.2, \-1.5, \-2.2\] as \[number, number, number\], size: 0.14, speed: 0.018, color: "\#34D399" },  
    { pos: \[-2.8, 0.2, \-1.0\] as \[number, number, number\], size: 0.11, speed: 0.028, color: "\#60A5FA" },  
  \];

  return (  
    \<\>  
      {cubes.map((cube, i) \=\> {  
        const floatOffset \= Math.sin(frame \* cube.speed \+ i \* 1.2) \* 0.3;  
        return (  
          \<mesh  
            key={i}  
            position={\[cube.pos\[0\], cube.pos\[1\] \+ floatOffset, cube.pos\[2\]\]}  
            rotation={\[frame \* cube.speed \* 2, frame \* cube.speed \* 1.5, 0\]}  
          \>  
            \<boxGeometry args={\[cube.size, cube.size, cube.size\]} /\>  
            \<meshStandardMaterial  
              color={cube.color}  
              emissive={cube.color}  
              emissiveIntensity={0.8}  
              metalness={0.7}  
              roughness={0.3}  
            /\>  
          \</mesh\>  
        );  
      })}  
    \</\>  
  );  
};

const Scene3D \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  // Camera orbit calculation  
  const orbitSpeed \= 0.008;  
  const camAngle \= frame \* orbitSpeed;  
  const camRadius \= 8;  
  const camHeight \= Math.sin(frame \* 0.004) \* 1.5 \+ 1;

  const camX \= Math.sin(camAngle) \* camRadius;  
  const camZ \= Math.cos(camAngle) \* camRadius;

  return (  
    \<ThreeCanvas  
      width={1920}  
      height={1080}  
      camera={{  
        position: \[camX, camHeight, camZ\],  
        fov: 60,  
        near: 0.1,  
        far: 100,  
      }}  
    \>  
      {/\* Ambient lighting \*/}  
      \<ambientLight intensity={0.2} /\>

      {/\* Primary lights \*/}  
      \<pointLight position={\[5, 5, 5\]} intensity={1.5} color="\#60A5FA" /\>  
      \<pointLight position={\[-5, \-3, \-5\]} intensity={1.2} color="\#34D399" /\>  
      \<pointLight position={\[0, 8, 0\]} intensity={0.8} color="\#FFFFFF" /\>  
      \<pointLight position={\[0, \-8, 0\]} intensity={0.4} color="\#A78BFA" /\>

      {/\* Rim lighting \*/}  
      \<directionalLight position={\[-3, 2, \-3\]} intensity={0.5} color="\#F472B6" /\>

      {/\* Scene objects \*/}  
      \<CoreObject frame={frame} fps={fps} /\>  
      \<OrbitalRings frame={frame} /\>  
      \<FloatingCubes frame={frame} /\>

      {/\* Ground plane (subtle) \*/}  
      \<mesh position={\[0, \-4, 0\]} rotation={\[-Math.PI / 2, 0, 0\]}\>  
        \<circleGeometry args={\[12, 64\]} /\>  
        \<meshStandardMaterial  
          color="\#0A0A14"  
          metalness={0.8}  
          roughness={0.5}  
          transparent  
          opacity={0.6}  
        /\>  
      \</mesh\>  
    \</ThreeCanvas\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
    Premium dark 3D orbital camera animation with geometric centerpiece.  
    Smooth camera orbit combined with interactive-feel controls overlay.  
    Features wireframe icosahedron core, orbital rings, and floating accent cubes.  
  \*/

  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accent2: "\#34D399",  
    accent3: "\#A78BFA",  
  };

  const TIMING \= { FADE\_IN: 20, UI\_DELAY: 10, STAGGER: 6 };

  // UI fade in  
  const uiOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleSlide \= interpolate(frame, \[0, 25\], \[-30, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Orbit progress indicator  
  const orbitProgress \= (frame \* 0.008) / (2 \* Math.PI);  
  const orbitPercent \= ((orbitProgress % 1\) \* 100).toFixed(0);  
  const orbitAngleDeg \= Math.round((frame \* 0.008 \* 180\) / Math.PI) % 360;

  // Camera stats  
  const camAngle \= frame \* 0.008;  
  const camX \= (Math.sin(camAngle) \* 8).toFixed(2);  
  const camZ \= (Math.cos(camAngle) \* 8).toFixed(2);  
  const camY \= (Math.sin(frame \* 0.004) \* 1.5 \+ 1).toFixed(2);

  const BASE\_PADDING \= Math.round(width \* 0.025);  
  const FONT\_SIZE\_TITLE \= Math.max(14, Math.round(width \* 0.016));  
  const FONT\_SIZE\_SMALL \= Math.max(11, Math.round(width \* 0.011));  
  const FONT\_SIZE\_TINY \= Math.max(10, Math.round(width \* 0.009));

  return (  
    \<AbsoluteFill style={{ backgroundColor: COLORS.bg }}\>  
      {/\* 3D Scene \*/}  
      \<AbsoluteFill\>  
        \<Scene3D frame={frame} fps={fps} /\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background:  
            "radial-gradient(ellipse at center, transparent 40%, rgba(5,5,16,0.7) 100%)",  
          zIndex: 2,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Top bar \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: 0,  
          left: 0,  
          right: 0,  
          height: Math.round(height \* 0.09),  
          background:  
            "linear-gradient(180deg, rgba(5,5,16,0.9) 0%, rgba(5,5,16,0) 100%)",  
          zIndex: 10,  
          display: "flex",  
          alignItems: "center",  
          paddingLeft: BASE\_PADDING,  
          paddingRight: BASE\_PADDING,  
          justifyContent: "space-between",  
          opacity: uiOpacity,  
        }}  
      \>  
        {/\* Title \*/}  
        \<div  
          style={{  
            transform: \`translateY(${titleSlide}px)\`,  
            opacity: uiOpacity,  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: FONT\_SIZE\_TITLE,  
              fontWeight: 700,  
              color: COLORS.text,  
              letterSpacing: "0.12em",  
              textTransform: "uppercase",  
            }}  
          \>  
            3D Orbital Scene  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: FONT\_SIZE\_TINY,  
              fontWeight: 400,  
              color: COLORS.textMuted,  
              letterSpacing: "0.08em",  
              marginTop: 4,  
            }}  
          \>  
            INTERACTIVE CAMERA ORBIT SYSTEM  
          \</div\>  
        \</div\>

        {/\* Orbit indicator \*/}  
        \<div  
          style={{  
            display: "flex",  
            alignItems: "center",  
            gap: 16,  
            opacity: uiOpacity,  
          }}  
        \>  
          \<div  
            style={{  
              width: Math.round(width \* 0.05),  
              height: Math.round(width \* 0.05),  
              position: "relative",  
              display: "flex",  
              alignItems: "center",  
              justifyContent: "center",  
            }}  
          \>  
            {/\* Circular orbit track \*/}  
            \<svg  
              width={Math.round(width \* 0.05)}  
              height={Math.round(width \* 0.05)}  
              viewBox="0 0 60 60"  
              style={{ position: "absolute" }}  
            \>  
              \<circle  
                cx="30"  
                cy="30"  
                r="24"  
                fill="none"  
                stroke="rgba(96,165,250,0.15)"  
                strokeWidth="2"  
              /\>  
              \<circle  
                cx="30"  
                cy="30"  
                r="24"  
                fill="none"  
                stroke={COLORS.accent}  
                strokeWidth="2"  
                strokeLinecap="round"  
                strokeDasharray={\`${151 \* (parseInt(orbitPercent) / 100)} 151\`}  
                transform="rotate(-90 30 30)"  
              /\>  
              {/\* Camera dot \*/}  
              \<circle  
                cx={30 \+ 24 \* Math.sin((frame \* 0.008))}  
                cy={30 \- 24 \* Math.cos((frame \* 0.008))}  
                r="3"  
                fill={COLORS.accent}  
              /\>  
            \</svg\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: Math.max(8, Math.round(width \* 0.008)),  
                fontWeight: 700,  
                color: COLORS.accent,  
                textAlign: "center",  
              }}  
            \>  
              {orbitAngleDeg}°  
            \</div\>  
          \</div\>

          \<div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: FONT\_SIZE\_TINY,  
                fontWeight: 600,  
                color: COLORS.textMuted,  
                letterSpacing: "0.06em",  
                textTransform: "uppercase",  
              }}  
            \>  
              ORBIT  
            \</div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: FONT\_SIZE\_SMALL,  
                fontWeight: 700,  
                color: COLORS.text,  
              }}  
            \>  
              {orbitAngleDeg}° / 360°  
            \</div\>  
          \</div\>  
        \</div\>  
      \</div\>

      {/\* Left panel \- Camera Controls UI \*/}  
      \<div  
        style={{  
          position: "absolute",  
          left: BASE\_PADDING,  
          top: "50%",  
          transform: "translateY(-50%)",  
          zIndex: 10,  
          opacity: uiOpacity,  
          display: "flex",  
          flexDirection: "column",  
          gap: 12,  
        }}  
      \>  
        {/\* Panel header \*/}  
        \<div  
          style={{  
            background: "rgba(11,11,26,0.85)",  
            border: "1px solid rgba(96,165,250,0.2)",  
            borderRadius: 12,  
            padding: \`${Math.round(height \* 0.015)}px ${Math.round(width \* 0.012)}px\`,  
            backdropFilter: "blur(12px)",  
            minWidth: Math.round(width \* 0.13),  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: FONT\_SIZE\_TINY,  
              fontWeight: 600,  
              color: COLORS.accent,  
              letterSpacing: "0.1em",  
              textTransform: "uppercase",  
              marginBottom: 12,  
              borderBottom: "1px solid rgba(96,165,250,0.1)",  
              paddingBottom: 8,  
            }}  
          \>  
            Camera Position  
          \</div\>

          {\[  
            { label: "X", value: camX, color: "\#F87171" },  
            { label: "Y", value: camY, color: COLORS.accent2 },  
            { label: "Z", value: camZ, color: COLORS.accent },  
          \].map((axis, i) \=\> (  
            \<div  
              key={axis.label}  
              style={{  
                display: "flex",  
                justifyContent: "space-between",  
                alignItems: "center",  
                marginBottom: i \< 2 ? 8 : 0,  
              }}  
            \>  
              \<div  
                style={{  
                  display: "flex",  
                  alignItems: "center",  
                  gap: 6,  
                }}  
              \>  
                \<div  
                  style={{  
                    width: 3,  
                    height: 14,  
                    background: axis.color,  
                    borderRadius: 2,  
                  }}  
                /\>  
                \<span  
                  style={{  
                    fontFamily: "Inter, sans-serif",  
                    fontSize: FONT\_SIZE\_TINY,  
                    fontWeight: 500,  
                    color: COLORS.textMuted,  
                    letterSpacing: "0.06em",  
                  }}  
                \>  
                  {axis.label}  
                \</span\>  
              \</div\>  
              \<span  
                style={{  
                  fontFamily: "'SF Mono', 'Fira Code', monospace",  
                  fontSize: FONT\_SIZE\_TINY,  
                  fontWeight: 600,  
                  color: COLORS.text,  
                }}  
              \>  
                {axis.value}  
              \</span\>  
            \</div\>  
          ))}  
        \</div\>

        {/\* Controls reference \*/}  
        \<div  
          style={{  
            background: "rgba(11,11,26,0.75)",  
            border: "1px solid rgba(96,165,250,0.12)",  
            borderRadius: 10,  
            padding: \`${Math.round(height \* 0.012)}px ${Math.round(width \* 0.01)}px\`,  
            backdropFilter: "blur(12px)",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: FONT\_SIZE\_TINY,  
              fontWeight: 600,  
              color: COLORS.accent3,  
              letterSpacing: "0.1em",  
              textTransform: "uppercase",  
              marginBottom: 10,  
            }}  
          \>  
            Scene Objects  
          \</div\>

          {\[  
            { label: "Core", detail: "Icosahedron", color: COLORS.accent },  
            { label: "Ring A", detail: "r=2.5", color: COLORS.accent },  
            { label: "Ring B", detail: "r=3.2", color: COLORS.accent2 },  
            { label: "Ring C", detail: "r=3.8", color: COLORS.accent3 },  
            { label: "Cubes", detail: "×6 floating", color: "\#F472B6" },  
          \].map((obj) \=\> (  
            \<div  
              key={obj.label}  
              style={{  
                display: "flex",  
                justifyContent: "space-between",  
                alignItems: "center",  
                marginBottom: 6,  
              }}  
            \>  
              \<div  
                style={{  
                  display: "flex",  
                  alignItems: "center",  
                  gap: 6,  
                }}  
              \>  
                \<div  
                  style={{  
                    width: 6,  
                    height: 6,  
                    borderRadius: "50%",  
                    background: obj.color,  
                  }}  
                /\>  
                \<span  
                  style={{  
                    fontFamily: "Inter, sans-serif",  
                    fontSize: FONT\_SIZE\_TINY,  
                    color: COLORS.textMuted,  
                  }}  
                \>  
                  {obj.label}  
                \</span\>  
              \</div\>  
              \<span  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: FONT\_SIZE\_TINY,  
                  color: obj.color,  
                  opacity: 0.8,  
                }}  
              \>  
                {obj.detail}  
              \</span\>  
            \</div\>  
          ))}  
        \</div\>  
      \</div\>

      {/\* Right panel \- Orbit controls \*/}  
      \<div  
        style={{  
          position: "absolute",  
          right: BASE\_PADDING,  
          top: "50%",  
          transform: "translateY(-50%)",  
          zIndex: 10,  
          opacity: uiOpacity,  
          display: "flex",  
          flexDirection: "column",  
          gap: 12,  
        }}  
      \>  
        \<div  
          style={{  
            background: "rgba(11,11,26,0.85)",  
            border: "1px solid rgba(96,165,250,0.2)",  
            borderRadius: 12,  
            padding: \`${Math.round(height \* 0.015)}px ${Math.round(width \* 0.012)}px\`,  
            backdropFilter: "blur(12px)",  
            minWidth: Math.round(width \* 0.11),  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: FONT\_SIZE\_TINY,  
              fontWeight: 600,  
              color: COLORS.accent2,  
              letterSpacing: "0.1em",  
              textTransform: "uppercase",  
              marginBottom: 12,  
              borderBottom: "1px solid rgba(52,211,153,0.1)",  
              paddingBottom: 8,  
            }}  
          \>  
            Orbit Settings  
          \</div\>

          {\[  
            { label: "Speed", value: "0.008 r/f", bar: 0.4 },  
            { label: "Radius", value: "8.0 units", bar: 0.65 },  
            { label: "Tilt", value: "±1.5 units", bar: 0.3 },  
          \].map((setting) \=\> (  
            \<div key={setting.label} style={{ marginBottom: 12 }}\>  
              \<div  
                style={{  
                  display: "flex",  
                  justifyContent: "space-between",  
                  marginBottom: 4,  
                }}  
              \>  
                \<span  
                  style={{  
                    fontFamily: "Inter, sans-serif",  
                    fontSize: FONT\_SIZE\_TINY,  
                    color: COLORS.textMuted,  
                  }}  
                \>  
                  {setting.label}  
                \</span\>  
                \<span  
                  style={{  
                    fontFamily: "'SF Mono', monospace",  
                    fontSize: FONT\_SIZE\_TINY,  
                    color: COLORS.text,  
                    fontWeight: 600,  
                  }}  
                \>  
                  {setting.value}  
                \</span\>  
              \</div\>  
              \<div  
                style={{  
                  width: "100%",  
                  height: 3,  
                  background: "rgba(255,255,255,0.08)",  
                  borderRadius: 2,  
                  overflow: "hidden",  
                }}  
              \>  
                \<div  
                  style={{  
                    width: \`${setting.bar \* 100}%\`,  
                    height: "100%",  
                    background: COLORS.accent2,  
                    borderRadius: 2,  
                  }}  
                /\>  
              \</div\>  
            \</div\>  
          ))}

          {/\* Live orbit angle arc \*/}  
          \<div style={{ display: "flex", justifyContent: "center", marginTop: 4 }}\>  
            \<svg width={70} height={70} viewBox="0 0 70 70"\>  
              {/\* Track \*/}  
              \<circle  
                cx="35"  
                cy="35"  
                r="28"  
                fill="none"  
                stroke="rgba(52,211,153,0.12)"  
                strokeWidth="2"  
              /\>  
              {/\* Progress arc \*/}  
              \<circle  
                cx="35"  
                cy="35"  
                r="28"  
                fill="none"  
                stroke={COLORS.accent2}  
                strokeWidth="2.5"  
                strokeLinecap="round"  
                strokeDasharray={\`${176 \* (parseInt(orbitPercent) / 100)} 176\`}  
                transform="rotate(-90 35 35)"  
                opacity={0.9}  
              /\>  
              {/\* Camera indicator \*/}  
              \<circle  
                cx={35 \+ 28 \* Math.sin(frame \* 0.008)}  
                cy={35 \- 28 \* Math.cos(frame \* 0.008)}  
                r="4"  
                fill={COLORS.accent2}  
              /\>  
              {/\* Center dot \*/}  
              \<circle cx="35" cy="35" r="2" fill={COLORS.accent} opacity={0.5} /\>  
              \<text  
                x="35"  
                y="41"  
                textAnchor="middle"  
                fill={COLORS.accent2}  
                fontSize="8"  
                fontFamily="Inter, sans-serif"  
                fontWeight="700"  
              \>  
                {orbitPercent}%  
              \</text\>  
            \</svg\>  
          \</div\>  
        \</div\>

        {/\* FPS / Frame info \*/}  
        \<div  
          style={{  
            background: "rgba(11,11,26,0.7)",  
            border: "1px solid rgba(96,165,250,0.1)",  
            borderRadius: 10,  
            padding: \`${Math.round(height \* 0.01)}px ${Math.round(width \* 0.01)}px\`,  
            backdropFilter: "blur(8px)",  
          }}  
        \>  
          \<div  
            style={{  
              display: "flex",  
              gap: 16,  
              alignItems: "center",  
              justifyContent: "space-between",  
            }}  
          \>  
            \<div style={{ textAlign: "center" }}\>  
              \<div  
                style={{  
                  fontFamily: "'SF Mono', monospace",  
                  fontSize: FONT\_SIZE\_TITLE,  
                  fontWeight: 700,  
                  color: COLORS.accent,  
                  lineHeight: 1,  
                }}  
              \>  
                {fps}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: FONT\_SIZE\_TINY,  
                  color: COLORS.textMuted,  
                  textTransform: "uppercase",  
                  letterSpacing: "0.06em",  
                  marginTop: 2,  
                }}  
              \>  
                FPS  
              \</div\>  
            \</div\>  
            \<div  
              style={{  
                width: 1,  
                height: 28,  
                background: "rgba(255,255,255,0.1)",  
              }}  
            /\>  
            \<div style={{ textAlign: "center" }}\>  
              \<div  
                style={{  
                  fontFamily: "'SF Mono', monospace",  
                  fontSize: FONT\_SIZE\_TITLE,  
                  fontWeight: 700,  
                  color: COLORS.text,  
                  lineHeight: 1,  
                }}  
              \>  
                {frame}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: FONT\_SIZE\_TINY,  
                  color: COLORS.textMuted,  
                  textTransform: "uppercase",  
                  letterSpacing: "0.06em",  
                  marginTop: 2,  
                }}  
              \>  
                FRAME  
              \</div\>  
            \</div\>  
          \</div\>  
        \</div\>  
      \</div\>

      {/\* Bottom bar \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: 0,  
          left: 0,  
          right: 0,  
          height: Math.round(height \* 0.1),  
          background:  
            "linear-gradient(0deg, rgba(5,5,16,0.95) 0%, rgba(5,5,16,0) 100%)",  
          zIndex: 10,  
          display: "flex",  
          alignItems: "flex-end",  
          paddingBottom: Math.round(height \* 0.025),  
          paddingLeft: BASE\_PADDING,  
          paddingRight: BASE\_PADDING,  
          justifyContent: "space-between",  
          opacity: uiOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: FONT\_SIZE\_TINY,  
            color: COLORS.textMuted,  
            letterSpacing: "0.06em",  
          }}  
        \>  
          AUTO ORBIT ENABLED · SMOOTH CAMERA PATH · CONTINUOUS ROTATION  
        \</div\>

        {/\* Color legend \*/}  
        \<div style={{ display: "flex", gap: 16, alignItems: "center" }}\>  
          {\[  
            { label: "Ring A", color: COLORS.accent },  
            { label: "Ring B", color: COLORS.accent2 },  
            { label: "Ring C", color: COLORS.accent3 },  
          \].map((item) \=\> (  
            \<div  
              key={item.label}  
              style={{ display: "flex", alignItems: "center", gap: 5 }}  
            \>  
              \<div  
                style={{  
                  width: 20,  
                  height: 2,  
                  background: item.color,  
                  borderRadius: 1,  
                }}  
              /\>  
              \<span  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: FONT\_SIZE\_TINY,  
                  color: COLORS.textMuted,  
                }}  
              \>  
                {item.label}  
              \</span\>  
            \</div\>  
          ))}  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma cena 3D com um objeto que muda de cor gradualmente durante a animação.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  interpolateColors,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A 3D scene featuring a rotating geometric object (icosahedron) that smoothly  
 \* transitions through a vibrant color palette as the animation progresses.  
 \* The scene includes floating particles and dynamic lighting to enhance the visual depth.  
 \*/

const FloatingParticle \= ({  
  frame,  
  x,  
  y,  
  z,  
  delay,  
  color,  
}: {  
  frame: number;  
  x: number;  
  y: number;  
  z: number;  
  delay: number;  
  color: string;  
}) \=\> {  
  const floatY \= Math.sin((frame \+ delay) \* 0.05) \* 0.4;  
  const scale \= 0.08 \+ Math.sin((frame \+ delay) \* 0.08) \* 0.03;

  return (  
    \<mesh position={\[x, y \+ floatY, z\]} scale={\[scale, scale, scale\]}\>  
      \<sphereGeometry args={\[1, 8, 8\]} /\>  
      \<meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.6} /\>  
    \</mesh\>  
  );  
};

const MainObject \= ({  
  frame,  
  fps,  
  accentColor,  
}: {  
  frame: number;  
  fps: number;  
  accentColor: string;  
}) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const rotationY \= frame \* 0.018;  
  const rotationX \= frame \* 0.009;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.15;

  return (  
    \<group position={\[0, floatY, 0\]}\>  
      {/\* Main icosahedron \*/}  
      \<mesh  
        rotation={\[rotationX, rotationY, 0\]}  
        scale={\[scaleProgress \* 1.5, scaleProgress \* 1.5, scaleProgress \* 1.5\]}  
      \>  
        \<icosahedronGeometry args={\[1, 0\]} /\>  
        \<meshStandardMaterial  
          color={accentColor}  
          emissive={accentColor}  
          emissiveIntensity={0.2}  
          metalness={0.7}  
          roughness={0.2}  
        /\>  
      \</mesh\>

      {/\* Wireframe overlay \*/}  
      \<mesh  
        rotation={\[rotationX \* 1.3, rotationY \* 1.3, 0\]}  
        scale={\[scaleProgress \* 1.55, scaleProgress \* 1.55, scaleProgress \* 1.55\]}  
      \>  
        \<icosahedronGeometry args={\[1, 0\]} /\>  
        \<meshBasicMaterial color={accentColor} wireframe opacity={0.3} transparent /\>  
      \</mesh\>

      {/\* Inner glow sphere \*/}  
      \<mesh scale={\[scaleProgress \* 0.8, scaleProgress \* 0.8, scaleProgress \* 0.8\]}\>  
        \<sphereGeometry args={\[1, 16, 16\]} /\>  
        \<meshStandardMaterial  
          color={accentColor}  
          emissive={accentColor}  
          emissiveIntensity={0.5}  
          transparent  
          opacity={0.15}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const OrbitingRings \= ({  
  frame,  
  accentColor,  
  secondaryColor,  
}: {  
  frame: number;  
  accentColor: string;  
  secondaryColor: string;  
}) \=\> {  
  const ring1Rot \= frame \* 0.025;  
  const ring2Rot \= \-frame \* 0.018;  
  const ring3Rot \= frame \* 0.012;

  return (  
    \<\>  
      \<mesh rotation={\[Math.PI / 2 \+ ring1Rot, ring1Rot, 0\]}\>  
        \<torusGeometry args={\[2.2, 0.025, 8, 64\]} /\>  
        \<meshStandardMaterial color={accentColor} emissive={accentColor} emissiveIntensity={0.4} /\>  
      \</mesh\>  
      \<mesh rotation={\[ring2Rot, Math.PI / 4 \+ ring2Rot, 0\]}\>  
        \<torusGeometry args={\[2.6, 0.018, 8, 64\]} /\>  
        \<meshStandardMaterial  
          color={secondaryColor}  
          emissive={secondaryColor}  
          emissiveIntensity={0.4}  
        /\>  
      \</mesh\>  
      \<mesh rotation={\[Math.PI / 3, ring3Rot, Math.PI / 3 \+ ring3Rot\]}\>  
        \<torusGeometry args={\[3.0, 0.012, 8, 64\]} /\>  
        \<meshStandardMaterial color={accentColor} emissive={accentColor} emissiveIntensity={0.25} transparent opacity={0.6} /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Main composition component that orchestrates the 3D scene,  
   \* color transitions, and background gradient animations.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ─── Theme ───────────────────────────────────────────────────────────  
  const COLORS \= {  
    bg: '\#050510',  
    surface1: '\#0B0B1A',  
    text: '\#FFFFFF',  
    textMuted: '\#A0A0B8',  
  };

  const TIMING \= { BASE: fps, FADE\_IN: Math.round(fps \* 0.5) };

  // ─── Color Cycle ─────────────────────────────────────────────────────  
  const colorStops \= \[  
    '\#00FF88',  
    '\#00AAFF',  
    '\#8B5CF6',  
    '\#F59E0B',  
    '\#EF4444',  
    '\#EC4899',  
    '\#00FF88',  
  \];

  const colorProgress \= frame / durationInFrames;  
  const numSegments \= colorStops.length \- 1;  
  const segmentIndex \= Math.min(  
    Math.floor(colorProgress \* numSegments),  
    numSegments \- 1  
  );  
  const segmentProgress \= (colorProgress \* numSegments) % 1;

  const accentColor \= interpolateColors(  
    segmentProgress,  
    \[0, 1\],  
    \[colorStops\[segmentIndex\], colorStops\[segmentIndex \+ 1\]\]  
  );

  const secondaryColor \= interpolateColors(  
    segmentProgress,  
    \[0, 1\],  
    \[colorStops\[(segmentIndex \+ 2\) % numSegments\], colorStops\[(segmentIndex \+ 3\) % numSegments\]\]  
  );

  // ─── Background gradient animation ──────────────────────────────────  
  const bgHue \= interpolate(frame, \[0, durationInFrames\], \[200, 340\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
  });

  // ─── Global opacity ──────────────────────────────────────────────────  
  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
  });

  // ─── UI Labels ───────────────────────────────────────────────────────  
  const colorPercent \= Math.round(colorProgress \* 100);  
  const titleSize \= Math.max(28, Math.round(width \* 0.04));  
  const subtitleSize \= Math.max(13, Math.round(width \* 0.017));  
  const badgeSize \= Math.max(11, Math.round(width \* 0.014));

  // Particle positions (static seed)  
  const particles \= \[  
    { x: \-3.5, y: 1.2, z: \-1.5, delay: 0 },  
    { x: 3.2, y: \-1.0, z: \-1.0, delay: 20 },  
    { x: \-2.8, y: \-1.8, z: 0.5, delay: 40 },  
    { x: 3.8, y: 1.5, z: 0.8, delay: 60 },  
    { x: \-1.0, y: 2.8, z: \-2.0, delay: 80 },  
    { x: 1.5, y: \-2.6, z: \-1.2, delay: 100 },  
    { x: \-4.0, y: 0.2, z: 0.3, delay: 120 },  
    { x: 4.2, y: \-0.5, z: \-0.8, delay: 140 },  
  \];

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, opacity: globalOpacity }}\>  
      {/\* Background radial gradients \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`  
            radial-gradient(ellipse 60% 50% at 20% 30%, ${accentColor}18 0%, transparent 70%),  
            radial-gradient(ellipse 50% 60% at 80% 70%, ${secondaryColor}12 0%, transparent 70%),  
            radial-gradient(ellipse 80% 80% at 50% 50%, ${COLORS.surface1} 0%, ${COLORS.bg} 100%)  
          \`,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 7\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.3} /\>  
          \<pointLight position={\[5, 5, 5\]} intensity={1.2} color={accentColor} /\>  
          \<pointLight position={\[-5, \-3, \-5\]} intensity={0.8} color={secondaryColor} /\>  
          \<pointLight position={\[0, 0, 8\]} intensity={0.4} color="\#FFFFFF" /\>

          {/\* Main 3D object \*/}  
          \<MainObject frame={frame} fps={fps} accentColor={accentColor} /\>

          {/\* Orbiting rings \*/}  
          \<OrbitingRings  
            frame={frame}  
            accentColor={accentColor}  
            secondaryColor={secondaryColor}  
          /\>

          {/\* Floating particles \*/}  
          {particles.map((p, i) \=\> (  
            \<FloatingParticle  
              key={i}  
              frame={frame}  
              x={p.x}  
              y={p.y}  
              z={p.z}  
              delay={p.delay}  
              color={i % 2 \=== 0 ? accentColor : secondaryColor}  
            /\>  
          ))}  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* UI Overlay \*/}  
      \<AbsoluteFill style={{ pointerEvents: 'none' }}\>  
        {/\* Title \*/}  
        \<div  
          style={{  
            position: 'absolute',  
            top: Math.round(height \* 0.07),  
            left: 0,  
            right: 0,  
            textAlign: 'center',  
            fontFamily: 'Inter, sans-serif',  
          }}  
        \>  
          \<div  
            style={{  
              fontSize: titleSize,  
              fontWeight: 700,  
              letterSpacing: '-0.02em',  
              color: COLORS.text,  
              textShadow: \`0 0 40px ${accentColor}60\`,  
              lineHeight: 1.2,  
            }}  
          \>  
            Chromatic{' '}  
            \<span  
              style={{  
                background: \`linear-gradient(90deg, ${accentColor}, ${secondaryColor})\`,  
                WebkitBackgroundClip: 'text',  
                WebkitTextFillColor: 'transparent',  
              }}  
            \>  
              Morph  
            \</span\>  
          \</div\>  
          \<div  
            style={{  
              fontSize: subtitleSize,  
              fontWeight: 400,  
              letterSpacing: '0.12em',  
              color: COLORS.textMuted,  
              marginTop: 8,  
              textTransform: 'uppercase',  
            }}  
          \>  
            3D Color Shift Animation  
          \</div\>  
        \</div\>

        {/\* Color indicator bottom bar \*/}  
        \<div  
          style={{  
            position: 'absolute',  
            bottom: Math.round(height \* 0.06),  
            left: Math.round(width \* 0.1),  
            right: Math.round(width \* 0.1),  
            display: 'flex',  
            flexDirection: 'column',  
            alignItems: 'center',  
            gap: 10,  
          }}  
        \>  
          {/\* Progress bar \*/}  
          \<div  
            style={{  
              width: '100%',  
              height: 3,  
              background: 'rgba(255,255,255,0.1)',  
              borderRadius: 4,  
              overflow: 'hidden',  
            }}  
          \>  
            \<div  
              style={{  
                height: '100%',  
                width: \`${colorPercent}%\`,  
                background: \`linear-gradient(90deg, ${colorStops\[0\]}, ${accentColor})\`,  
                borderRadius: 4,  
                transition: 'none',  
              }}  
            /\>  
          \</div\>

          {/\* Color swatches row \*/}  
          \<div style={{ display: 'flex', gap: 8, alignItems: 'center' }}\>  
            {colorStops.slice(0, \-1).map((c, i) \=\> (  
              \<div  
                key={i}  
                style={{  
                  width: i \=== segmentIndex ? 16 : 10,  
                  height: i \=== segmentIndex ? 16 : 10,  
                  borderRadius: '50%',  
                  background: c,  
                  boxShadow: i \=== segmentIndex ? \`0 0 10px ${c}\` : 'none',  
                  transition: 'none',  
                }}  
              /\>  
            ))}  
          \</div\>

          {/\* Current color hex badge \*/}  
          \<div  
            style={{  
              padding: '4px 14px',  
              borderRadius: 20,  
              background: 'rgba(255,255,255,0.06)',  
              border: \`1px solid ${accentColor}40\`,  
              fontFamily: 'monospace',  
              fontSize: badgeSize,  
              color: accentColor,  
              letterSpacing: '0.1em',  
              fontWeight: 600,  
            }}  
          \>  
            {accentColor.toUpperCase()}  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie um objeto 3D com uma luz que pisca.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A 3D metallic sphere with a pulsing, flickering light effect.  
 \* The light cycles through warm and cool tones while the sphere slowly rotates.  
 \* Ambient glow and point light intensity are driven by frame-based sine waves for organic flickering.  
 \*/

const Scene3D \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  // Flicker effect using sine waves at different frequencies  
  const flicker1 \= Math.sin(frame \* 0.3) \* 0.5 \+ 0.5;  
  const flicker2 \= Math.sin(frame \* 0.7 \+ 1.2) \* 0.3 \+ 0.7;  
  const flicker3 \= Math.sin(frame \* 1.1 \+ 0.5) \* 0.2 \+ 0.8;  
  const flickerIntensity \= flicker1 \* flicker2 \* flicker3;

  // Main light intensity pulsing  
  const mainLightIntensity \= 2.5 \+ flickerIntensity \* 3.5;  
  const fillLightIntensity \= 0.3 \+ flickerIntensity \* 0.4;

  // Light color cycling between warm and cool  
  const colorCycle \= Math.sin(frame \* 0.05) \* 0.5 \+ 0.5;  
  const warmR \= 1.0;  
  const warmG \= 0.6 \+ colorCycle \* 0.2;  
  const warmB \= 0.2 \+ colorCycle \* 0.6;

  // Sphere rotation  
  const rotY \= frame \* 0.018;  
  const rotX \= frame \* 0.007;

  // Scale entrance via spring  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  // Secondary orb that orbits  
  const orbAngle \= frame \* 0.04;  
  const orbX \= Math.cos(orbAngle) \* 2.2;  
  const orbZ \= Math.sin(orbAngle) \* 2.2;  
  const orbY \= Math.sin(orbAngle \* 0.5) \* 0.5;

  return (  
    \<\>  
      {/\* Ambient light \*/}  
      \<ambientLight intensity={0.15} /\>

      {/\* Main flickering point light \*/}  
      \<pointLight  
        position={\[3, 3, 3\]}  
        intensity={mainLightIntensity}  
        color={\[warmR, warmG, warmB\] as unknown as string}  
        distance={20}  
        decay={2}  
      /\>

      {/\* Rim light \- cool blue \*/}  
      \<pointLight  
        position={\[-3, \-2, \-2\]}  
        intensity={fillLightIntensity \* 2}  
        color="\#4488ff"  
        distance={15}  
        decay={2}  
      /\>

      {/\* Top fill light \*/}  
      \<directionalLight  
        position={\[0, 5, 2\]}  
        intensity={0.3 \+ flickerIntensity \* 0.2}  
        color="\#ffffff"  
      /\>

      {/\* Main sphere \*/}  
      \<mesh  
        rotation={\[rotX, rotY, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<sphereGeometry args={\[1.2, 64, 64\]} /\>  
        \<meshStandardMaterial  
          color="\#1a1a2e"  
          metalness={0.95}  
          roughness={0.05}  
        /\>  
      \</mesh\>

      {/\* Orbiting small orb (the "light source" object) \*/}  
      \<mesh position={\[orbX, orbY, orbZ\]}\>  
        \<sphereGeometry args={\[0.18, 16, 16\]} /\>  
        \<meshStandardMaterial  
          color={\`rgb(${Math.round(warmR \* 255)}, ${Math.round(warmG \* 255)}, ${Math.round(warmB \* 255)})\`}  
          emissive={\`rgb(${Math.round(warmR \* 255)}, ${Math.round(warmG \* 255)}, ${Math.round(warmB \* 255)})\`}  
          emissiveIntensity={3 \+ flickerIntensity \* 4}  
          metalness={0}  
          roughness={0}  
        /\>  
      \</mesh\>

      {/\* Orbiting light source aligned with orb \*/}  
      \<pointLight  
        position={\[orbX, orbY, orbZ\]}  
        intensity={mainLightIntensity \* 0.8}  
        color={\`rgb(${Math.round(warmR \* 255)}, ${Math.round(warmG \* 255)}, ${Math.round(warmB \* 255)})\`}  
        distance={10}  
        decay={2}  
      /\>

      {/\* Ground ring / disc \*/}  
      \<mesh rotation={\[-Math.PI / 2, 0, frame \* 0.01\]} position={\[0, \-1.6, 0\]}\>  
        \<torusGeometry args={\[2.0, 0.04, 16, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#334"  
          metalness={0.9}  
          roughness={0.1}  
          emissive="\#2244aa"  
          emissiveIntensity={0.2 \+ flickerIntensity \* 0.3}  
        /\>  
      \</mesh\>

      {/\* Outer decorative ring \*/}  
      \<mesh rotation={\[-Math.PI / 2 \+ 0.3, 0, \-frame \* 0.015\]} position={\[0, \-1.5, 0\]}\>  
        \<torusGeometry args={\[2.6, 0.025, 16, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#224"  
          metalness={0.85}  
          roughness={0.15}  
          emissive="\#aa4422"  
          emissiveIntensity={0.15 \+ flickerIntensity \* 0.25}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* A 3D metallic sphere with a pulsing, flickering light effect.  
   \* The light cycles through warm and cool tones while the sphere slowly rotates.  
   \* Ambient glow and point light intensity are driven by frame-based sine waves for organic flickering.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Design archetype: NEON/GLOW  
  const COLORS \= {  
    bg: '\#050510',  
    surface1: '\#0B0B1A',  
    text: '\#FFFFFF',  
    accent: '\#00FF88',  
    glow: '\#00AAFF',  
  };

  const TIMING \= { BASE: 15, FADE: 30 };

  // Background glow pulse  
  const glowPulse \= Math.sin(frame \* 0.08) \* 0.5 \+ 0.5;  
  const bgGlowOpacity \= 0.08 \+ glowPulse \* 0.06;

  // Flicker for UI elements  
  const uiFlicker \= Math.sin(frame \* 0.3) \* Math.sin(frame \* 0.7) \* 0.5 \+ 0.5;

  // Title fade in  
  const titleOpacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
  });  
  const titleY \= interpolate(frame, \[0, TIMING.FADE\], \[20, 0\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, \#0d0d2a 0%, ${COLORS.bg} 70%)\`,  
        fontFamily: 'Inter, sans-serif',  
      }}  
    \>  
      {/\* Background ambient glow \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 45%, rgba(100, 120, 255, ${bgGlowOpacity}) 0%, transparent 65%)\`,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<ThreeCanvas  
        width={width}  
        height={height}  
        camera={{ position: \[0, 1.2, 5.5\], fov: 60 }}  
      \>  
        \<Scene3D frame={frame} fps={fps} /\>  
      \</ThreeCanvas\>

      {/\* UI Overlay \- Title \*/}  
      \<AbsoluteFill  
        style={{  
          display: 'flex',  
          flexDirection: 'column',  
          alignItems: 'center',  
          justifyContent: 'flex-start',  
          paddingTop: Math.round(height \* 0.06),  
          pointerEvents: 'none',  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: 'center',  
          }}  
        \>  
          \<div  
            style={{  
              fontSize: Math.max(12, Math.round(width \* 0.012)),  
              fontWeight: 500,  
              letterSpacing: '0.25em',  
              color: COLORS.glow,  
              textTransform: 'uppercase',  
              opacity: 0.8 \+ uiFlicker \* 0.2,  
              marginBottom: '8px',  
            }}  
          \>  
            ◈ Pulsing Light Source ◈  
          \</div\>  
          \<div  
            style={{  
              fontSize: Math.max(28, Math.round(width \* 0.048)),  
              fontWeight: 800,  
              letterSpacing: '-0.02em',  
              lineHeight: 1.1,  
              background: \`linear-gradient(135deg, \#ffffff 0%, ${COLORS.glow} 50%, ${COLORS.accent} 100%)\`,  
              WebkitBackgroundClip: 'text',  
              WebkitTextFillColor: 'transparent',  
            }}  
          \>  
            LIGHT FLICKER  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Bottom label \*/}  
      \<AbsoluteFill  
        style={{  
          display: 'flex',  
          flexDirection: 'column',  
          alignItems: 'center',  
          justifyContent: 'flex-end',  
          paddingBottom: Math.round(height \* 0.06),  
          pointerEvents: 'none',  
        }}  
      \>  
        \<div  
          style={{  
            opacity: (titleOpacity \* (0.5 \+ uiFlicker \* 0.5)),  
            fontSize: Math.max(10, Math.round(width \* 0.009)),  
            fontWeight: 400,  
            letterSpacing: '0.15em',  
            color: COLORS.glow,  
            textTransform: 'uppercase',  
          }}  
        \>  
          Frame-Driven Intensity · Orbital Light Source  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma cena 3D com bloom effect e pós-processamento para dar um brilho dramático.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef, useMemo } from "react";  
import \* as THREE from "three";

/\*  
 \* Dramatic 3D scene with simulated bloom and post-processing glow effects.  
 \* Features rotating geometric shapes with CSS-based glow layers to simulate  
 \* the bloom effect, creating a cinematic neon aesthetic.  
 \*/

// Floating crystal shard component  
const CrystalShard \= ({  
  frame,  
  fps,  
  position,  
  rotation,  
  color,  
  delay \= 0,  
}: {  
  frame: number;  
  fps: number;  
  position: \[number, number, number\];  
  rotation: \[number, number, number\];  
  color: string;  
  delay?: number;  
}) \=\> {  
  const scaleProgress \= spring({  
    frame: Math.max(0, frame \- delay),  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const rotY \= frame \* 0.018 \+ rotation\[1\];  
  const rotX \= Math.sin(frame \* 0.012 \+ delay) \* 0.3 \+ rotation\[0\];  
  const floatY \= Math.sin(frame \* 0.05 \+ delay) \* 0.15;

  return (  
    \<mesh  
      position={\[position\[0\], position\[1\] \+ floatY, position\[2\]\]}  
      rotation={\[rotX, rotY, rotation\[2\]\]}  
      scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
    \>  
      \<octahedronGeometry args={\[0.5, 0\]} /\>  
      \<meshStandardMaterial  
        color={color}  
        emissive={color}  
        emissiveIntensity={1.2}  
        metalness={0.1}  
        roughness={0.05}  
        transparent  
        opacity={0.92}  
      /\>  
    \</mesh\>  
  );  
};

// Central orb  
const CentralOrb \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scale \= spring({ frame, fps, config: { damping: 18, stiffness: 60 } });  
  const pulse \= 1 \+ Math.sin(frame \* 0.08) \* 0.06;

  return (  
    \<mesh scale={\[scale \* pulse, scale \* pulse, scale \* pulse\]}\>  
      \<sphereGeometry args={\[0.7, 64, 64\]} /\>  
      \<meshStandardMaterial  
        color="\#00DDFF"  
        emissive="\#00AAFF"  
        emissiveIntensity={2.5}  
        metalness={0.2}  
        roughness={0.0}  
        transparent  
        opacity={0.9}  
      /\>  
    \</mesh\>  
  );  
};

// Ring structure  
const EnergyRing \= ({  
  frame,  
  fps,  
  index,  
}: {  
  frame: number;  
  fps: number;  
  index: number;  
}) \=\> {  
  const delay \= index \* 5;  
  const scale \= spring({  
    frame: Math.max(0, frame \- delay),  
    fps,  
    config: { damping: 20, stiffness: 50 },  
  });

  const rotY \= frame \* (0.01 \+ index \* 0.005);  
  const rotX \= frame \* (0.007 \- index \* 0.003);

  const colors \= \["\#00FFAA", "\#AA00FF", "\#FF6600"\];  
  const color \= colors\[index % 3\];

  return (  
    \<mesh  
      rotation={\[rotX \+ index \* 0.5, rotY, index \* 1.0\]}  
      scale={\[scale, scale, scale\]}  
    \>  
      \<torusGeometry args={\[1.2 \+ index \* 0.4, 0.025, 16, 100\]} /\>  
      \<meshStandardMaterial  
        color={color}  
        emissive={color}  
        emissiveIntensity={2.0}  
        metalness={0.0}  
        roughness={0.0}  
      /\>  
    \</mesh\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Cinematic 3D bloom scene with rotating geometric forms and multi-layered  
   \* CSS glow simulation. Uses emissive materials and layered canvas compositing  
   \* to achieve a dramatic post-processed look without GPU post-processing libs.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ─── THEME TOKENS ───────────────────────────────────────────────────  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    accent: "\#00DDFF",  
    accentGlow: "\#0044FF",  
    neon1: "\#00FFAA",  
    neon2: "\#AA00FF",  
    neon3: "\#FF6600",  
    text: "\#FFFFFF",  
    textMuted: "\#8888BB",  
  };  
  const TIMING \= { INTRO: 20, MAIN: 40 };  
  const TEXT \= {  
    label: "BLOOM EFFECT",  
    sub: "3D Post-Processing",  
    caption: "Cinematic Rendering",  
  };

  // ─── DERIVED CALCULATIONS ────────────────────────────────────────────  
  const progress \= frame / durationInFrames;

  // Title entrance  
  const titleOpacity \= interpolate(frame, \[TIMING.INTRO, TIMING.INTRO \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });  
  const titleY \= interpolate(frame, \[TIMING.INTRO, TIMING.INTRO \+ 25\], \[30, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  // Sub entrance  
  const subOpacity \= interpolate(frame, \[TIMING.INTRO \+ 15, TIMING.INTRO \+ 35\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Global bloom pulse  
  const bloomPulse \= 0.8 \+ Math.sin(frame \* 0.06) \* 0.2;  
  const bloomIntensity \= 0.6 \+ Math.sin(frame \* 0.09) \* 0.15;

  // Vignette overlay opacity  
  const vignetteOpacity \= 0.55;

  // Caption fade  
  const captionOpacity \= interpolate(frame, \[TIMING.MAIN, TIMING.MAIN \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Font sizes  
  const titleSize \= Math.max(28, Math.round(width \* 0.055));  
  const subSize \= Math.max(14, Math.round(width \* 0.022));  
  const captionSize \= Math.max(10, Math.round(width \* 0.014));

  // Crystal shard configs  
  const shards \= useMemo(  
    () \=\> \[  
      { position: \[-2.2, 0.8, \-1.5\] as \[number, number, number\], rotation: \[0.3, 0, 0.2\] as \[number, number, number\], color: "\#00FFAA", delay: 8 },  
      { position: \[2.2, \-0.5, \-1.0\] as \[number, number, number\], rotation: \[0.1, 1.0, 0.5\] as \[number, number, number\], color: "\#AA00FF", delay: 14 },  
      { position: \[-1.5, \-1.2, \-0.5\] as \[number, number, number\], rotation: \[0.8, 0.5, 0.1\] as \[number, number, number\], color: "\#FF6600", delay: 20 },  
      { position: \[1.8, 1.3, \-2.0\] as \[number, number, number\], rotation: \[0.2, 0.8, 0.6\] as \[number, number, number\], color: "\#00DDFF", delay: 6 },  
      { position: \[0.5, \-1.8, \-1.2\] as \[number, number, number\], rotation: \[0.6, 0.3, 0.9\] as \[number, number, number\], color: "\#FF00AA", delay: 18 },  
      { position: \[-2.5, \-0.2, \-2.5\] as \[number, number, number\], rotation: \[0.4, 1.2, 0.3\] as \[number, number, number\], color: "\#FFEE00", delay: 12 },  
    \],  
    \[\]  
  );

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* ── DEEP SPACE BACKGROUND ── \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, \#0A0A28 0%, \#050510 60%, \#000008 100%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* ── SUBTLE STAR FIELD ── \*/}  
      \<AbsoluteFill style={{ zIndex: 1, overflow: "hidden" }}\>  
        {Array.from({ length: 60 }).map((\_, i) \=\> {  
          const x \= ((i \* 173.17) % 100).toFixed(2);  
          const y \= ((i \* 97.43) % 100).toFixed(2);  
          const sz \= 0.8 \+ (i % 3\) \* 0.6;  
          const twinkle \= 0.3 \+ Math.abs(Math.sin(frame \* 0.04 \+ i)) \* 0.7;  
          return (  
            \<div  
              key={i}  
              style={{  
                position: "absolute",  
                left: \`${x}%\`,  
                top: \`${y}%\`,  
                width: sz,  
                height: sz,  
                borderRadius: "50%",  
                background: "white",  
                opacity: twinkle \* 0.6,  
              }}  
            /\>  
          );  
        })}  
      \</AbsoluteFill\>

      {/\* ── AMBIENT BLOOM GLOW LAYERS (simulated post-processing) ── \*/}  
      {/\* Layer 1: large soft outer bloom \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          pointerEvents: "none",  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.75),  
            height: Math.round(width \* 0.75),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(0,170,255,${0.08 \* bloomPulse}) 0%, rgba(0,80,200,${0.04 \* bloomPulse}) 40%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.04)}px)\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* Layer 2: medium tighter bloom \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 3,  
          pointerEvents: "none",  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.45),  
            height: Math.round(width \* 0.45),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(0,221,255,${0.18 \* bloomIntensity}) 0%, rgba(0,100,220,${0.08 \* bloomIntensity}) 50%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.025)}px)\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* Layer 3: neon accent halos \*/}  
      \<AbsoluteFill style={{ zIndex: 4, pointerEvents: "none" }}\>  
        {/\* Green neon halo \- left \*/}  
        \<div  
          style={{  
            position: "absolute",  
            left: \`${Math.round(width \* 0.15)}px\`,  
            top: \`${Math.round(height \* 0.35)}px\`,  
            width: Math.round(width \* 0.3),  
            height: Math.round(width \* 0.3),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(0,255,170,${0.1 \* bloomPulse}) 0%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.03)}px)\`,  
          }}  
        /\>  
        {/\* Purple neon halo \- right \*/}  
        \<div  
          style={{  
            position: "absolute",  
            right: \`${Math.round(width \* 0.1)}px\`,  
            top: \`${Math.round(height \* 0.25)}px\`,  
            width: Math.round(width \* 0.28),  
            height: Math.round(width \* 0.28),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(170,0,255,${0.1 \* bloomIntensity}) 0%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.03)}px)\`,  
          }}  
        /\>  
        {/\* Orange halo \- bottom \*/}  
        \<div  
          style={{  
            position: "absolute",  
            left: \`${Math.round(width \* 0.35)}px\`,  
            bottom: \`${Math.round(height \* 0.15)}px\`,  
            width: Math.round(width \* 0.22),  
            height: Math.round(width \* 0.22),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(255,100,0,${0.09 \* bloomPulse}) 0%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.025)}px)\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* ── THREE.JS 3D SCENE ── \*/}  
      \<AbsoluteFill style={{ zIndex: 5 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5.5\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.15} color="\#1133AA" /\>  
          \<pointLight position={\[0, 0, 3\]} intensity={3.0} color="\#00DDFF" /\>  
          \<pointLight position={\[-4, 3, 1\]} intensity={2.0} color="\#00FFAA" /\>  
          \<pointLight position={\[4, \-2, 1\]} intensity={2.0} color="\#AA00FF" /\>  
          \<pointLight position={\[0, \-3, 2\]} intensity={1.5} color="\#FF6600" /\>  
          \<directionalLight position={\[5, 5, 5\]} intensity={0.3} color="\#FFFFFF" /\>

          {/\* Central orb \*/}  
          \<CentralOrb frame={frame} fps={fps} /\>

          {/\* Energy rings \*/}  
          {\[0, 1, 2\].map((i) \=\> (  
            \<EnergyRing key={i} frame={frame} fps={fps} index={i} /\>  
          ))}

          {/\* Crystal shards \*/}  
          {shards.map((shard, i) \=\> (  
            \<CrystalShard  
              key={i}  
              frame={frame}  
              fps={fps}  
              position={shard.position}  
              rotation={shard.rotation}  
              color={shard.color}  
              delay={shard.delay}  
            /\>  
          ))}  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* ── BLOOM OVERLAY: Central core glow (tight) ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 6,  
          pointerEvents: "none",  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.18),  
            height: Math.round(width \* 0.18),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(0,221,255,${0.55 \* bloomPulse}) 0%, rgba(0,150,255,${0.2 \* bloomPulse}) 40%, transparent 70%)\`,  
            filter: \`blur(${Math.round(width \* 0.012)}px)\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* ── HORIZONTAL LENS FLARE ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 7,  
          pointerEvents: "none",  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
        }}  
      \>  
        \<div  
          style={{  
            width: "100%",  
            height: Math.round(height \* 0.002),  
            background: \`linear-gradient(to right, transparent 0%, rgba(0,221,255,${0.06 \* bloomPulse}) 30%, rgba(0,200,255,${0.12 \* bloomPulse}) 50%, rgba(0,221,255,${0.06 \* bloomPulse}) 70%, transparent 100%)\`,  
            filter: \`blur(${Math.round(width \* 0.004)}px)\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* ── VIGNETTE ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 8,  
          background: \`radial-gradient(ellipse at 50% 50%, transparent 40%, rgba(0,0,8,${vignetteOpacity}) 100%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* ── SCAN LINES ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 9,  
          pointerEvents: "none",  
          backgroundImage: \`repeating-linear-gradient(  
            0deg,  
            transparent,  
            transparent 2px,  
            rgba(0,0,0,0.04) 2px,  
            rgba(0,0,0,0.04) 4px  
          )\`,  
          opacity: 0.4,  
        }}  
      /\>

      {/\* ── UI TEXT LAYER ── \*/}  
      \<AbsoluteFill style={{ zIndex: 10 }}\>  
        {/\* Caption — top left \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.06),  
            left: Math.round(width \* 0.06),  
            opacity: captionOpacity,  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: captionSize,  
              fontWeight: 400,  
              letterSpacing: "0.25em",  
              color: COLORS.textMuted,  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.caption}  
          \</div\>  
        \</div\>

        {/\* Caption — top right: FPS indicator \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.06),  
            right: Math.round(width \* 0.06),  
            opacity: captionOpacity \* 0.7,  
            display: "flex",  
            alignItems: "center",  
            gap: 8,  
          }}  
        \>  
          \<div  
            style={{  
              width: 6,  
              height: 6,  
              borderRadius: "50%",  
              background: COLORS.neon1,  
              opacity: 0.5 \+ Math.sin(frame \* 0.15) \* 0.5,  
            }}  
          /\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: captionSize,  
              fontWeight: 400,  
              letterSpacing: "0.2em",  
              color: COLORS.textMuted,  
            }}  
          \>  
            LIVE RENDER  
          \</div\>  
        \</div\>

        {/\* Main title — bottom center \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.14),  
            left: 0,  
            right: 0,  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: Math.round(height \* 0.015),  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
          }}  
        \>  
          {/\* Subtitle \*/}  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: subSize,  
              fontWeight: 300,  
              letterSpacing: "0.35em",  
              color: COLORS.textMuted,  
              textTransform: "uppercase",  
              opacity: subOpacity,  
            }}  
          \>  
            {TEXT.sub}  
          \</div\>

          {/\* Title with glow \*/}  
          \<div style={{ position: "relative", display: "inline-block" }}\>  
            {/\* Glow copy behind \*/}  
            \<div  
              style={{  
                position: "absolute",  
                inset: 0,  
                fontFamily: "Inter, sans-serif",  
                fontSize: titleSize,  
                fontWeight: 900,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.0,  
                color: COLORS.accent,  
                filter: \`blur(${Math.round(titleSize \* 0.25)}px)\`,  
                opacity: 0.7 \* bloomPulse,  
                userSelect: "none",  
                textAlign: "center",  
              }}  
            \>  
              {TEXT.label}  
            \</div\>  
            {/\* Actual title \*/}  
            \<div  
              style={{  
                position: "relative",  
                fontFamily: "Inter, sans-serif",  
                fontSize: titleSize,  
                fontWeight: 900,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.0,  
                background: \`linear-gradient(135deg, \#FFFFFF 0%, \#A0E8FF 50%, \#00DDFF 100%)\`,  
                WebkitBackgroundClip: "text",  
                WebkitTextFillColor: "transparent",  
                userSelect: "none",  
              }}  
            \>  
              {TEXT.label}  
            \</div\>  
          \</div\>

          {/\* Divider line \*/}  
          \<div  
            style={{  
              width: Math.round(width \* 0.12),  
              height: 1,  
              background: \`linear-gradient(to right, transparent, ${COLORS.accent}, transparent)\`,  
              opacity: subOpacity,  
            }}  
          /\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* ── EDGE ABERRATION (chromatic) ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 11,  
          pointerEvents: "none",  
          background: \`linear-gradient(to bottom, rgba(0,221,255,0.03) 0%, transparent 15%, transparent 85%, rgba(0,221,255,0.03) 100%)\`,  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

1\. Primeiro prompt: \*"Crie uma esfera 3D azul girando."\*  
2\. Follow-up prompt: \*"Mude a cor da esfera para dourado metálico com roughness baixo."\*

resultado 1:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

export const MyAnimation \= () \=\> {  
  /\*  
   \* A rotating 3D blue sphere with smooth spin animation.  
   \* The sphere features metallic material with proper lighting for depth and shine.  
   \* A premium dark background creates strong contrast for visual impact.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    accent: "\#60A5FA",  
    glow: "\#3B82F6",  
  };

  // Scale entrance spring  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  // Continuous rotation  
  const rotationY \= frame \* 0.025;  
  const rotationX \= frame \* 0.01;

  // Floating Y offset  
  const floatY \= Math.sin(frame \* 0.05) \* 0.15;

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, \#0A0F1E 0%, \#000000 70%)\`,  
      }}  
    \>  
      {/\* Subtle ambient glow behind sphere \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
          zIndex: 0,  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.45),  
            height: Math.round(width \* 0.45),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(59,130,246,0.18) 0%, rgba(96,165,250,0.06) 60%, transparent 80%)\`,  
            filter: "blur(40px)",  
            transform: \`scale(${scaleProgress})\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 4\], fov: 60 }}  
        \>  
          {/\* Ambient light \*/}  
          \<ambientLight intensity={0.3} /\>

          {/\* Key light — cool blue-white from top-left \*/}  
          \<directionalLight  
            position={\[-4, 5, 4\]}  
            intensity={1.4}  
            color="\#DDEEFF"  
          /\>

          {/\* Fill light — warm from right \*/}  
          \<pointLight position={\[4, \-2, 3\]} intensity={0.6} color="\#7EC8FF" /\>

          {/\* Rim light — deep blue from behind \*/}  
          \<pointLight position={\[0, \-3, \-4\]} intensity={0.8} color="\#1E3A8A" /\>

          {/\* Rotating sphere \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, 0\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<sphereGeometry args={\[1.2, 64, 64\]} /\>  
            \<meshStandardMaterial  
              color="\#2563EB"  
              roughness={0.15}  
              metalness={0.7}  
              envMapIntensity={1.2}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Label \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.08),  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(14, Math.round(width \* 0.018)),  
            fontWeight: 400,  
            letterSpacing: "0.25em",  
            textTransform: "uppercase",  
            color: "rgba(96,165,250,0.55)",  
            opacity: scaleProgress,  
          }}  
        \>  
          Blue Sphere · 3D  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

resultado 2:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

export const MyAnimation \= () \=\> {  
  /\*  
   \* A rotating 3D golden metallic sphere with smooth spin animation.  
   \* The sphere features a low-roughness metallic gold material with proper lighting for depth and shine.  
   \* A premium dark background creates strong contrast for visual impact.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    accent: "\#F59E0B",  
    glow: "\#D97706",  
  };

  // Scale entrance spring  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  // Continuous rotation  
  const rotationY \= frame \* 0.025;  
  const rotationX \= frame \* 0.01;

  // Floating Y offset  
  const floatY \= Math.sin(frame \* 0.05) \* 0.15;

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, \#1A1000 0%, \#000000 70%)\`,  
      }}  
    \>  
      {/\* Subtle ambient glow behind sphere \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
          zIndex: 0,  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.45),  
            height: Math.round(width \* 0.45),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(245,158,11,0.18) 0%, rgba(217,119,6,0.06) 60%, transparent 80%)\`,  
            filter: "blur(40px)",  
            transform: \`scale(${scaleProgress})\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 4\], fov: 60 }}  
        \>  
          {/\* Ambient light \*/}  
          \<ambientLight intensity={0.4} /\>

          {/\* Key light — warm golden from top-left \*/}  
          \<directionalLight  
            position={\[-4, 5, 4\]}  
            intensity={1.6}  
            color="\#FFF5CC"  
          /\>

          {/\* Fill light — soft warm from right \*/}  
          \<pointLight position={\[4, \-2, 3\]} intensity={0.8} color="\#FFD97A" /\>

          {/\* Rim light — deep amber from behind \*/}  
          \<pointLight position={\[0, \-3, \-4\]} intensity={0.9} color="\#B45309" /\>

          {/\* Top highlight \*/}  
          \<pointLight position={\[0, 5, 2\]} intensity={0.5} color="\#FFFDE0" /\>

          {/\* Rotating golden sphere \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, 0\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<sphereGeometry args={\[1.2, 64, 64\]} /\>  
            \<meshStandardMaterial  
              color="\#C8860A"  
              roughness={0.05}  
              metalness={0.95}  
              envMapIntensity={1.5}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Label \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.08),  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(14, Math.round(width \* 0.018)),  
            fontWeight: 400,  
            letterSpacing: "0.25em",  
            textTransform: "uppercase",  
            color: "rgba(245,158,11,0.55)",  
            opacity: scaleProgress,  
          }}  
        \>  
          Golden Sphere · 3D  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

1\. Primeiro prompt: \*"Crie uma câmera que orbita ao redor de um objeto 3D."\*  
2\. Follow-up prompt: \*"Faça a câmera orbitar 3 vezes mais devagar."

resultado 1:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
 \* A cinematic 3D animation featuring a camera that orbits around a glowing  
 \* geometric object — a faceted icosahedron — set against a deep space backdrop.  
 \* The orbit is smooth and continuous, with dynamic lighting that reacts to the camera angle.  
 \*/

const OrbitingScene \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const ORBIT\_SPEED \= 0.012;  
  const ORBIT\_RADIUS \= 5;  
  const ORBIT\_HEIGHT \= 1.5;

  const angle \= frame \* ORBIT\_SPEED;  
  const camX \= Math.sin(angle) \* ORBIT\_RADIUS;  
  const camZ \= Math.cos(angle) \* ORBIT\_RADIUS;  
  const camY \= ORBIT\_HEIGHT \+ Math.sin(frame \* 0.005) \* 0.5;

  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const innerRotX \= frame \* 0.008;  
  const innerRotY \= frame \* 0.015;

  const lightAngle \= angle \+ Math.PI \* 0.3;  
  const lightX \= Math.sin(lightAngle) \* 6;  
  const lightZ \= Math.cos(lightAngle) \* 6;

  return (  
    \<\>  
      {/\* Lighting \*/}  
      \<ambientLight intensity={0.15} /\>  
      \<pointLight position={\[lightX, 4, lightZ\]} intensity={2.2} color="\#60A5FA" /\>  
      \<pointLight position={\[-lightX \* 0.5, \-3, \-lightZ \* 0.5\]} intensity={1.0} color="\#34D399" /\>  
      \<pointLight position={\[0, 5, 0\]} intensity={0.4} color="\#ffffff" /\>

      {/\* Main object \- Icosahedron \*/}  
      \<mesh  
        rotation={\[innerRotX, innerRotY, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
        position={\[0, 0, 0\]}  
      \>  
        \<icosahedronGeometry args={\[1.3, 1\]} /\>  
        \<meshStandardMaterial  
          color="\#1A1A2E"  
          metalness={0.85}  
          roughness={0.12}  
          envMapIntensity={1}  
        /\>  
      \</mesh\>

      {/\* Wireframe overlay \*/}  
      \<mesh  
        rotation={\[innerRotX, innerRotY, 0\]}  
        scale={\[scaleProgress \* 1.01, scaleProgress \* 1.01, scaleProgress \* 1.01\]}  
      \>  
        \<icosahedronGeometry args={\[1.3, 1\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" wireframe opacity={0.3} transparent /\>  
      \</mesh\>

      {/\* Inner glowing core \*/}  
      \<mesh position={\[0, 0, 0\]} scale={\[scaleProgress \* 0.35, scaleProgress \* 0.35, scaleProgress \* 0.35\]}\>  
        \<sphereGeometry args={\[1, 32, 32\]} /\>  
        \<meshBasicMaterial color="\#34D399" transparent opacity={0.85} /\>  
      \</mesh\>

      {/\* Orbit ring \- flat torus \*/}  
      \<mesh rotation={\[Math.PI / 2, 0, frame \* 0.004\]} scale={\[scaleProgress, scaleProgress, scaleProgress\]}\>  
        \<torusGeometry args={\[2.2, 0.015, 8, 128\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" transparent opacity={0.25} /\>  
      \</mesh\>

      {/\* Second orbit ring \- tilted \*/}  
      \<mesh rotation={\[Math.PI / 3, frame \* 0.003, 0\]} scale={\[scaleProgress, scaleProgress, scaleProgress\]}\>  
        \<torusGeometry args={\[2.8, 0.01, 8, 128\]} /\>  
        \<meshBasicMaterial color="\#34D399" transparent opacity={0.15} /\>  
      \</mesh\>

      {/\* Floating satellite cube \*/}  
      \<mesh  
        position={\[  
          Math.sin(frame \* 0.025) \* 2.2,  
          Math.cos(frame \* 0.018) \* 0.6,  
          Math.cos(frame \* 0.025) \* 2.2,  
        \]}  
        rotation={\[frame \* 0.04, frame \* 0.06, 0\]}  
        scale={\[scaleProgress \* 0.22, scaleProgress \* 0.22, scaleProgress \* 0.22\]}  
      \>  
        \<boxGeometry args={\[1, 1, 1\]} /\>  
        \<meshStandardMaterial color="\#60A5FA" metalness={0.9} roughness={0.1} /\>  
      \</mesh\>

      {/\* Second satellite \- octahedron \*/}  
      \<mesh  
        position={\[  
          Math.sin(frame \* 0.02 \+ Math.PI) \* 2.8,  
          Math.sin(frame \* 0.022) \* 0.8,  
          Math.cos(frame \* 0.02 \+ Math.PI) \* 2.8,  
        \]}  
        rotation={\[frame \* 0.05, frame \* 0.03, frame \* 0.04\]}  
        scale={\[scaleProgress \* 0.18, scaleProgress \* 0.18, scaleProgress \* 0.18\]}  
      \>  
        \<octahedronGeometry args={\[1, 0\]} /\>  
        \<meshStandardMaterial color="\#34D399" metalness={0.8} roughness={0.15} /\>  
      \</mesh\>

      {/\* Grid floor \*/}  
      \<gridHelper args={\[20, 30, "\#1A1A2E", "\#111122"\]} position={\[0, \-2.5, 0\]} /\>

      {/\* Camera target \*/}  
      \<perspectiveCamera  
        position={\[camX, camY, camZ\]}  
        near={0.1}  
        far={100}  
        fov={60}  
      /\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Main composition for the orbiting camera 3D scene.  
   \* Uses ThreeCanvas with a dynamically computed camera position driven by frame.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ── Theme tokens ──────────────────────────────────────────────  
  const THEME \= { archetype: "premium\_dark", pacing: "cinematic" };  
  const COLORS \= {  
    bg: "\#000008",  
    surface1: "\#0A0A18",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accent2: "\#34D399",  
  };  
  const TIMING \= { FADE\_IN: 20, LABEL\_DELAY: 40 };

  // ── Derived animation values ───────────────────────────────────  
  const ORBIT\_SPEED \= 0.012;  
  const ORBIT\_RADIUS \= 5;  
  const ORBIT\_HEIGHT \= 1.5;  
  const angle \= frame \* ORBIT\_SPEED;  
  const camX \= Math.sin(angle) \* ORBIT\_RADIUS;  
  const camZ \= Math.cos(angle) \* ORBIT\_RADIUS;  
  const camY \= ORBIT\_HEIGHT \+ Math.sin(frame \* 0.005) \* 0.5;

  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const labelOpacity \= interpolate(frame, \[TIMING.LABEL\_DELAY, TIMING.LABEL\_DELAY \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const exitOpacity \= interpolate(  
    frame,  
    \[durationInFrames \- 20, durationInFrames \- 2\],  
    \[1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const finalOpacity \= Math.min(globalOpacity, exitOpacity);

  // Degrees for HUD display  
  const orbitDeg \= Math.round(((angle % (Math.PI \* 2)) / (Math.PI \* 2)) \* 360);

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Deep space gradient background \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 40%, \#0D0D2B 0%, \#050508 55%, \#000004 100%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* Star field \*/}  
      \<AbsoluteFill style={{ zIndex: 1, opacity: 0.6 }}\>  
        {\[...Array(60)\].map((\_, i) \=\> {  
          const sx \= ((i \* 137.5) % 100);  
          const sy \= ((i \* 97.3) % 100);  
          const size \= ((i \* 53.7) % 2.5) \+ 0.5;  
          const twinkle \= interpolate(  
            (frame \+ i \* 7\) % 60,  
            \[0, 30, 60\],  
            \[0.3, 1.0, 0.3\],  
            { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
          );  
          return (  
            \<div  
              key={i}  
              style={{  
                position: "absolute",  
                left: \`${sx}%\`,  
                top: \`${sy}%\`,  
                width: size,  
                height: size,  
                borderRadius: "50%",  
                background: i % 5 \=== 0 ? COLORS.accent : "\#FFFFFF",  
                opacity: twinkle \* 0.7,  
              }}  
            /\>  
          );  
        })}  
      \</AbsoluteFill\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 2, opacity: finalOpacity }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{  
            position: \[camX, camY, camZ\],  
            fov: 60,  
            near: 0.1,  
            far: 100,  
          }}  
        \>  
          \<OrbitingScene frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* HUD Overlay \*/}  
      \<AbsoluteFill style={{ zIndex: 10, pointerEvents: "none", opacity: finalOpacity }}\>  
        {/\* Top bar \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.04),  
            left: Math.round(width \* 0.05),  
            right: Math.round(width \* 0.05),  
            display: "flex",  
            justifyContent: "space-between",  
            alignItems: "center",  
            opacity: labelOpacity,  
          }}  
        \>  
          \<div style={{ display: "flex", alignItems: "center", gap: 10 }}\>  
            \<div  
              style={{  
                width: 8,  
                height: 8,  
                borderRadius: "50%",  
                background: COLORS.accent2,  
                boxShadow: \`0 0 8px ${COLORS.accent2}\`,  
              }}  
            /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: Math.max(10, Math.round(width \* 0.013)),  
                fontWeight: 600,  
                color: COLORS.textMuted,  
                letterSpacing: "0.15em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Orbit Cam — Live  
            \</span\>  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "'Courier New', monospace",  
              fontSize: Math.max(9, Math.round(width \* 0.011)),  
              color: COLORS.accent,  
              letterSpacing: "0.08em",  
              opacity: 0.8,  
            }}  
          \>  
            {String(orbitDeg).padStart(3, "0")}°  
          \</div\>  
        \</div\>

        {/\* Center title \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.08),  
            left: 0,  
            right: 0,  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: 8,  
            opacity: labelOpacity,  
          }}  
        \>  
          \<h1  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: Math.max(20, Math.round(width \* 0.038)),  
              fontWeight: 800,  
              color: COLORS.text,  
              letterSpacing: "-0.02em",  
              margin: 0,  
              textAlign: "center",  
            }}  
          \>  
            Órbita{" "}  
            \<span  
              style={{  
                background: \`linear-gradient(90deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
                WebkitBackgroundClip: "text",  
                WebkitTextFillColor: "transparent",  
              }}  
            \>  
              3D  
            \</span\>  
          \</h1\>  
          \<p  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: Math.max(10, Math.round(width \* 0.014)),  
              fontWeight: 400,  
              color: COLORS.textMuted,  
              letterSpacing: "0.05em",  
              margin: 0,  
            }}  
          \>  
            Câmera em translação ao redor do objeto  
          \</p\>  
        \</div\>

        {/\* Corner brackets \*/}  
        {\[  
          { top: Math.round(height \* 0.035), left: Math.round(width \* 0.035), borderTop: "2px solid", borderLeft: "2px solid" },  
          { top: Math.round(height \* 0.035), right: Math.round(width \* 0.035), borderTop: "2px solid", borderRight: "2px solid" },  
          { bottom: Math.round(height \* 0.035), left: Math.round(width \* 0.035), borderBottom: "2px solid", borderLeft: "2px solid" },  
          { bottom: Math.round(height \* 0.035), right: Math.round(width \* 0.035), borderBottom: "2px solid", borderRight: "2px solid" },  
        \].map((style, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              width: Math.round(width \* 0.03),  
              height: Math.round(width \* 0.03),  
              borderColor: COLORS.accent,  
              opacity: labelOpacity \* 0.5,  
              ...style,  
            }}  
          /\>  
        ))}

        {/\* Camera position readout \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.04),  
            right: Math.round(width \* 0.05),  
            fontFamily: "'Courier New', monospace",  
            fontSize: Math.max(8, Math.round(width \* 0.01)),  
            color: COLORS.accent2,  
            opacity: labelOpacity \* 0.7,  
            letterSpacing: "0.05em",  
            textAlign: "right",  
            lineHeight: 1.6,  
          }}  
        \>  
          \<div\>X {camX.toFixed(2)}\</div\>  
          \<div\>Y {camY.toFixed(2)}\</div\>  
          \<div\>Z {camZ.toFixed(2)}\</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

resultado 2:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A cinematic 3D animation featuring a camera that orbits around a glowing  
 \* geometric object — a faceted icosahedron — set against a deep space backdrop.  
 \* The orbit is smooth and continuous, with dynamic lighting that reacts to the camera angle.  
 \* Camera orbit speed reduced to 1/3 of the original.  
 \*/

const OrbitingScene \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const ORBIT\_SPEED \= 0.004;  
  const ORBIT\_RADIUS \= 5;  
  const ORBIT\_HEIGHT \= 1.5;

  const angle \= frame \* ORBIT\_SPEED;  
  const camX \= Math.sin(angle) \* ORBIT\_RADIUS;  
  const camZ \= Math.cos(angle) \* ORBIT\_RADIUS;  
  const camY \= ORBIT\_HEIGHT \+ Math.sin(frame \* 0.005) \* 0.5;

  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const innerRotX \= frame \* 0.008;  
  const innerRotY \= frame \* 0.015;

  const lightAngle \= angle \+ Math.PI \* 0.3;  
  const lightX \= Math.sin(lightAngle) \* 6;  
  const lightZ \= Math.cos(lightAngle) \* 6;

  return (  
    \<\>  
      {/\* Lighting \*/}  
      \<ambientLight intensity={0.15} /\>  
      \<pointLight position={\[lightX, 4, lightZ\]} intensity={2.2} color="\#60A5FA" /\>  
      \<pointLight position={\[-lightX \* 0.5, \-3, \-lightZ \* 0.5\]} intensity={1.0} color="\#34D399" /\>  
      \<pointLight position={\[0, 5, 0\]} intensity={0.4} color="\#ffffff" /\>

      {/\* Main object \- Icosahedron \*/}  
      \<mesh  
        rotation={\[innerRotX, innerRotY, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
        position={\[0, 0, 0\]}  
      \>  
        \<icosahedronGeometry args={\[1.3, 1\]} /\>  
        \<meshStandardMaterial  
          color="\#1A1A2E"  
          metalness={0.85}  
          roughness={0.12}  
          envMapIntensity={1}  
        /\>  
      \</mesh\>

      {/\* Wireframe overlay \*/}  
      \<mesh  
        rotation={\[innerRotX, innerRotY, 0\]}  
        scale={\[scaleProgress \* 1.01, scaleProgress \* 1.01, scaleProgress \* 1.01\]}  
      \>  
        \<icosahedronGeometry args={\[1.3, 1\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" wireframe opacity={0.3} transparent /\>  
      \</mesh\>

      {/\* Inner glowing core \*/}  
      \<mesh position={\[0, 0, 0\]} scale={\[scaleProgress \* 0.35, scaleProgress \* 0.35, scaleProgress \* 0.35\]}\>  
        \<sphereGeometry args={\[1, 32, 32\]} /\>  
        \<meshBasicMaterial color="\#34D399" transparent opacity={0.85} /\>  
      \</mesh\>

      {/\* Orbit ring \- flat torus \*/}  
      \<mesh rotation={\[Math.PI / 2, 0, frame \* 0.004\]} scale={\[scaleProgress, scaleProgress, scaleProgress\]}\>  
        \<torusGeometry args={\[2.2, 0.015, 8, 128\]} /\>  
        \<meshBasicMaterial color="\#60A5FA" transparent opacity={0.25} /\>  
      \</mesh\>

      {/\* Second orbit ring \- tilted \*/}  
      \<mesh rotation={\[Math.PI / 3, frame \* 0.003, 0\]} scale={\[scaleProgress, scaleProgress, scaleProgress\]}\>  
        \<torusGeometry args={\[2.8, 0.01, 8, 128\]} /\>  
        \<meshBasicMaterial color="\#34D399" transparent opacity={0.15} /\>  
      \</mesh\>

      {/\* Floating satellite cube \*/}  
      \<mesh  
        position={\[  
          Math.sin(frame \* 0.025) \* 2.2,  
          Math.cos(frame \* 0.018) \* 0.6,  
          Math.cos(frame \* 0.025) \* 2.2,  
        \]}  
        rotation={\[frame \* 0.04, frame \* 0.06, 0\]}  
        scale={\[scaleProgress \* 0.22, scaleProgress \* 0.22, scaleProgress \* 0.22\]}  
      \>  
        \<boxGeometry args={\[1, 1, 1\]} /\>  
        \<meshStandardMaterial color="\#60A5FA" metalness={0.9} roughness={0.1} /\>  
      \</mesh\>

      {/\* Second satellite \- octahedron \*/}  
      \<mesh  
        position={\[  
          Math.sin(frame \* 0.02 \+ Math.PI) \* 2.8,  
          Math.sin(frame \* 0.022) \* 0.8,  
          Math.cos(frame \* 0.02 \+ Math.PI) \* 2.8,  
        \]}  
        rotation={\[frame \* 0.05, frame \* 0.03, frame \* 0.04\]}  
        scale={\[scaleProgress \* 0.18, scaleProgress \* 0.18, scaleProgress \* 0.18\]}  
      \>  
        \<octahedronGeometry args={\[1, 0\]} /\>  
        \<meshStandardMaterial color="\#34D399" metalness={0.8} roughness={0.15} /\>  
      \</mesh\>

      {/\* Grid floor \*/}  
      \<gridHelper args={\[20, 30, "\#1A1A2E", "\#111122"\]} position={\[0, \-2.5, 0\]} /\>

      {/\* Camera target \*/}  
      \<perspectiveCamera  
        position={\[camX, camY, camZ\]}  
        near={0.1}  
        far={100}  
        fov={60}  
      /\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Main composition for the orbiting camera 3D scene.  
   \* Uses ThreeCanvas with a dynamically computed camera position driven by frame.  
   \* Camera orbit speed is 3x slower than the original.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ── Theme tokens ──────────────────────────────────────────────  
  const THEME \= { archetype: "premium\_dark", pacing: "cinematic" };  
  const COLORS \= {  
    bg: "\#000008",  
    surface1: "\#0A0A18",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accent2: "\#34D399",  
  };  
  const TIMING \= { FADE\_IN: 20, LABEL\_DELAY: 40 };

  // ── Derived animation values ───────────────────────────────────  
  const ORBIT\_SPEED \= 0.004;  
  const ORBIT\_RADIUS \= 5;  
  const ORBIT\_HEIGHT \= 1.5;  
  const angle \= frame \* ORBIT\_SPEED;  
  const camX \= Math.sin(angle) \* ORBIT\_RADIUS;  
  const camZ \= Math.cos(angle) \* ORBIT\_RADIUS;  
  const camY \= ORBIT\_HEIGHT \+ Math.sin(frame \* 0.005) \* 0.5;

  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const labelOpacity \= interpolate(frame, \[TIMING.LABEL\_DELAY, TIMING.LABEL\_DELAY \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const exitOpacity \= interpolate(  
    frame,  
    \[durationInFrames \- 20, durationInFrames \- 2\],  
    \[1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const finalOpacity \= Math.min(globalOpacity, exitOpacity);

  // Degrees for HUD display  
  const orbitDeg \= Math.round(((angle % (Math.PI \* 2)) / (Math.PI \* 2)) \* 360);

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Deep space gradient background \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 40%, \#0D0D2B 0%, \#050508 55%, \#000004 100%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* Star field \*/}  
      \<AbsoluteFill style={{ zIndex: 1, opacity: 0.6 }}\>  
        {\[...Array(60)\].map((\_, i) \=\> {  
          const sx \= ((i \* 137.5) % 100);  
          const sy \= ((i \* 97.3) % 100);  
          const size \= ((i \* 53.7) % 2.5) \+ 0.5;  
          const twinkle \= interpolate(  
            (frame \+ i \* 7\) % 60,  
            \[0, 30, 60\],  
            \[0.3, 1.0, 0.3\],  
            { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
          );  
          return (  
            \<div  
              key={i}  
              style={{  
                position: "absolute",  
                left: \`${sx}%\`,  
                top: \`${sy}%\`,  
                width: size,  
                height: size,  
                borderRadius: "50%",  
                background: i % 5 \=== 0 ? COLORS.accent : "\#FFFFFF",  
                opacity: twinkle \* 0.7,  
              }}  
            /\>  
          );  
        })}  
      \</AbsoluteFill\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 2, opacity: finalOpacity }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{  
            position: \[camX, camY, camZ\],  
            fov: 60,  
            near: 0.1,  
            far: 100,  
          }}  
        \>  
          \<OrbitingScene frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* HUD Overlay \*/}  
      \<AbsoluteFill style={{ zIndex: 10, pointerEvents: "none", opacity: finalOpacity }}\>  
        {/\* Top bar \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.04),  
            left: Math.round(width \* 0.05),  
            right: Math.round(width \* 0.05),  
            display: "flex",  
            justifyContent: "space-between",  
            alignItems: "center",  
            opacity: labelOpacity,  
          }}  
        \>  
          \<div style={{ display: "flex", alignItems: "center", gap: 10 }}\>  
            \<div  
              style={{  
                width: 8,  
                height: 8,  
                borderRadius: "50%",  
                background: COLORS.accent2,  
                boxShadow: \`0 0 8px ${COLORS.accent2}\`,  
              }}  
            /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: Math.max(10, Math.round(width \* 0.013)),  
                fontWeight: 600,  
                color: COLORS.textMuted,  
                letterSpacing: "0.15em",  
                textTransform: "uppercase" as const,  
              }}  
            \>  
              Orbit Cam — Live  
            \</span\>  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "'Courier New', monospace",  
              fontSize: Math.max(9, Math.round(width \* 0.011)),  
              color: COLORS.accent,  
              letterSpacing: "0.08em",  
              opacity: 0.8,  
            }}  
          \>  
            {String(orbitDeg).padStart(3, "0")}°  
          \</div\>  
        \</div\>

        {/\* Center title \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.08),  
            left: 0,  
            right: 0,  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: 8,  
            opacity: labelOpacity,  
          }}  
        \>  
          \<h1  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: Math.max(20, Math.round(width \* 0.038)),  
              fontWeight: 800,  
              color: COLORS.text,  
              letterSpacing: "-0.02em",  
              margin: 0,  
              textAlign: "center",  
            }}  
          \>  
            Órbita{" "}  
            \<span  
              style={{  
                background: \`linear-gradient(90deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
                WebkitBackgroundClip: "text",  
                WebkitTextFillColor: "transparent",  
              }}  
            \>  
              3D  
            \</span\>  
          \</h1\>  
          \<p  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: Math.max(10, Math.round(width \* 0.014)),  
              fontWeight: 400,  
              color: COLORS.textMuted,  
              letterSpacing: "0.05em",  
              margin: 0,  
            }}  
          \>  
            Câmera em translação ao redor do objeto  
          \</p\>  
        \</div\>

        {/\* Corner brackets \*/}  
        {\[  
          { top: Math.round(height \* 0.035), left: Math.round(width \* 0.035), borderTop: "2px solid", borderLeft: "2px solid" },  
          { top: Math.round(height \* 0.035), right: Math.round(width \* 0.035), borderTop: "2px solid", borderRight: "2px solid" },  
          { bottom: Math.round(height \* 0.035), left: Math.round(width \* 0.035), borderBottom: "2px solid", borderLeft: "2px solid" },  
          { bottom: Math.round(height \* 0.035), right: Math.round(width \* 0.035), borderBottom: "2px solid", borderRight: "2px solid" },  
        \].map((style, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              width: Math.round(width \* 0.03),  
              height: Math.round(width \* 0.03),  
              borderColor: COLORS.accent,  
              opacity: labelOpacity \* 0.5,  
              ...style,  
            }}  
          /\>  
        ))}

        {/\* Camera position readout \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.04),  
            right: Math.round(width \* 0.05),  
            fontFamily: "'Courier New', monospace",  
            fontSize: Math.max(8, Math.round(width \* 0.01)),  
            color: COLORS.accent2,  
            opacity: labelOpacity \* 0.7,  
            letterSpacing: "0.05em",  
            textAlign: "right",  
            lineHeight: 1.6,  
          }}  
        \>  
          \<div\>X {camX.toFixed(2)}\</div\>  
          \<div\>Y {camY.toFixed(2)}\</div\>  
          \<div\>Z {camZ.toFixed(2)}\</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

1\. Primeiro prompt: \*"Crie um cubo metálico 3D girando."\*  
2\. Follow-up prompt: \*"Adicione um anel torus ao redor do cubo, girando no sentido contrário."\*

resultado 1:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A premium 3D metallic cube rotating in 3D space.  
 \* Features reflective metallic material with smooth continuous rotation on all axes.  
 \* Dark cinematic background with subtle lighting for a dramatic effect.  
 \*/

export const MyAnimation \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    surface2: "\#1A1A1E",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
  };

  const TIMING \= { BASE: 15, FADE: 30, STAGGER: 4 };

  // Entrance spring for scale  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80, mass: 1.2 },  
  });

  // Continuous rotation values  
  const rotationY \= frame \* 0.022;  
  const rotationX \= frame \* 0.011;  
  const rotationZ \= frame \* 0.006;

  // Floating Y position  
  const floatY \= Math.sin(frame \* 0.05) \* 0.18;

  // Fade in opacity  
  const opacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Subtle background pulse  
  const bgGlow \= interpolate(  
    Math.sin(frame \* 0.04),  
    \[-1, 1\],  
    \[0.03, 0.08\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, rgba(96, 165, 250, ${bgGlow}) 0%, \#000000 70%)\`,  
        display: "flex",  
        alignItems: "center",  
        justifyContent: "center",  
        opacity,  
      }}  
    \>  
      {/\* Subtle floor reflection line \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: Math.round(height \* 0.3),  
          left: "50%",  
          transform: "translateX(-50%)",  
          width: Math.round(width \* 0.25),  
          height: 1,  
          background: \`linear-gradient(90deg, transparent, rgba(96, 165, 250, 0.3), transparent)\`,  
          zIndex: 1,  
        }}  
      /\>

      {/\* Label \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: Math.round(height \* 0.12),  
          left: "50%",  
          transform: "translateX(-50%)",  
          fontFamily: "Inter, sans-serif",  
          fontSize: Math.max(14, Math.round(width \* 0.018)),  
          fontWeight: 300,  
          letterSpacing: "0.25em",  
          color: COLORS.textMuted,  
          textTransform: "uppercase",  
          zIndex: 2,  
          opacity: interpolate(frame, \[20, 50\], \[0, 1\], {  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          }),  
        }}  
      \>  
        Metallic Cube  
      \</div\>

      {/\* 3D Scene \*/}  
      \<div  
        style={{  
          position: "absolute",  
          inset: 0,  
          zIndex: 1,  
        }}  
      \>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.15} /\>  
          \<directionalLight position={\[5, 8, 5\]} intensity={1.2} color="\#ffffff" /\>  
          \<directionalLight position={\[-5, \-3, \-5\]} intensity={0.4} color="\#60A5FA" /\>  
          \<pointLight position={\[0, 5, 3\]} intensity={0.8} color="\#ffffff" /\>  
          \<pointLight position={\[3, \-2, 2\]} intensity={0.5} color="\#93C5FD" /\>  
          \<pointLight position={\[-3, 2, \-2\]} intensity={0.3} color="\#BFDBFE" /\>

          {/\* Metallic Cube \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, rotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<boxGeometry args={\[2, 2, 2\]} /\>  
            \<meshStandardMaterial  
              color="\#8899AA"  
              metalness={0.95}  
              roughness={0.08}  
              envMapIntensity={1.0}  
            /\>  
          \</mesh\>

          {/\* Subtle inner glow sphere \*/}  
          \<mesh  
            rotation={\[rotationX \* 0.5, rotationY \* 0.5, rotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress \* 1.05, scaleProgress \* 1.05, scaleProgress \* 1.05\]}  
          \>  
            \<boxGeometry args={\[2, 2, 2\]} /\>  
            \<meshStandardMaterial  
              color="\#60A5FA"  
              metalness={1}  
              roughness={0}  
              transparent  
              opacity={0.04}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

resultado 2:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A premium 3D metallic cube rotating in 3D space with a torus ring orbiting around it.  
 \* The torus ring rotates in the opposite direction to the cube for dynamic contrast.  
 \* Dark cinematic background with subtle lighting for a dramatic effect.  
 \*/

export const MyAnimation \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    surface2: "\#1A1A1E",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
  };

  const TIMING \= { BASE: 15, FADE: 30, STAGGER: 4 };

  // Entrance spring for scale  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80, mass: 1.2 },  
  });

  // Continuous rotation values for cube  
  const rotationY \= frame \* 0.022;  
  const rotationX \= frame \* 0.011;  
  const rotationZ \= frame \* 0.006;

  // Torus rotates in opposite direction  
  const torusRotationY \= \-frame \* 0.028;  
  const torusRotationX \= frame \* 0.018;  
  const torusRotationZ \= \-frame \* 0.009;

  // Floating Y position  
  const floatY \= Math.sin(frame \* 0.05) \* 0.18;

  // Fade in opacity  
  const opacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Subtle background pulse  
  const bgGlow \= interpolate(  
    Math.sin(frame \* 0.04),  
    \[-1, 1\],  
    \[0.03, 0.08\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // Torus entrance delayed  
  const torusScale \= spring({  
    frame: Math.max(0, frame \- 20),  
    fps,  
    config: { damping: 14, stiffness: 70, mass: 1.4 },  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, rgba(96, 165, 250, ${bgGlow}) 0%, \#000000 70%)\`,  
        display: "flex",  
        alignItems: "center",  
        justifyContent: "center",  
        opacity,  
      }}  
    \>  
      {/\* Subtle floor reflection line \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: Math.round(height \* 0.3),  
          left: "50%",  
          transform: "translateX(-50%)",  
          width: Math.round(width \* 0.25),  
          height: 1,  
          background: \`linear-gradient(90deg, transparent, rgba(96, 165, 250, 0.3), transparent)\`,  
          zIndex: 1,  
        }}  
      /\>

      {/\* Label \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: Math.round(height \* 0.12),  
          left: "50%",  
          transform: "translateX(-50%)",  
          fontFamily: "Inter, sans-serif",  
          fontSize: Math.max(14, Math.round(width \* 0.018)),  
          fontWeight: 300,  
          letterSpacing: "0.25em",  
          color: COLORS.textMuted,  
          textTransform: "uppercase" as const,  
          zIndex: 2,  
          opacity: interpolate(frame, \[20, 50\], \[0, 1\], {  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          }),  
          whiteSpace: "nowrap",  
        }}  
      \>  
        Metallic Cube  
      \</div\>

      {/\* 3D Scene \*/}  
      \<div  
        style={{  
          position: "absolute",  
          inset: 0,  
          zIndex: 1,  
        }}  
      \>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.15} /\>  
          \<directionalLight position={\[5, 8, 5\]} intensity={1.2} color="\#ffffff" /\>  
          \<directionalLight position={\[-5, \-3, \-5\]} intensity={0.4} color="\#60A5FA" /\>  
          \<pointLight position={\[0, 5, 3\]} intensity={0.8} color="\#ffffff" /\>  
          \<pointLight position={\[3, \-2, 2\]} intensity={0.5} color="\#93C5FD" /\>  
          \<pointLight position={\[-3, 2, \-2\]} intensity={0.3} color="\#BFDBFE" /\>

          {/\* Metallic Cube \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, rotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<boxGeometry args={\[2, 2, 2\]} /\>  
            \<meshStandardMaterial  
              color="\#8899AA"  
              metalness={0.95}  
              roughness={0.08}  
            /\>  
          \</mesh\>

          {/\* Subtle inner glow overlay \*/}  
          \<mesh  
            rotation={\[rotationX \* 0.5, rotationY \* 0.5, rotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress \* 1.05, scaleProgress \* 1.05, scaleProgress \* 1.05\]}  
          \>  
            \<boxGeometry args={\[2, 2, 2\]} /\>  
            \<meshStandardMaterial  
              color="\#60A5FA"  
              metalness={1}  
              roughness={0}  
              transparent  
              opacity={0.04}  
            /\>  
          \</mesh\>

          {/\* Torus Ring \- opposite rotation \*/}  
          \<mesh  
            rotation={\[torusRotationX, torusRotationY, torusRotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[torusScale, torusScale, torusScale\]}  
          \>  
            \<torusGeometry args={\[1.72, 0.09, 24, 80\]} /\>  
            \<meshStandardMaterial  
              color="\#93C5FD"  
              metalness={1.0}  
              roughness={0.05}  
            /\>  
          \</mesh\>

          {/\* Second thinner torus at a tilted angle \*/}  
          \<mesh  
            rotation={\[torusRotationX \+ 1.2, torusRotationY \* 0.7, torusRotationZ \- 0.8\]}  
            position={\[0, floatY, 0\]}  
            scale={\[torusScale \* 0.9, torusScale \* 0.9, torusScale \* 0.9\]}  
          \>  
            \<torusGeometry args={\[1.9, 0.05, 16, 80\]} /\>  
            \<meshStandardMaterial  
              color="\#BFDBFE"  
              metalness={1.0}  
              roughness={0.1}  
              transparent  
              opacity={0.7}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação explicando o crescimento de uma startup de 0 a 1 milhão de usuários.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
  Sequence,  
} from "remotion";  
import { TransitionSeries, linearTiming } from "@remotion/transitions";  
import { fade } from "@remotion/transitions/fade";  
import { slide } from "@remotion/transitions/slide";

// ─── MILESTONE CARD ───────────────────────────────────────────────────────────  
const MilestoneCard \= ({  
  label,  
  value,  
  color,  
  delay,  
  frame,  
  fps,  
}: {  
  label: string;  
  value: string;  
  color: string;  
  delay: number;  
  frame: number;  
  fps: number;  
}) \=\> {  
  const enter \= spring({  
    frame: frame \- delay,  
    fps,  
    config: { damping: 18, stiffness: 120 },  
  });  
  const opacity \= interpolate(frame \- delay, \[0, 10\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  return (  
    \<div  
      style={{  
        opacity,  
        transform: \`translateY(${interpolate(enter, \[0, 1\], \[24, 0\])}px)\`,  
        background: "rgba(255,255,255,0.04)",  
        border: \`1px solid rgba(255,255,255,0.08)\`,  
        borderRadius: 16,  
        padding: "20px 28px",  
        display: "flex",  
        flexDirection: "column",  
        gap: 6,  
        minWidth: 160,  
      }}  
    \>  
      \<div  
        style={{  
          width: 8,  
          height: 8,  
          borderRadius: "50%",  
          backgroundColor: color,  
          boxShadow: \`0 0 10px ${color}\`,  
          marginBottom: 4,  
        }}  
      /\>  
      \<div  
        style={{  
          fontFamily: "Inter, sans-serif",  
          fontWeight: 700,  
          fontSize: 28,  
          color: "\#FFFFFF",  
          letterSpacing: "-0.02em",  
        }}  
      \>  
        {value}  
      \</div\>  
      \<div  
        style={{  
          fontFamily: "Inter, sans-serif",  
          fontWeight: 400,  
          fontSize: 13,  
          color: "\#A0A0A8",  
          letterSpacing: "0.01em",  
        }}  
      \>  
        {label}  
      \</div\>  
    \</div\>  
  );  
};

// ─── PHASE BAR ────────────────────────────────────────────────────────────────  
const PhaseBar \= ({  
  label,  
  percent,  
  color,  
  delay,  
  frame,  
  fps,  
}: {  
  label: string;  
  percent: number;  
  color: string;  
  delay: number;  
  frame: number;  
  fps: number;  
}) \=\> {  
  const progress \= spring({  
    frame: frame \- delay,  
    fps,  
    config: { damping: 22, stiffness: 80 },  
  });  
  const widthPercent \= interpolate(progress, \[0, 1\], \[0, percent\]);  
  const opacity \= interpolate(frame \- delay, \[0, 12\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  return (  
    \<div style={{ opacity, display: "flex", flexDirection: "column", gap: 10 }}\>  
      \<div  
        style={{  
          display: "flex",  
          justifyContent: "space-between",  
          alignItems: "center",  
        }}  
      \>  
        \<span  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: 15,  
            fontWeight: 500,  
            color: "\#E0E0E8",  
            letterSpacing: "0.01em",  
          }}  
        \>  
          {label}  
        \</span\>  
        \<span  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: 14,  
            fontWeight: 700,  
            color,  
          }}  
        \>  
          {Math.round(widthPercent)}%  
        \</span\>  
      \</div\>  
      \<div  
        style={{  
          height: 10,  
          borderRadius: 10,  
          backgroundColor: "rgba(255,255,255,0.07)",  
          overflow: "hidden",  
        }}  
      \>  
        \<div  
          style={{  
            height: "100%",  
            width: \`${widthPercent}%\`,  
            borderRadius: 10,  
            background: \`linear-gradient(90deg, ${color}99, ${color})\`,  
            transition: "none",  
          }}  
        /\>  
      \</div\>  
    \</div\>  
  );  
};

// ─── SCENE 1: HERO / INTRO ────────────────────────────────────────────────────  
const SceneHero \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
    accent2: "\#60A5FA",  
  };

  const titleEnter \= spring({ frame, fps, config: { damping: 28, stiffness: 80 } });  
  const subtitleOpacity \= interpolate(frame, \[20, 45\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const subtitleY \= interpolate(frame, \[20, 45\], \[20, 0\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const badgeOpacity \= interpolate(frame, \[40, 60\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const badgeScale \= spring({ frame: frame \- 40, fps, config: { damping: 14, stiffness: 140 } });

  const lineWidth \= interpolate(frame, \[50, 85\], \[0, 260\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const orbScale \= interpolate(Math.sin(frame \* 0.03), \[-1, 1\], \[0.95, 1.05\]);

  const titleSize \= Math.max(52, Math.round(width \* 0.072));  
  const subtitleSize \= Math.max(18, Math.round(width \* 0.022));

  return (  
    \<AbsoluteFill  
      style={{  
        background: "radial-gradient(ellipse 80% 60% at 50% 40%, \#0E1F12 0%, \#000000 70%)",  
        display: "flex",  
        flexDirection: "column",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
      }}  
    \>  
      {/\* Ambient orb \*/}  
      \<div  
        style={{  
          position: "absolute",  
          width: Math.round(width \* 0.6),  
          height: Math.round(height \* 0.4),  
          borderRadius: "50%",  
          background: "radial-gradient(circle, rgba(52,211,153,0.12) 0%, transparent 70%)",  
          transform: \`scale(${orbScale})\`,  
          top: "10%",  
          left: "20%",  
          zIndex: 0,  
        }}  
      /\>

      {/\* Badge \*/}  
      \<div  
        style={{  
          opacity: badgeOpacity,  
          transform: \`scale(${badgeScale})\`,  
          background: "rgba(52,211,153,0.12)",  
          border: "1px solid rgba(52,211,153,0.3)",  
          borderRadius: 24,  
          padding: "8px 20px",  
          marginBottom: 28,  
          zIndex: 1,  
        }}  
      \>  
        \<span  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 600,  
            fontSize: 13,  
            color: COLORS.accent,  
            letterSpacing: "0.08em",  
            textTransform: "uppercase",  
          }}  
        \>  
          Case de Crescimento  
        \</span\>  
      \</div\>

      {/\* Title \*/}  
      \<div  
        style={{  
          opacity: titleEnter,  
          transform: \`translateY(${interpolate(titleEnter, \[0, 1\], \[40, 0\])}px)\`,  
          textAlign: "center",  
          zIndex: 1,  
          padding: "0 40px",  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 900,  
            fontSize: titleSize,  
            color: COLORS.text,  
            letterSpacing: "-0.03em",  
            lineHeight: 1.05,  
          }}  
        \>  
          De \<span style={{ color: COLORS.accent }}\>0\</span\> a{" "}  
          \<span  
            style={{  
              background: \`linear-gradient(135deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            1 Milhão  
          \</span\>  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 900,  
            fontSize: titleSize,  
            color: COLORS.text,  
            letterSpacing: "-0.03em",  
            lineHeight: 1.05,  
            marginTop: 4,  
          }}  
        \>  
          de Usuários  
        \</div\>  
      \</div\>

      {/\* Divider \*/}  
      \<div  
        style={{  
          width: lineWidth,  
          height: 2,  
          background: \`linear-gradient(90deg, transparent, ${COLORS.accent}, transparent)\`,  
          borderRadius: 2,  
          marginTop: 28,  
          marginBottom: 20,  
          zIndex: 1,  
        }}  
      /\>

      {/\* Subtitle \*/}  
      \<div  
        style={{  
          opacity: subtitleOpacity,  
          transform: \`translateY(${subtitleY}px)\`,  
          textAlign: "center",  
          maxWidth: Math.round(width \* 0.55),  
          zIndex: 1,  
        }}  
      \>  
        \<p  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 400,  
            fontSize: subtitleSize,  
            color: COLORS.textMuted,  
            letterSpacing: "0.01em",  
            lineHeight: 1.5,  
            margin: 0,  
          }}  
        \>  
          A jornada real de uma startup — do zero ao primeiro milhão com estratégia, produto e resiliência.  
        \</p\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── SCENE 2: PHASE 0 — IDEATION ─────────────────────────────────────────────  
const SceneIdeation \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    bg: "\#000000",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#F59E0B",  
    surface: "rgba(245,158,11,0.06)",  
  };

  const titleEnter \= spring({ frame, fps, config: { damping: 24, stiffness: 90 } });  
  const titleSize \= Math.max(40, Math.round(width \* 0.055));  
  const bodySize \= Math.max(14, Math.round(width \* 0.018));

  const items \= \[  
    { text: "Identificar um problema real", delay: 10 },  
    { text: "Entrevistar 50+ potenciais usuários", delay: 20 },  
    { text: "Definir hipóteses de valor", delay: 30 },  
    { text: "Prototipar em papel em 1 semana", delay: 40 },  
  \];

  const counterProgress \= interpolate(frame, \[30, 80\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const userCount \= Math.round(counterProgress \* 0);

  return (  
    \<AbsoluteFill  
      style={{  
        background: "radial-gradient(ellipse 70% 50% at 30% 50%, \#1A1000 0%, \#000000 70%)",  
        display: "flex",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
      }}  
    \>  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          gap: Math.round(width \* 0.06),  
          alignItems: "center",  
          padding: "0 60px",  
          width: "100%",  
        }}  
      \>  
        {/\* Left: Phase label \+ items \*/}  
        \<div style={{ flex: 1 }}\>  
          {/\* Phase tag \*/}  
          \<div  
            style={{  
              opacity: interpolate(frame, \[0, 12\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
              display: "inline-flex",  
              alignItems: "center",  
              gap: 8,  
              background: "rgba(245,158,11,0.12)",  
              border: "1px solid rgba(245,158,11,0.3)",  
              borderRadius: 20,  
              padding: "6px 16px",  
              marginBottom: 20,  
            }}  
          \>  
            \<div style={{ width: 7, height: 7, borderRadius: "50%", backgroundColor: COLORS.accent }} /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 600,  
                fontSize: 12,  
                color: COLORS.accent,  
                letterSpacing: "0.08em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Fase 1 — Ideação  
            \</span\>  
          \</div\>

          \<div  
            style={{  
              opacity: titleEnter,  
              transform: \`translateY(${interpolate(titleEnter, \[0, 1\], \[30, 0\])}px)\`,  
            }}  
          \>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 800,  
                fontSize: titleSize,  
                color: COLORS.text,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.1,  
                marginBottom: 8,  
              }}  
            \>  
              Validando a  
            \</div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 800,  
                fontSize: titleSize,  
                color: COLORS.accent,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.1,  
                marginBottom: 24,  
              }}  
            \>  
              Ideia  
            \</div\>  
          \</div\>

          \<div style={{ display: "flex", flexDirection: "column", gap: 14 }}\>  
            {items.map((item, i) \=\> {  
              const itemOpacity \= interpolate(frame \- item.delay, \[0, 14\], \[0, 1\], {  
                extrapolateLeft: "clamp",  
                extrapolateRight: "clamp",  
              });  
              const itemX \= interpolate(frame \- item.delay, \[0, 14\], \[-20, 0\], {  
                easing: Easing.bezier(0.16, 1, 0.3, 1),  
                extrapolateLeft: "clamp",  
                extrapolateRight: "clamp",  
              });  
              return (  
                \<div  
                  key={i}  
                  style={{  
                    opacity: itemOpacity,  
                    transform: \`translateX(${itemX}px)\`,  
                    display: "flex",  
                    alignItems: "center",  
                    gap: 12,  
                  }}  
                \>  
                  \<div  
                    style={{  
                      width: 24,  
                      height: 24,  
                      borderRadius: 6,  
                      backgroundColor: "rgba(245,158,11,0.15)",  
                      border: "1px solid rgba(245,158,11,0.3)",  
                      display: "flex",  
                      alignItems: "center",  
                      justifyContent: "center",  
                      flexShrink: 0,  
                    }}  
                  \>  
                    \<div style={{ width: 8, height: 8, borderRadius: 2, backgroundColor: COLORS.accent }} /\>  
                  \</div\>  
                  \<span  
                    style={{  
                      fontFamily: "Inter, sans-serif",  
                      fontWeight: 400,  
                      fontSize: bodySize,  
                      color: "\#D0D0D8",  
                      letterSpacing: "0.01em",  
                    }}  
                  \>  
                    {item.text}  
                  \</span\>  
                \</div\>  
              );  
            })}  
          \</div\>  
        \</div\>

        {/\* Right: User counter \*/}  
        \<div  
          style={{  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: 12,  
            opacity: interpolate(frame, \[25, 40\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
          }}  
        \>  
          \<div  
            style={{  
              width: Math.round(width \* 0.28),  
              height: Math.round(height \* 0.38),  
              background: COLORS.surface,  
              border: "1px solid rgba(245,158,11,0.15)",  
              borderRadius: 24,  
              display: "flex",  
              flexDirection: "column",  
              alignItems: "center",  
              justifyContent: "center",  
              gap: 8,  
            }}  
          \>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 900,  
                fontSize: Math.max(48, Math.round(width \* 0.065)),  
                color: COLORS.accent,  
                letterSpacing: "-0.04em",  
                lineHeight: 1,  
              }}  
            \>  
              {userCount.toLocaleString("pt-BR")}  
            \</div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 400,  
                fontSize: 14,  
                color: COLORS.textMuted,  
                letterSpacing: "0.05em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Usuários  
            \</div\>  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: 13,  
              color: "rgba(245,158,11,0.6)",  
              letterSpacing: "0.02em",  
            }}  
          \>  
            Ponto de partida  
          \</div\>  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── SCENE 3: MVP / EARLY TRACTION ───────────────────────────────────────────  
const SceneMVP \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    surface: "rgba(96,165,250,0.06)",  
  };

  const titleEnter \= spring({ frame, fps, config: { damping: 24, stiffness: 90 } });  
  const titleSize \= Math.max(40, Math.round(width \* 0.055));

  const counterProgress \= interpolate(frame, \[20, 75\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const userCount \= Math.round(counterProgress \* 10000);

  const phases \= \[  
    { label: "Desenvolvimento", percent: 85, color: "\#60A5FA", delay: 15 },  
    { label: "Beta Testers", percent: 62, color: "\#34D399", delay: 25 },  
    { label: "Retenção D7", percent: 40, color: "\#F59E0B", delay: 35 },  
  \];

  return (  
    \<AbsoluteFill  
      style={{  
        background: "radial-gradient(ellipse 70% 60% at 70% 50%, \#001A3A 0%, \#000000 70%)",  
        display: "flex",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
      }}  
    \>  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          gap: Math.round(width \* 0.06),  
          alignItems: "center",  
          padding: "0 60px",  
          width: "100%",  
        }}  
      \>  
        {/\* Left: Counter \*/}  
        \<div  
          style={{  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: 12,  
            opacity: interpolate(frame, \[0, 20\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
          }}  
        \>  
          \<div  
            style={{  
              width: Math.round(width \* 0.28),  
              height: Math.round(height \* 0.4),  
              background: COLORS.surface,  
              border: "1px solid rgba(96,165,250,0.15)",  
              borderRadius: 24,  
              display: "flex",  
              flexDirection: "column",  
              alignItems: "center",  
              justifyContent: "center",  
              gap: 8,  
            }}  
          \>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 900,  
                fontSize: Math.max(44, Math.round(width \* 0.06)),  
                color: COLORS.accent,  
                letterSpacing: "-0.04em",  
                lineHeight: 1,  
              }}  
            \>  
              {userCount \>= 1000  
                ? \`${(userCount / 1000).toFixed(userCount \< 10000 ? 1 : 0)}k\`  
                : userCount.toLocaleString("pt-BR")}  
            \</div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 400,  
                fontSize: 14,  
                color: COLORS.textMuted,  
                letterSpacing: "0.05em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Usuários  
            \</div\>  
          \</div\>  
          \<div  
            style={{  
              display: "flex",  
              alignItems: "center",  
              gap: 6,  
              background: "rgba(52,211,153,0.1)",  
              border: "1px solid rgba(52,211,153,0.2)",  
              borderRadius: 20,  
              padding: "5px 12px",  
            }}  
          \>  
            \<span style={{ fontSize: 12, color: "\#34D399", fontFamily: "Inter, sans-serif", fontWeight: 600 }}\>  
              ↑ \+10.000 em 3 meses  
            \</span\>  
          \</div\>  
        \</div\>

        {/\* Right: Info \*/}  
        \<div style={{ flex: 1 }}\>  
          \<div  
            style={{  
              opacity: interpolate(frame, \[0, 12\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
              display: "inline-flex",  
              alignItems: "center",  
              gap: 8,  
              background: "rgba(96,165,250,0.12)",  
              border: "1px solid rgba(96,165,250,0.3)",  
              borderRadius: 20,  
              padding: "6px 16px",  
              marginBottom: 20,  
            }}  
          \>  
            \<div style={{ width: 7, height: 7, borderRadius: "50%", backgroundColor: COLORS.accent }} /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 600,  
                fontSize: 12,  
                color: COLORS.accent,  
                letterSpacing: "0.08em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Fase 2 — MVP  
            \</span\>  
          \</div\>

          \<div  
            style={{  
              opacity: titleEnter,  
              transform: \`translateY(${interpolate(titleEnter, \[0, 1\], \[30, 0\])}px)\`,  
              marginBottom: 28,  
            }}  
          \>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 800,  
                fontSize: titleSize,  
                color: COLORS.text,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.1,  
              }}  
            \>  
              Produto mínimo,  
            \</div\>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 800,  
                fontSize: titleSize,  
                color: COLORS.accent,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.1,  
              }}  
            \>  
              máximo aprendizado  
            \</div\>  
          \</div\>

          \<div style={{ display: "flex", flexDirection: "column", gap: 18 }}\>  
            {phases.map((phase, i) \=\> (  
              \<PhaseBar key={i} {...phase} frame={frame} fps={fps} /\>  
            ))}  
          \</div\>  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── SCENE 4: GROWTH / PMF ────────────────────────────────────────────────────  
const SceneGrowth \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
    accent2: "\#60A5FA",  
  };

  const titleSize \= Math.max(38, Math.round(width \* 0.052));  
  const counterProgress \= interpolate(frame, \[15, 80\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const userCount \= Math.round(counterProgress \* 500000);

  const milestones \= \[  
    { label: "Mês 1", value: "0", color: "\#A0A0A8", delay: 10 },  
    { label: "Mês 6", value: "10k", color: "\#60A5FA", delay: 20 },  
    { label: "Mês 12", value: "100k", color: "\#F59E0B", delay: 30 },  
    { label: "Mês 18", value: "500k", color: "\#34D399", delay: 40 },  
  \];

  // Chart points  
  const chartW \= Math.round(width \* 0.55);  
  const chartH \= Math.round(height \* 0.35);  
  const chartProgress \= interpolate(frame, \[20, 80\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const rawPoints \= \[  
    { x: 0, y: 1 },  
    { x: 0.15, y: 0.95 },  
    { x: 0.3, y: 0.82 },  
    { x: 0.45, y: 0.65 },  
    { x: 0.6, y: 0.42 },  
    { x: 0.75, y: 0.22 },  
    { x: 0.85, y: 0.1 },  
    { x: 1, y: 0 },  
  \];

  const clampedProgress \= Math.min(chartProgress, 1);  
  const visiblePoints \= rawPoints.filter((p) \=\> p.x \<= clampedProgress);  
  if (visiblePoints.length \< rawPoints.length) {  
    const next \= rawPoints\[visiblePoints.length\];  
    const prev \= visiblePoints\[visiblePoints.length \- 1\];  
    if (prev && next) {  
      const t \= (clampedProgress \- prev.x) / (next.x \- prev.x);  
      visiblePoints.push({ x: clampedProgress, y: prev.y \+ (next.y \- prev.y) \* t });  
    }  
  }

  const toSVG \= (p: { x: number; y: number }) \=\> ({  
    sx: p.x \* chartW,  
    sy: p.y \* chartH,  
  });

  const pathData \=  
    visiblePoints.length \> 1  
      ? visiblePoints  
          .map((p, i) \=\> {  
            const { sx, sy } \= toSVG(p);  
            return \`${i \=== 0 ? "M" : "L"} ${sx} ${sy}\`;  
          })  
          .join(" ")  
      : "";

  return (  
    \<AbsoluteFill  
      style={{  
        background: "radial-gradient(ellipse 80% 60% at 50% 60%, \#001A0E 0%, \#000000 70%)",  
        display: "flex",  
        flexDirection: "column",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
        padding: "0 60px",  
      }}  
    \>  
      {/\* Top section \*/}  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          alignItems: "flex-start",  
          justifyContent: "space-between",  
          width: "100%",  
          marginBottom: 30,  
        }}  
      \>  
        \<div\>  
          \<div  
            style={{  
              opacity: interpolate(frame, \[0, 12\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
              display: "inline-flex",  
              alignItems: "center",  
              gap: 8,  
              background: "rgba(52,211,153,0.12)",  
              border: "1px solid rgba(52,211,153,0.3)",  
              borderRadius: 20,  
              padding: "6px 16px",  
              marginBottom: 16,  
            }}  
          \>  
            \<div style={{ width: 7, height: 7, borderRadius: "50%", backgroundColor: COLORS.accent }} /\>  
            \<span  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 600,  
                fontSize: 12,  
                color: COLORS.accent,  
                letterSpacing: "0.08em",  
                textTransform: "uppercase",  
              }}  
            \>  
              Fase 3 — Crescimento  
            \</span\>  
          \</div\>  
          \<div  
            style={{  
              opacity: spring({ frame, fps, config: { damping: 26, stiffness: 90 } }),  
              transform: \`translateY(${interpolate(  
                spring({ frame, fps, config: { damping: 26, stiffness: 90 } }),  
                \[0, 1\],  
                \[24, 0\]  
              )}px)\`,  
            }}  
          \>  
            \<div  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontWeight: 800,  
                fontSize: titleSize,  
                color: COLORS.text,  
                letterSpacing: "-0.02em",  
                lineHeight: 1.1,  
              }}  
            \>  
              Tração Real &{" "}  
              \<span style={{ color: COLORS.accent }}\>Product-Market Fit\</span\>  
            \</div\>  
          \</div\>  
        \</div\>

        {/\* Big counter \*/}  
        \<div  
          style={{  
            textAlign: "right",  
            opacity: interpolate(frame, \[10, 25\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 900,  
              fontSize: Math.max(44, Math.round(width \* 0.065)),  
              color: COLORS.accent,  
              letterSpacing: "-0.04em",  
              lineHeight: 1,  
            }}  
          \>  
            {userCount \>= 1000  
              ? \`${(userCount / 1000).toFixed(0)}k\`  
              : userCount.toLocaleString("pt-BR")}  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 400,  
              fontSize: 13,  
              color: COLORS.textMuted,  
              letterSpacing: "0.05em",  
              textTransform: "uppercase",  
              marginTop: 4,  
            }}  
          \>  
            Usuários  
          \</div\>  
        \</div\>  
      \</div\>

      {/\* Chart \+ milestones \*/}  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          gap: 40,  
          alignItems: "flex-end",  
          width: "100%",  
        }}  
      \>  
        {/\* SVG Chart \*/}  
        \<div  
          style={{  
            opacity: interpolate(frame, \[18, 35\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
            flex: 1,  
          }}  
        \>  
          \<svg  
            width="100%"  
            viewBox={\`0 0 ${chartW} ${chartH \+ 20}\`}  
            style={{ overflow: "visible" }}  
          \>  
            {/\* Grid lines \*/}  
            {\[0, 0.25, 0.5, 0.75, 1\].map((y, i) \=\> (  
              \<line  
                key={i}  
                x1={0}  
                y1={y \* chartH}  
                x2={chartW}  
                y2={y \* chartH}  
                stroke="rgba(255,255,255,0.05)"  
                strokeWidth={1}  
              /\>  
            ))}  
            {/\* Area fill \*/}  
            {pathData && (  
              \<path  
                d={\`${pathData} L ${visiblePoints\[visiblePoints.length \- 1\].x \* chartW} ${chartH} L 0 ${chartH} Z\`}  
                fill={\`url(\#areaGrad)\`}  
              /\>  
            )}  
            {/\* Line \*/}  
            {pathData && (  
              \<path  
                d={pathData}  
                fill="none"  
                stroke={COLORS.accent}  
                strokeWidth={3}  
                strokeLinecap="round"  
                strokeLinejoin="round"  
              /\>  
            )}  
            {/\* Gradient def \*/}  
            \<defs\>  
              \<linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1"\>  
                \<stop offset="0%" stopColor={COLORS.accent} stopOpacity={0.25} /\>  
                \<stop offset="100%" stopColor={COLORS.accent} stopOpacity={0.02} /\>  
              \</linearGradient\>  
            \</defs\>  
            {/\* Dot at tip \*/}  
            {visiblePoints.length \> 0 && (() \=\> {  
              const last \= visiblePoints\[visiblePoints.length \- 1\];  
              const { sx, sy } \= toSVG(last);  
              return (  
                \<\>  
                  \<circle cx={sx} cy={sy} r={7} fill={COLORS.accent} opacity={0.25} /\>  
                  \<circle cx={sx} cy={sy} r={4} fill={COLORS.accent} /\>  
                \</\>  
              );  
            })()}  
          \</svg\>  
        \</div\>

        {/\* Milestones \*/}  
        \<div style={{ display: "flex", flexDirection: "column", gap: 12 }}\>  
          {milestones.map((m, i) \=\> (  
            \<MilestoneCard key={i} {...m} frame={frame} fps={fps} /\>  
          ))}  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── SCENE 5: SCALING / 1M ────────────────────────────────────────────────────  
const ScaleTo1M \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
    accent2: "\#60A5FA",  
    gold: "\#F59E0B",  
  };

  const titleSize \= Math.max(42, Math.round(width \* 0.058));  
  const bigSize \= Math.max(64, Math.round(width \* 0.1));

  const counterProgress \= interpolate(frame, \[10, 80\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const userCount \= Math.round(counterProgress \* 1000000);

  const orbPulse \= interpolate(Math.sin(frame \* 0.06), \[-1, 1\], \[0.9, 1.1\]);

  const bigCounterEnter \= spring({ frame: frame \- 8, fps, config: { damping: 26, stiffness: 70 } });

  const stats \= \[  
    { label: "MRR", value: "$120k", color: COLORS.gold, delay: 30 },  
    { label: "NPS Score", value: "72", color: COLORS.accent, delay: 40 },  
    { label: "Retenção M6", value: "68%", color: COLORS.accent2, delay: 50 },  
    { label: "Tempo médio", value: "8.4 min/dia", color: "\#C084FC", delay: 60 },  
  \];

  return (  
    \<AbsoluteFill  
      style={{  
        background: "\#000000",  
        display: "flex",  
        flexDirection: "column",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
      }}  
    \>  
      {/\* Glow orbs \*/}  
      \<div  
        style={{  
          position: "absolute",  
          width: Math.round(width \* 0.7),  
          height: Math.round(height \* 0.5),  
          borderRadius: "50%",  
          background:  
            "radial-gradient(circle, rgba(52,211,153,0.15) 0%, transparent 70%)",  
          transform: \`scale(${orbPulse})\`,  
          top: "5%",  
          left: "15%",  
          zIndex: 0,  
        }}  
      /\>  
      \<div  
        style={{  
          position: "absolute",  
          width: Math.round(width \* 0.5),  
          height: Math.round(height \* 0.4),  
          borderRadius: "50%",  
          background:  
            "radial-gradient(circle, rgba(96,165,250,0.1) 0%, transparent 70%)",  
          transform: \`scale(${1 / orbPulse})\`,  
          bottom: "5%",  
          right: "10%",  
          zIndex: 0,  
        }}  
      /\>

      {/\* Badge \*/}  
      \<div  
        style={{  
          opacity: interpolate(frame, \[0, 14\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
          transform: \`scale(${spring({ frame, fps, config: { damping: 14, stiffness: 140 } })})\`,  
          background:  
            "linear-gradient(135deg, rgba(52,211,153,0.15), rgba(96,165,250,0.15))",  
          border: "1px solid rgba(52,211,153,0.4)",  
          borderRadius: 28,  
          padding: "8px 24px",  
          marginBottom: 20,  
          zIndex: 1,  
        }}  
      \>  
        \<span  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 700,  
            fontSize: 13,  
            color: COLORS.accent,  
            letterSpacing: "0.1em",  
            textTransform: "uppercase",  
          }}  
        \>  
          🎉 Fase Final — 1 Milhão  
        \</span\>  
      \</div\>

      {/\* Big counter \*/}  
      \<div  
        style={{  
          opacity: bigCounterEnter,  
          transform: \`scale(${interpolate(bigCounterEnter, \[0, 1\], \[0.85, 1\])})\`,  
          textAlign: "center",  
          zIndex: 1,  
          marginBottom: 12,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 900,  
            fontSize: bigSize,  
            letterSpacing: "-0.04em",  
            lineHeight: 1,  
            background: \`linear-gradient(135deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
            WebkitBackgroundClip: "text",  
            WebkitTextFillColor: "transparent",  
          }}  
        \>  
          {userCount \>= 1000000  
            ? "1.000.000"  
            : userCount \>= 1000  
            ? \`${(userCount / 1000).toFixed(0)}.000\`  
            : userCount.toLocaleString("pt-BR")}  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 300,  
            fontSize: Math.max(16, Math.round(width \* 0.02)),  
            color: COLORS.textMuted,  
            letterSpacing: "0.12em",  
            textTransform: "uppercase",  
            marginTop: 8,  
          }}  
        \>  
          Usuários Ativos  
        \</div\>  
      \</div\>

      {/\* Divider \*/}  
      \<div  
        style={{  
          width: interpolate(frame, \[30, 60\], \[0, Math.round(width \* 0.5)\], {  
            easing: Easing.bezier(0.16, 1, 0.3, 1),  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          }),  
          height: 1,  
          background: \`linear-gradient(90deg, transparent, ${COLORS.accent}66, ${COLORS.accent2}66, transparent)\`,  
          borderRadius: 2,  
          marginBottom: 28,  
          zIndex: 1,  
        }}  
      /\>

      {/\* Stats row \*/}  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          gap: 16,  
          zIndex: 1,  
          flexWrap: "wrap",  
          justifyContent: "center",  
          padding: "0 40px",  
        }}  
      \>  
        {stats.map((s, i) \=\> {  
          const sOpacity \= interpolate(frame \- s.delay, \[0, 16\], \[0, 1\], {  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          });  
          const sY \= interpolate(frame \- s.delay, \[0, 16\], \[16, 0\], {  
            easing: Easing.bezier(0.16, 1, 0.3, 1),  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          });  
          return (  
            \<div  
              key={i}  
              style={{  
                opacity: sOpacity,  
                transform: \`translateY(${sY}px)\`,  
                background: "rgba(255,255,255,0.04)",  
                border: "1px solid rgba(255,255,255,0.07)",  
                borderRadius: 16,  
                padding: "16px 24px",  
                display: "flex",  
                flexDirection: "column",  
                alignItems: "center",  
                gap: 4,  
                minWidth: 120,  
              }}  
            \>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontWeight: 700,  
                  fontSize: Math.max(22, Math.round(width \* 0.03)),  
                  color: s.color,  
                  letterSpacing: "-0.02em",  
                }}  
              \>  
                {s.value}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontWeight: 400,  
                  fontSize: 12,  
                  color: COLORS.textMuted,  
                  letterSpacing: "0.04em",  
                  textTransform: "uppercase",  
                }}  
              \>  
                {s.label}  
              \</div\>  
            \</div\>  
          );  
        })}  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── SCENE 6: LESSONS / CLOSING ───────────────────────────────────────────────  
const SceneClosing \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  const COLORS \= {  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
    accent2: "\#60A5FA",  
  };

  const titleSize \= Math.max(38, Math.round(width \* 0.05));  
  const bodySize \= Math.max(14, Math.round(width \* 0.018));

  const lessons \= \[  
    { icon: "🎯", title: "Problema antes de produto", text: "Validar o mercado antes de escrever código salva meses de trabalho." },  
    { icon: "🔁", title: "Iterate com dados reais", text: "Cada usuário é uma fonte de aprendizado. Ouça e adapte rápido." },  
    { icon: "📈", title: "Distribuição é estratégia", text: "Sem canal de aquisição escalável, o melhor produto fica invisível." },  
    { icon: "🧠", title: "Retenção \> Aquisição", text: "Reter 10% a mais vale mais do que dobrar a aquisição." },  
  \];

  const headerEnter \= spring({ frame, fps, config: { damping: 24, stiffness: 90 } });

  return (  
    \<AbsoluteFill  
      style={{  
        background: "radial-gradient(ellipse 80% 60% at 50% 30%, \#0A001F 0%, \#000000 65%)",  
        display: "flex",  
        flexDirection: "column",  
        alignItems: "center",  
        justifyContent: "center",  
        overflow: "hidden",  
        padding: "0 60px",  
      }}  
    \>  
      {/\* Header \*/}  
      \<div  
        style={{  
          opacity: headerEnter,  
          transform: \`translateY(${interpolate(headerEnter, \[0, 1\], \[28, 0\])}px)\`,  
          textAlign: "center",  
          marginBottom: 36,  
          zIndex: 1,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 800,  
            fontSize: titleSize,  
            letterSpacing: "-0.02em",  
            lineHeight: 1.1,  
            color: COLORS.text,  
          }}  
        \>  
          O que{" "}  
          \<span  
            style={{  
              background: \`linear-gradient(135deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            realmente importa  
          \</span\>  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 400,  
            fontSize: Math.max(14, Math.round(width \* 0.018)),  
            color: COLORS.textMuted,  
            marginTop: 10,  
            letterSpacing: "0.01em",  
          }}  
        \>  
          4 lições da jornada de 0 → 1M de usuários  
        \</div\>  
      \</div\>

      {/\* Lessons grid \*/}  
      \<div  
        style={{  
          display: "grid",  
          gridTemplateColumns: "1fr 1fr",  
          gap: 16,  
          width: "100%",  
          maxWidth: Math.round(width \* 0.85),  
        }}  
      \>  
        {lessons.map((lesson, i) \=\> {  
          const delay \= 15 \+ i \* 12;  
          const cardOpacity \= interpolate(frame \- delay, \[0, 18\], \[0, 1\], {  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          });  
          const cardY \= interpolate(frame \- delay, \[0, 18\], \[20, 0\], {  
            easing: Easing.bezier(0.16, 1, 0.3, 1),  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          });  
          return (  
            \<div  
              key={i}  
              style={{  
                opacity: cardOpacity,  
                transform: \`translateY(${cardY}px)\`,  
                background: "rgba(255,255,255,0.03)",  
                border: "1px solid rgba(255,255,255,0.07)",  
                borderRadius: 18,  
                padding: "22px 24px",  
                display: "flex",  
                flexDirection: "column",  
                gap: 8,  
              }}  
            \>  
              \<div style={{ fontSize: Math.round(width \* 0.028), lineHeight: 1 }}\>{lesson.icon}\</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontWeight: 700,  
                  fontSize: Math.max(15, Math.round(width \* 0.02)),  
                  color: COLORS.text,  
                  letterSpacing: "-0.01em",  
                }}  
              \>  
                {lesson.title}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontWeight: 400,  
                  fontSize: bodySize,  
                  color: COLORS.textMuted,  
                  letterSpacing: "0.01em",  
                  lineHeight: 1.45,  
                }}  
              \>  
                {lesson.text}  
              \</div\>  
            \</div\>  
          );  
        })}  
      \</div\>

      {/\* Bottom CTA \*/}  
      \<div  
        style={{  
          opacity: interpolate(frame, \[65, 80\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
          marginTop: 28,  
          textAlign: "center",  
          zIndex: 1,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontWeight: 600,  
            fontSize: Math.max(14, Math.round(width \* 0.018)),  
            color: COLORS.accent,  
            letterSpacing: "0.06em",  
            textTransform: "uppercase",  
          }}  
        \>  
          Sua startup pode ser a próxima história ✦  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── MAIN EXPORT ──────────────────────────────────────────────────────────────  
export const MyAnimation \= () \=\> {  
  /\*  
   \* Six-scene startup growth story animation.  
   \* Covers ideation, MVP, traction, scaling, 1M milestone, and closing lessons.  
   \* Uses premium dark palette with green/blue accent driven by interpolate \+ spring.  
   \*/  
  const { fps } \= useVideoConfig();

  const TIMING \= {  
    HERO: 95,  
    IDEATION: 100,  
    MVP: 100,  
    GROWTH: 110,  
    MILLION: 110,  
    CLOSING: 110,  
    TRANSITION: 18,  
  };

  return (  
    \<TransitionSeries\>  
      \<TransitionSeries.Sequence durationInFrames={TIMING.HERO} premountFor={fps}\>  
        \<SceneHero /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={fade()}  
        timing={linearTiming({ durationInFrames: TIMING.TRANSITION })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={TIMING.IDEATION} premountFor={fps}\>  
        \<SceneIdeation /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={slide({ direction: "from-right" })}  
        timing={linearTiming({ durationInFrames: TIMING.TRANSITION })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={TIMING.MVP} premountFor={fps}\>  
        \<SceneMVP /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={slide({ direction: "from-right" })}  
        timing={linearTiming({ durationInFrames: TIMING.TRANSITION })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={TIMING.GROWTH} premountFor={fps}\>  
        \<SceneGrowth /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={fade()}  
        timing={linearTiming({ durationInFrames: TIMING.TRANSITION })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={TIMING.MILLION} premountFor={fps}\>  
        \<ScaleTo1M /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={slide({ direction: "from-bottom" })}  
        timing={linearTiming({ durationInFrames: TIMING.TRANSITION })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={TIMING.CLOSING} premountFor={fps}\>  
        \<SceneClosing /\>  
      \</TransitionSeries.Sequence\>  
    \</TransitionSeries\>  
  );  
};

prompt:

Crie uma animação de slides de apresentação corporativa com texto e gráficos.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
  Sequence,  
} from "remotion";  
import { TransitionSeries, linearTiming } from "@remotion/transitions";  
import { fade } from "@remotion/transitions/fade";  
import { slide } from "@remotion/transitions/slide";

// ── TOKENS ──────────────────────────────────────────────────────────────────  
const COLORS \= {  
  bg: "\#0A0C10",  
  surface1: "\#111318",  
  surface2: "\#1C2028",  
  border: "\#252A33",  
  text: "\#F0F2F5",  
  textMuted: "\#7A8494",  
  accent: "\#3B82F6",  
  accentSoft: "\#1E3A5F",  
  accent2: "\#10B981",  
  accent3: "\#F59E0B",  
  accent4: "\#8B5CF6",  
};  
const TIMING \= { BASE: 30, STAGGER: 6, FADE: 20 };

// ── BAR CHART DATA ───────────────────────────────────────────────────────────  
const BAR\_DATA \= \[  
  { label: "Q1", value: 62, color: COLORS.accent },  
  { label: "Q2", value: 78, color: COLORS.accent },  
  { label: "Q3", value: 91, color: COLORS.accent2 },  
  { label: "Q4", value: 110, color: COLORS.accent2 },  
\];  
const MAX\_VAL \= 120;

// ── KPI CARDS ────────────────────────────────────────────────────────────────  
const KPIS \= \[  
  { label: "Revenue", value: "$12.4M", delta: "+18%", color: COLORS.accent2 },  
  { label: "Users", value: "284K", delta: "+34%", color: COLORS.accent },  
  { label: "NPS Score", value: "74", delta: "+12pts", color: COLORS.accent4 },  
  { label: "Churn Rate", value: "1.8%", delta: "–0.4%", color: COLORS.accent3 },  
\];

// ── PIE DATA ────────────────────────────────────────────────────────────────  
const PIE\_SEGMENTS \= \[  
  { label: "Americas", pct: 42, color: COLORS.accent },  
  { label: "Europe", pct: 31, color: COLORS.accent2 },  
  { label: "APAC", pct: 19, color: COLORS.accent4 },  
  { label: "Other", pct: 8, color: COLORS.accent3 },  
\];

// ── SCENE 1: TITLE SLIDE ─────────────────────────────────────────────────────  
const Scene1 \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const logoScale \= spring({ frame, fps, config: { damping: 18, stiffness: 100 }, durationInFrames: 40 });  
  const titleY \= interpolate(frame, \[10, 45\], \[40, 0\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });  
  const titleOp \= interpolate(frame, \[10, 40\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const subY \= interpolate(frame, \[28, 58\], \[30, 0\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });  
  const subOp \= interpolate(frame, \[28, 55\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const lineW \= interpolate(frame, \[20, 55\], \[0, 1\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });  
  const badgeOp \= interpolate(frame, \[50, 75\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const badgeY \= interpolate(frame, \[50, 75\], \[20, 0\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });

  const titleSize \= Math.max(48, Math.round(width \* 0.062));  
  const subSize \= Math.max(18, Math.round(width \* 0.022));

  return (  
    \<AbsoluteFill style={{ background: \`radial-gradient(ellipse at 30% 40%, \#0F1B35 0%, ${COLORS.bg} 70%)\` }}\>  
      {/\* Grid lines \*/}  
      \<AbsoluteFill style={{ opacity: 0.06 }}\>  
        {Array.from({ length: 8 }).map((\_, i) \=\> (  
          \<div key={i} style={{  
            position: "absolute", left: \`${i \* 14.28}%\`, top: 0, bottom: 0,  
            width: 1, background: COLORS.text,  
          }} /\>  
        ))}  
      \</AbsoluteFill\>

      {/\* Accent orb \*/}  
      \<div style={{  
        position: "absolute", left: "-10%", top: "-10%",  
        width: "55%", height: "55%",  
        borderRadius: "50%",  
        background: \`radial-gradient(circle, ${COLORS.accentSoft}55 0%, transparent 70%)\`,  
        filter: "blur(60px)",  
      }} /\>

      {/\* Logo mark \*/}  
      \<div style={{  
        position: "absolute", top: Math.round(height \* 0.1), left: Math.round(width \* 0.08),  
        transform: \`scale(${logoScale})\`,  
        display: "flex", alignItems: "center", gap: 12,  
      }}\>  
        \<div style={{  
          width: 42, height: 42, borderRadius: 10,  
          background: \`linear-gradient(135deg, ${COLORS.accent}, ${COLORS.accent4})\`,  
          display: "flex", alignItems: "center", justifyContent: "center",  
          fontFamily: "Inter, sans-serif", fontWeight: 900, fontSize: 20, color: "\#fff",  
        }}\>A\</div\>  
        \<span style={{ fontFamily: "Inter, sans-serif", fontWeight: 700, fontSize: 18, color: COLORS.text, letterSpacing: "0.02em" }}\>  
          APEX CORP  
        \</span\>  
      \</div\>

      {/\* Main content \*/}  
      \<div style={{  
        position: "absolute", left: Math.round(width \* 0.08), top: "50%",  
        transform: "translateY(-50%)", maxWidth: "65%",  
      }}\>  
        \<div style={{  
          width: \`${lineW \* 80}px\`, height: 3, background: \`linear-gradient(90deg, ${COLORS.accent}, ${COLORS.accent4})\`,  
          borderRadius: 2, marginBottom: 28,  
        }} /\>  
        \<div style={{  
          opacity: titleOp, transform: \`translateY(${titleY}px)\`,  
          fontFamily: "Inter, sans-serif", fontWeight: 800,  
          fontSize: titleSize, color: COLORS.text,  
          letterSpacing: "-0.02em", lineHeight: 1.1,  
          marginBottom: 20,  
        }}\>  
          Annual Business\<br /\>  
          \<span style={{  
            background: \`linear-gradient(90deg, ${COLORS.accent}, ${COLORS.accent4})\`,  
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent",  
          }}\>Review 2024\</span\>  
        \</div\>  
        \<div style={{  
          opacity: subOp, transform: \`translateY(${subY}px)\`,  
          fontFamily: "Inter, sans-serif", fontWeight: 400,  
          fontSize: subSize, color: COLORS.textMuted,  
          letterSpacing: "0.01em", lineHeight: 1.5,  
        }}\>  
          Strategic Performance · Growth Analysis · Market Outlook  
        \</div\>  
      \</div\>

      {/\* Year badge \*/}  
      \<div style={{  
        position: "absolute", right: Math.round(width \* 0.08), bottom: Math.round(height \* 0.12),  
        opacity: badgeOp, transform: \`translateY(${badgeY}px)\`,  
        fontFamily: "Inter, sans-serif", fontSize: 120,  
        fontWeight: 900, color: COLORS.accent, opacity: badgeOp \* 0.12,  
        letterSpacing: "-0.04em", lineHeight: 1,  
      }}\>  
        2024  
      \</div\>

      {/\* Slide counter \*/}  
      \<div style={{  
        position: "absolute", bottom: Math.round(height \* 0.06), right: Math.round(width \* 0.08),  
        opacity: badgeOp,  
        fontFamily: "Inter, sans-serif", fontSize: 13, color: COLORS.textMuted,  
        letterSpacing: "0.08em",  
      }}\>  
        01 / 04  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ── SCENE 2: KPI DASHBOARD ───────────────────────────────────────────────────  
const Scene2 \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const headOp \= interpolate(frame, \[0, 25\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const headY \= interpolate(frame, \[0, 25\], \[20, 0\], { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  const cardSize \= Math.max(180, Math.round(width \* 0.19));  
  const valSize \= Math.max(30, Math.round(width \* 0.038));  
  const labelSize \= Math.max(12, Math.round(width \* 0.013));

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg }}\>  
      \<div style={{  
        position: "absolute", right: "-5%", top: "-5%",  
        width: "45%", height: "45%",  
        borderRadius: "50%",  
        background: \`radial-gradient(circle, ${COLORS.accentSoft}33 0%, transparent 70%)\`,  
        filter: "blur(80px)",  
      }} /\>

      {/\* Header \*/}  
      \<div style={{  
        position: "absolute", top: Math.round(height \* 0.09), left: Math.round(width \* 0.08),  
        opacity: headOp, transform: \`translateY(${headY}px)\`,  
      }}\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 300,  
          fontSize: Math.max(11, Math.round(width \* 0.012)),  
          color: COLORS.accent, letterSpacing: "0.18em", textTransform: "uppercase" as const,  
          marginBottom: 10,  
        }}\>Key Performance Indicators\</div\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 700,  
          fontSize: Math.max(28, Math.round(width \* 0.038)),  
          color: COLORS.text, letterSpacing: "-0.015em", lineHeight: 1.1,  
        }}\>FY 2024 Highlights\</div\>  
      \</div\>

      {/\* KPI Cards \*/}  
      \<div style={{  
        position: "absolute",  
        top: "50%", left: "50%",  
        transform: "translate(-50%, \-40%)",  
        display: "flex", gap: Math.round(width \* 0.025), flexWrap: "wrap" as const,  
        justifyContent: "center", width: "85%",  
      }}\>  
        {KPIS.map((kpi, i) \=\> {  
          const delay \= 20 \+ i \* TIMING.STAGGER;  
          const cardSpring \= spring({ frame: frame \- delay, fps, config: { damping: 18, stiffness: 120 } });  
          const cardOp \= interpolate(frame, \[delay, delay \+ 20\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
          const countUp \= interpolate(frame, \[delay, delay \+ 45\], \[0, 1\], {  
            easing: Easing.bezier(0.16, 1, 0.3, 1),  
            extrapolateLeft: "clamp", extrapolateRight: "clamp",  
          });  
          return (  
            \<div key={kpi.label} style={{  
              opacity: cardOp,  
              transform: \`translateY(${interpolate(cardSpring, \[0, 1\], \[30, 0\])}px) scale(${interpolate(cardSpring, \[0, 1\], \[0.92, 1\])})\`,  
              background: COLORS.surface1,  
              border: \`1px solid ${COLORS.border}\`,  
              borderRadius: 20,  
              padding: \`${Math.round(height \* 0.045)}px ${Math.round(width \* 0.03)}px\`,  
              width: cardSize,  
              position: "relative", overflow: "hidden",  
            }}\>  
              {/\* Top accent bar \*/}  
              \<div style={{  
                position: "absolute", top: 0, left: 0, right: 0, height: 3,  
                background: \`linear-gradient(90deg, ${kpi.color}, transparent)\`,  
              }} /\>  
              \<div style={{  
                fontFamily: "Inter, sans-serif", fontWeight: 400,  
                fontSize: labelSize, color: COLORS.textMuted,  
                letterSpacing: "0.06em", textTransform: "uppercase" as const,  
                marginBottom: 16,  
              }}\>{kpi.label}\</div\>  
              \<div style={{  
                fontFamily: "Inter, sans-serif", fontWeight: 800,  
                fontSize: valSize, color: COLORS.text,  
                letterSpacing: "-0.02em", marginBottom: 12,  
              }}\>{kpi.value}\</div\>  
              \<div style={{  
                display: "inline-flex", alignItems: "center", gap: 6,  
                background: \`${kpi.color}20\`, borderRadius: 6,  
                padding: "4px 10px",  
              }}\>  
                \<span style={{  
                  fontFamily: "Inter, sans-serif", fontWeight: 600,  
                  fontSize: Math.max(11, Math.round(width \* 0.012)),  
                  color: kpi.color,  
                }}\>{kpi.delta}\</span\>  
              \</div\>  
            \</div\>  
          );  
        })}  
      \</div\>

      {/\* Slide counter \*/}  
      \<div style={{  
        position: "absolute", bottom: Math.round(height \* 0.06), right: Math.round(width \* 0.08),  
        fontFamily: "Inter, sans-serif", fontSize: 13, color: COLORS.textMuted, letterSpacing: "0.08em",  
      }}\>02 / 04\</div\>  
    \</AbsoluteFill\>  
  );  
};

// ── SCENE 3: BAR CHART ───────────────────────────────────────────────────────  
const Scene3 \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const headOp \= interpolate(frame, \[0, 25\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const headY \= interpolate(frame, \[0, 25\], \[20, 0\], { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  const chartH \= Math.round(height \* 0.42);  
  const barW \= Math.round(width \* 0.09);

  const ySteps \= \[0, 30, 60, 90, 120\];

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg }}\>  
      \<div style={{  
        position: "absolute", left: "-5%", bottom: "-5%",  
        width: "40%", height: "40%",  
        borderRadius: "50%",  
        background: \`radial-gradient(circle, \#0F2A1A 0%, transparent 70%)\`,  
        filter: "blur(80px)",  
      }} /\>

      {/\* Header \*/}  
      \<div style={{  
        position: "absolute", top: Math.round(height \* 0.09), left: Math.round(width \* 0.08),  
        opacity: headOp, transform: \`translateY(${headY}px)\`,  
      }}\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 300,  
          fontSize: Math.max(11, Math.round(width \* 0.012)),  
          color: COLORS.accent2, letterSpacing: "0.18em", textTransform: "uppercase" as const,  
          marginBottom: 10,  
        }}\>Quarterly Revenue\</div\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 700,  
          fontSize: Math.max(28, Math.round(width \* 0.038)),  
          color: COLORS.text, letterSpacing: "-0.015em", lineHeight: 1.1,  
        }}\>Growth Trajectory\</div\>  
      \</div\>

      {/\* Chart container \*/}  
      \<div style={{  
        position: "absolute",  
        bottom: Math.round(height \* 0.14),  
        left: Math.round(width \* 0.1),  
        right: Math.round(width \* 0.08),  
        display: "flex",  
        alignItems: "flex-end",  
        gap: 0,  
      }}\>  
        {/\* Y Axis \*/}  
        \<div style={{  
          display: "flex", flexDirection: "column" as const,  
          justifyContent: "space-between",  
          height: chartH, marginRight: 16, paddingBottom: 2,  
        }}\>  
          {\[...ySteps\].reverse().map((s) \=\> (  
            \<span key={s} style={{  
              fontFamily: "Inter, sans-serif", fontSize: 12,  
              color: COLORS.textMuted, lineHeight: 1,  
            }}\>${s}M\</span\>  
          ))}  
        \</div\>

        {/\* Bars area \*/}  
        \<div style={{  
          flex: 1, display: "flex", alignItems: "flex-end",  
          gap: Math.round(width \* 0.04),  
          height: chartH,  
          borderLeft: \`1px solid ${COLORS.border}\`,  
          borderBottom: \`1px solid ${COLORS.border}\`,  
          paddingLeft: Math.round(width \* 0.03),  
          paddingRight: Math.round(width \* 0.02),  
          position: "relative",  
        }}\>  
          {/\* Grid lines \*/}  
          {ySteps.slice(1).map((s) \=\> (  
            \<div key={s} style={{  
              position: "absolute",  
              bottom: \`${(s / MAX\_VAL) \* 100}%\`,  
              left: 0, right: 0,  
              height: 1,  
              background: COLORS.border,  
              opacity: 0.5,  
            }} /\>  
          ))}

          {BAR\_DATA.map((bar, i) \=\> {  
            const delay \= 20 \+ i \* TIMING.STAGGER;  
            const prog \= spring({ frame: frame \- delay, fps, config: { damping: 14, stiffness: 80 } });  
            const barH \= (bar.value / MAX\_VAL) \* chartH \* prog;  
            const labelOp \= interpolate(frame, \[delay \+ 20, delay \+ 40\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

            return (  
              \<div key={bar.label} style={{ display: "flex", flexDirection: "column" as const, alignItems: "center", flex: 1 }}\>  
                {/\* Value label \*/}  
                \<div style={{  
                  opacity: labelOp,  
                  fontFamily: "Inter, sans-serif", fontWeight: 700,  
                  fontSize: Math.max(13, Math.round(width \* 0.015)),  
                  color: bar.color, marginBottom: 8,  
                }}\>${bar.value}M\</div\>  
                {/\* Bar \*/}  
                \<div style={{  
                  width: barW, height: barH,  
                  background: \`linear-gradient(to top, ${bar.color}CC, ${bar.color})\`,  
                  borderRadius: "6px 6px 0 0",  
                  position: "relative", overflow: "hidden",  
                }}\>  
                  {/\* Shine \*/}  
                  \<div style={{  
                    position: "absolute", top: 0, left: 0, right: 0, height: "30%",  
                    background: "rgba(255,255,255,0.08)",  
                  }} /\>  
                \</div\>  
                {/\* X label \*/}  
                \<div style={{  
                  marginTop: 10,  
                  fontFamily: "Inter, sans-serif", fontWeight: 600,  
                  fontSize: Math.max(13, Math.round(width \* 0.014)),  
                  color: COLORS.textMuted, opacity: labelOp,  
                }}\>{bar.label}\</div\>  
              \</div\>  
            );  
          })}  
        \</div\>  
      \</div\>

      \<div style={{  
        position: "absolute", bottom: Math.round(height \* 0.06), right: Math.round(width \* 0.08),  
        fontFamily: "Inter, sans-serif", fontSize: 13, color: COLORS.textMuted, letterSpacing: "0.08em",  
      }}\>03 / 04\</div\>  
    \</AbsoluteFill\>  
  );  
};

// ── SCENE 4: PIE \+ CLOSING ───────────────────────────────────────────────────  
const Scene4 \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const headOp \= interpolate(frame, \[0, 25\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
  const headY \= interpolate(frame, \[0, 25\], \[20, 0\], { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  const cx \= 150, cy \= 150, r \= 120;  
  const circumference \= 2 \* Math.PI \* r;

  const progress \= interpolate(frame, \[15, 75\], \[0, 1\], {  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });

  let cumulative \= 0;  
  const segments \= PIE\_SEGMENTS.map((seg) \=\> {  
    const segLen \= (seg.pct / 100\) \* circumference;  
    const startAngle \= cumulative;  
    cumulative \+= seg.pct;  
    return { ...seg, segLen, startAngle };  
  });

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg }}\>  
      \<div style={{  
        position: "absolute", right: "-5%", top: "-5%",  
        width: "35%", height: "35%",  
        borderRadius: "50%",  
        background: \`radial-gradient(circle, \#1A0F35 0%, transparent 70%)\`,  
        filter: "blur(80px)",  
      }} /\>

      {/\* Header \*/}  
      \<div style={{  
        position: "absolute", top: Math.round(height \* 0.09), left: Math.round(width \* 0.08),  
        opacity: headOp, transform: \`translateY(${headY}px)\`,  
      }}\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 300,  
          fontSize: Math.max(11, Math.round(width \* 0.012)),  
          color: COLORS.accent4, letterSpacing: "0.18em", textTransform: "uppercase" as const,  
          marginBottom: 10,  
        }}\>Market Distribution\</div\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 700,  
          fontSize: Math.max(28, Math.round(width \* 0.038)),  
          color: COLORS.text, letterSpacing: "-0.015em", lineHeight: 1.1,  
        }}\>Revenue by Region\</div\>  
      \</div\>

      {/\* Pie \+ Legend \*/}  
      \<div style={{  
        position: "absolute",  
        top: "50%", left: "50%",  
        transform: "translate(-50%, \-38%)",  
        display: "flex", alignItems: "center",  
        gap: Math.round(width \* 0.06),  
      }}\>  
        {/\* SVG Pie \*/}  
        \<svg width={300} height={300} viewBox="0 0 300 300"\>  
          {segments.map((seg, i) \=\> {  
            const segProgress \= Math.min(1, Math.max(0, progress \* PIE\_SEGMENTS.length \- i));  
            const drawnLen \= seg.segLen \* segProgress;  
            const rotationDeg \= (seg.startAngle / 100\) \* 360 \- 90;  
            return (  
              \<circle  
                key={seg.label}  
                r={r}  
                cx={cx}  
                cy={cy}  
                fill="none"  
                stroke={seg.color}  
                strokeWidth={44}  
                strokeDasharray={\`${drawnLen} ${circumference}\`}  
                strokeDashoffset={0}  
                transform={\`rotate(${rotationDeg} ${cx} ${cy})\`}  
                style={{ transition: "none" }}  
              /\>  
            );  
          })}  
          {/\* Center circle \*/}  
          \<circle cx={cx} cy={cy} r={70} fill={COLORS.surface1} /\>  
          \<text x={cx} y={cy \- 6} textAnchor="middle" fill={COLORS.text}  
            style={{ fontFamily: "Inter, sans-serif", fontSize: 22, fontWeight: 800 }}\>  
            100%  
          \</text\>  
          \<text x={cx} y={cy \+ 18} textAnchor="middle" fill={COLORS.textMuted}  
            style={{ fontFamily: "Inter, sans-serif", fontSize: 11 }}\>  
            Global  
          \</text\>  
        \</svg\>

        {/\* Legend \*/}  
        \<div style={{ display: "flex", flexDirection: "column" as const, gap: 20 }}\>  
          {PIE\_SEGMENTS.map((seg, i) \=\> {  
            const delay \= 20 \+ i \* TIMING.STAGGER \* 1.5;  
            const legOp \= interpolate(frame, \[delay, delay \+ 20\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
            const legX \= interpolate(frame, \[delay, delay \+ 25\], \[20, 0\], { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateLeft: "clamp", extrapolateRight: "clamp" });  
            return (  
              \<div key={seg.label} style={{  
                display: "flex", alignItems: "center", gap: 14,  
                opacity: legOp, transform: \`translateX(${legX}px)\`,  
              }}\>  
                \<div style={{  
                  width: 14, height: 14, borderRadius: 3,  
                  background: seg.color, flexShrink: 0,  
                }} /\>  
                \<div\>  
                  \<div style={{  
                    fontFamily: "Inter, sans-serif", fontWeight: 600,  
                    fontSize: Math.max(14, Math.round(width \* 0.016)),  
                    color: COLORS.text, marginBottom: 2,  
                  }}\>{seg.label}\</div\>  
                  \<div style={{  
                    fontFamily: "Inter, sans-serif", fontWeight: 400,  
                    fontSize: Math.max(12, Math.round(width \* 0.013)),  
                    color: COLORS.textMuted,  
                  }}\>{seg.pct}% share\</div\>  
                \</div\>  
              \</div\>  
            );  
          })}  
        \</div\>  
      \</div\>

      {/\* CTA bottom \*/}  
      \<div style={{  
        position: "absolute", bottom: Math.round(height \* 0.1), left: Math.round(width \* 0.08),  
        opacity: interpolate(frame, \[70, 90\], \[0, 1\], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),  
        transform: \`translateY(${interpolate(frame, \[70, 90\], \[15, 0\], { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateLeft: "clamp", extrapolateRight: "clamp" })}px)\`,  
        display: "flex", alignItems: "center", gap: 20,  
      }}\>  
        \<div style={{  
          padding: \`${Math.round(height \* 0.016)}px ${Math.round(width \* 0.025)}px\`,  
          background: COLORS.accent,  
          borderRadius: 10,  
          fontFamily: "Inter, sans-serif", fontWeight: 700,  
          fontSize: Math.max(13, Math.round(width \* 0.014)),  
          color: "\#fff", letterSpacing: "0.01em",  
        }}\>Download Full Report\</div\>  
        \<div style={{  
          fontFamily: "Inter, sans-serif", fontWeight: 400,  
          fontSize: Math.max(12, Math.round(width \* 0.013)),  
          color: COLORS.textMuted,  
        }}\>Fiscal Year 2024 · Apex Corporation\</div\>  
      \</div\>

      \<div style={{  
        position: "absolute", bottom: Math.round(height \* 0.06), right: Math.round(width \* 0.08),  
        fontFamily: "Inter, sans-serif", fontSize: 13, color: COLORS.textMuted, letterSpacing: "0.08em",  
      }}\>04 / 04\</div\>  
    \</AbsoluteFill\>  
  );  
};

// ── MAIN COMPOSITION ─────────────────────────────────────────────────────────  
export const CorporatePresentation \= () \=\> {  
  /\*  
   \* Corporate presentation animation with 4 slides:  
   \* Title, KPI Dashboard, Bar Chart, and Pie Chart with regional breakdown.  
   \* Uses TransitionSeries with fade and slide transitions for a polished executive feel.  
   \*/  
  const { fps } \= useVideoConfig();

  const SCENE\_DUR \= 120;  
  const TRANS\_DUR \= 20;

  return (  
    \<TransitionSeries\>  
      \<TransitionSeries.Sequence durationInFrames={SCENE\_DUR} premountFor={fps}\>  
        \<Scene1 /\>  
      \</TransitionSeries.Sequence\>  
      \<TransitionSeries.Transition  
        presentation={slide({ direction: "from-right" })}  
        timing={linearTiming({ durationInFrames: TRANS\_DUR })}  
      /\>  
      \<TransitionSeries.Sequence durationInFrames={SCENE\_DUR} premountFor={fps}\>  
        \<Scene2 /\>  
      \</TransitionSeries.Sequence\>  
      \<TransitionSeries.Transition  
        presentation={fade()}  
        timing={linearTiming({ durationInFrames: TRANS\_DUR })}  
      /\>  
      \<TransitionSeries.Sequence durationInFrames={SCENE\_DUR} premountFor={fps}\>  
        \<Scene3 /\>  
      \</TransitionSeries.Sequence\>  
      \<TransitionSeries.Transition  
        presentation={slide({ direction: "from-right" })}  
        timing={linearTiming({ durationInFrames: TRANS\_DUR })}  
      /\>  
      \<TransitionSeries.Sequence durationInFrames={SCENE\_DUR} premountFor={fps}\>  
        \<Scene4 /\>  
      \</TransitionSeries.Sequence\>  
    \</TransitionSeries\>  
  );  
};

prompt:

Crie uma visualização 3D de um átomo com elétrons orbitando o núcleo.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import \* as THREE from "three";

/\*  
 \* 3D Atom Visualization with orbiting electrons around a glowing nucleus.  
 \* Three electron orbits at different angles create a realistic atomic model.  
 \* Smooth frame-driven animations ensure perfect Remotion export compatibility.  
 \*/

const NucleusCore \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleSpring \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });  
  const pulse \= 1 \+ Math.sin(frame \* 0.08) \* 0.04;  
  const scale \= scaleSpring \* pulse;

  return (  
    \<group\>  
      {/\* Core sphere \*/}  
      \<mesh scale={\[scale, scale, scale\]}\>  
        \<sphereGeometry args={\[0.55, 64, 64\]} /\>  
        \<meshStandardMaterial  
          color="\#FF6B35"  
          emissive="\#FF4500"  
          emissiveIntensity={0.8}  
          roughness={0.2}  
          metalness={0.3}  
        /\>  
      \</mesh\>  
      {/\* Inner glow layer \*/}  
      \<mesh scale={\[scale \* 1.25, scale \* 1.25, scale \* 1.25\]}\>  
        \<sphereGeometry args={\[0.55, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color="\#FF8C42"  
          emissive="\#FF6000"  
          emissiveIntensity={0.4}  
          transparent  
          opacity={0.3}  
          roughness={1}  
          metalness={0}  
        /\>  
      \</mesh\>  
      {/\* Outer glow aura \*/}  
      \<mesh scale={\[scale \* 1.7, scale \* 1.7, scale \* 1.7\]}\>  
        \<sphereGeometry args={\[0.55, 16, 16\]} /\>  
        \<meshStandardMaterial  
          color="\#FF4500"  
          emissive="\#FF2000"  
          emissiveIntensity={0.2}  
          transparent  
          opacity={0.12}  
          roughness={1}  
          metalness={0}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const OrbitRing \= ({  
  rotX,  
  rotY,  
  rotZ,  
}: {  
  rotX: number;  
  rotY: number;  
  rotZ: number;  
}) \=\> {  
  const points: THREE.Vector3\[\] \= \[\];  
  const segments \= 128;  
  for (let i \= 0; i \<= segments; i++) {  
    const angle \= (i / segments) \* Math.PI \* 2;  
    points.push(new THREE.Vector3(Math.cos(angle) \* 2.2, Math.sin(angle) \* 2.2, 0));  
  }  
  const geometry \= new THREE.BufferGeometry().setFromPoints(points);

  return (  
    \<group rotation={\[rotX, rotY, rotZ\]}\>  
      \<line geometry={geometry}\>  
        \<lineBasicMaterial color="\#4A9EFF" transparent opacity={0.25} /\>  
      \</line\>  
    \</group\>  
  );  
};

const Electron \= ({  
  frame,  
  fps,  
  orbitSpeed,  
  orbitOffset,  
  rotX,  
  rotY,  
  rotZ,  
  color,  
  glowColor,  
}: {  
  frame: number;  
  fps: number;  
  orbitSpeed: number;  
  orbitOffset: number;  
  rotX: number;  
  rotY: number;  
  rotZ: number;  
  color: string;  
  glowColor: string;  
}) \=\> {  
  const scaleSpring \= spring({  
    frame,  
    fps,  
    config: { damping: 12, stiffness: 60 },  
    delay: orbitOffset \* 4,  
  });

  const angle \= frame \* orbitSpeed \+ orbitOffset;  
  const x \= Math.cos(angle) \* 2.2;  
  const y \= Math.sin(angle) \* 2.2;

  // Transform position through orbit rotation  
  const cosX \= Math.cos(rotX);  
  const sinX \= Math.sin(rotX);  
  const cosY \= Math.cos(rotY);  
  const sinY \= Math.sin(rotY);  
  const cosZ \= Math.cos(rotZ);  
  const sinZ \= Math.sin(rotZ);

  // Rotate around X  
  const y1 \= y \* cosX;  
  const z1 \= y \* sinX;  
  // Rotate around Y  
  const x2 \= x \* cosY \+ z1 \* sinY;  
  const z2 \= \-x \* sinY \+ z1 \* cosY;  
  // Rotate around Z  
  const x3 \= x2 \* cosZ \- y1 \* sinZ;  
  const y3 \= x2 \* sinZ \+ y1 \* cosZ;

  const s \= scaleSpring;

  return (  
    \<group position={\[x3, y3, z2\]}\>  
      {/\* Electron core \*/}  
      \<mesh scale={\[s, s, s\]}\>  
        \<sphereGeometry args={\[0.18, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color={color}  
          emissive={glowColor}  
          emissiveIntensity={1.2}  
          roughness={0.1}  
          metalness={0.5}  
        /\>  
      \</mesh\>  
      {/\* Electron glow \*/}  
      \<mesh scale={\[s \* 1.8, s \* 1.8, s \* 1.8\]}\>  
        \<sphereGeometry args={\[0.18, 16, 16\]} /\>  
        \<meshStandardMaterial  
          color={glowColor}  
          emissive={glowColor}  
          emissiveIntensity={0.5}  
          transparent  
          opacity={0.25}  
          roughness={1}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const AtomScene \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  // Slow scene rotation  
  const globalRotY \= frame \* 0.008;  
  const globalRotX \= Math.sin(frame \* 0.005) \* 0.2;

  return (  
    \<group rotation={\[globalRotX, globalRotY, 0\]}\>  
      {/\* Lighting \*/}  
      \<ambientLight intensity={0.3} /\>  
      \<pointLight position={\[8, 8, 8\]} intensity={1.5} color="\#ffffff" /\>  
      \<pointLight position={\[-6, \-6, 6\]} intensity={0.8} color="\#4A9EFF" /\>  
      \<pointLight position={\[0, 0, 0\]} intensity={2} color="\#FF6B35" distance={4} /\>

      {/\* Nucleus \*/}  
      \<NucleusCore frame={frame} fps={fps} /\>

      {/\* Orbit rings \*/}  
      \<OrbitRing rotX={0} rotY={0} rotZ={0} /\>  
      \<OrbitRing rotX={Math.PI / 3} rotY={Math.PI / 6} rotZ={0} /\>  
      \<OrbitRing rotX={Math.PI / 2} rotY={Math.PI / 4} rotZ={Math.PI / 6} /\>

      {/\* Orbit 1 — Equatorial \*/}  
      \<Electron  
        frame={frame}  
        fps={fps}  
        orbitSpeed={0.04}  
        orbitOffset={0}  
        rotX={0}  
        rotY={0}  
        rotZ={0}  
        color="\#60A5FA"  
        glowColor="\#3B82F6"  
      /\>

      {/\* Orbit 2 — Tilted 60° \*/}  
      \<Electron  
        frame={frame}  
        fps={fps}  
        orbitSpeed={0.032}  
        orbitOffset={Math.PI \* 0.66}  
        rotX={Math.PI / 3}  
        rotY={Math.PI / 6}  
        rotZ={0}  
        color="\#34D399"  
        glowColor="\#10B981"  
      /\>

      {/\* Orbit 3 — Polar \*/}  
      \<Electron  
        frame={frame}  
        fps={fps}  
        orbitSpeed={0.045}  
        orbitOffset={Math.PI \* 1.33}  
        rotX={Math.PI / 2}  
        rotY={Math.PI / 4}  
        rotZ={Math.PI / 6}  
        color="\#F472B6"  
        glowColor="\#EC4899"  
      /\>  
    \</group\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* A stunning 3D atom visualization featuring a glowing orange nucleus  
   \* and three electrons orbiting along tilted paths in different colors.  
   \* The entire scene gently rotates for a cinematic spatial feel.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // ── THEME TOKENS ──────────────────────────────────────────────  
  const THEME \= { archetype: "neon\_glow", pacing: "slow" };  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0C0",  
    accent: "\#60A5FA",  
    accentGreen: "\#34D399",  
    accentPink: "\#F472B6",  
    nucleus: "\#FF6B35",  
  };  
  const TIMING \= { FADE\_IN: 20, TITLE\_DELAY: 10, LABEL\_DELAY: 25 };

  // ── DERIVED VALUES ─────────────────────────────────────────────  
  const titleFontSize \= Math.max(28, Math.round(width \* 0.045));  
  const subtitleFontSize \= Math.max(14, Math.round(width \* 0.018));  
  const labelFontSize \= Math.max(12, Math.round(width \* 0.014));

  const titleOpacity \= interpolate(frame, \[TIMING.TITLE\_DELAY, TIMING.TITLE\_DELAY \+ TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const subtitleOpacity \= interpolate(frame, \[TIMING.LABEL\_DELAY, TIMING.LABEL\_DELAY \+ TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleY \= interpolate(frame, \[TIMING.TITLE\_DELAY, TIMING.TITLE\_DELAY \+ TIMING.FADE\_IN\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const legendOpacity \= interpolate(frame, \[TIMING.LABEL\_DELAY \+ 15, TIMING.LABEL\_DELAY \+ 35\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, \#0D0D25 0%, \#050510 70%)\`,  
        fontFamily: "Inter, sans-serif",  
        overflow: "hidden",  
      }}  
    \>  
      {/\* Subtle star field \*/}  
      {\[...Array(30)\].map((\_, i) \=\> {  
        const seed \= (i \* 137.508) % 1;  
        const sx \= ((i \* 73\) % 100);  
        const sy \= ((i \* 47 \+ 13\) % 100);  
        const starOpacity \= 0.2 \+ (i % 5\) \* 0.08;  
        const twinkle \= 0.5 \+ Math.sin(frame \* 0.05 \+ i) \* 0.3;  
        return (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              left: \`${sx}%\`,  
              top: \`${sy}%\`,  
              width: i % 7 \=== 0 ? 3 : 2,  
              height: i % 7 \=== 0 ? 3 : 2,  
              borderRadius: "50%",  
              background: "\#FFFFFF",  
              opacity: starOpacity \* twinkle,  
            }}  
          /\>  
        );  
      })}

      {/\* 3D Canvas \*/}  
      \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 0, 6.5\], fov: 60 }}\>  
        \<AtomScene frame={frame} fps={fps} /\>  
      \</ThreeCanvas\>

      {/\* Title overlay \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: Math.round(height \* 0.06),  
          left: 0,  
          right: 0,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          gap: 8,  
          opacity: titleOpacity,  
          transform: \`translateY(${titleY}px)\`,  
        }}  
      \>  
        \<div  
          style={{  
            fontSize: titleFontSize,  
            fontWeight: 700,  
            letterSpacing: "-0.01em",  
            color: COLORS.text,  
            textAlign: "center",  
            background: \`linear-gradient(135deg, ${COLORS.text} 0%, ${COLORS.accent} 100%)\`,  
            WebkitBackgroundClip: "text",  
            WebkitTextFillColor: "transparent",  
          }}  
        \>  
          Atomic Structure  
        \</div\>  
        \<div  
          style={{  
            fontSize: subtitleFontSize,  
            fontWeight: 400,  
            letterSpacing: "0.06em",  
            color: COLORS.textMuted,  
            textTransform: "uppercase",  
            opacity: subtitleOpacity,  
          }}  
        \>  
          Bohr Model — 3 Electron Orbits  
        \</div\>  
      \</div\>

      {/\* Legend \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: Math.round(height \* 0.07),  
          left: 0,  
          right: 0,  
          display: "flex",  
          justifyContent: "center",  
          gap: Math.round(width \* 0.04),  
          opacity: legendOpacity,  
        }}  
      \>  
        {\[  
          { color: COLORS.nucleus, label: "Nucleus" },  
          { color: COLORS.accent, label: "e⁻ Orbit 1" },  
          { color: COLORS.accentGreen, label: "e⁻ Orbit 2" },  
          { color: COLORS.accentPink, label: "e⁻ Orbit 3" },  
        \].map(({ color, label }) \=\> (  
          \<div  
            key={label}  
            style={{  
              display: "flex",  
              alignItems: "center",  
              gap: 8,  
            }}  
          \>  
            \<div  
              style={{  
                width: 10,  
                height: 10,  
                borderRadius: "50%",  
                background: color,  
                boxShadow: \`0 0 8px ${color}\`,  
              }}  
            /\>  
            \<span  
              style={{  
                fontSize: labelFontSize,  
                color: COLORS.textMuted,  
                fontWeight: 500,  
                letterSpacing: "0.02em",  
              }}  
            \>  
              {label}  
            \</span\>  
          \</div\>  
        ))}  
      \</div\>

      {/\* Vignette overlay \*/}  
      \<div  
        style={{  
          position: "absolute",  
          inset: 0,  
          background:  
            "radial-gradient(ellipse at center, transparent 55%, rgba(5,5,16,0.7) 100%)",  
          pointerEvents: "none",  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação de 100 partículas 3D espalhadas pelo espaço, cada uma com movimento independente.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef, useMemo } from "react";

/\*  
  100 independent 3D particles scattered through space.  
  Each particle has a unique position, speed, rotation axis, and color.  
  The camera slowly orbits around the particle field for a cinematic effect.  
\*/

const COLORS \= {  
  bg: "\#050510",  
  surface1: "\#0B0B1A",  
  accent: "\#00FF88",  
  glow: "\#00AAFF",  
  secondary: "\#FF6B6B",  
  tertiary: "\#FFD93D",  
};

// Seeded pseudo-random number generator for deterministic values  
function seededRandom(seed: number) {  
  let s \= seed;  
  return () \=\> {  
    s \= (s \* 1664525 \+ 1013904223\) & 0xffffffff;  
    return (s \>\>\> 0\) / 0xffffffff;  
  };  
}

const PARTICLE\_COUNT \= 100;

// Generate particle data once — deterministic, no inline trig loops per frame  
const rng \= seededRandom(42);  
const particleData \= Array.from({ length: PARTICLE\_COUNT }, (\_, i) \=\> {  
  const r \= rng();  
  const theta \= rng() \* Math.PI \* 2;  
  const phi \= rng() \* Math.PI;  
  const radius \= 3 \+ rng() \* 7;

  const colorOptions \= \[COLORS.accent, COLORS.glow, COLORS.secondary, COLORS.tertiary, "\#FFFFFF"\];  
  const color \= colorOptions\[Math.floor(rng() \* colorOptions.length)\];

  return {  
    id: i,  
    // Spherical shell distribution  
    baseX: radius \* Math.sin(phi) \* Math.cos(theta),  
    baseY: radius \* Math.sin(phi) \* Math.sin(theta),  
    baseZ: radius \* Math.cos(phi),  
    // Individual motion parameters  
    speedX: (rng() \- 0.5) \* 0.04,  
    speedY: (rng() \- 0.5) \* 0.04,  
    speedZ: (rng() \- 0.5) \* 0.04,  
    phaseX: rng() \* Math.PI \* 2,  
    phaseY: rng() \* Math.PI \* 2,  
    phaseZ: rng() \* Math.PI \* 2,  
    amplitudeX: 0.3 \+ rng() \* 0.8,  
    amplitudeY: 0.3 \+ rng() \* 0.8,  
    amplitudeZ: 0.3 \+ rng() \* 0.8,  
    // Rotation  
    rotSpeedX: (rng() \- 0.5) \* 0.1,  
    rotSpeedY: (rng() \- 0.5) \* 0.1,  
    rotSpeedZ: (rng() \- 0.5) \* 0.1,  
    // Visual  
    scale: 0.04 \+ rng() \* 0.12,  
    color,  
    shape: r \< 0.5 ? "box" : "sphere",  
    opacity: 0.5 \+ rng() \* 0.5,  
  };  
});

// Individual particle mesh component  
const Particle \= ({  
  data,  
  frame,  
}: {  
  data: (typeof particleData)\[0\];  
  frame: number;  
}) \=\> {  
  const t \= frame \* 0.02;

  const x \= data.baseX \+ Math.sin(t \* data.speedX \* 50 \+ data.phaseX) \* data.amplitudeX;  
  const y \= data.baseY \+ Math.sin(t \* data.speedY \* 50 \+ data.phaseY) \* data.amplitudeY;  
  const z \= data.baseZ \+ Math.sin(t \* data.speedZ \* 50 \+ data.phaseZ) \* data.amplitudeZ;

  const rotX \= frame \* data.rotSpeedX;  
  const rotY \= frame \* data.rotSpeedY;  
  const rotZ \= frame \* data.rotSpeedZ;

  const s \= data.scale;

  return (  
    \<mesh  
      position={\[x, y, z\]}  
      rotation={\[rotX, rotY, rotZ\]}  
      scale={\[s, s, s\]}  
    \>  
      {data.shape \=== "box" ? (  
        \<boxGeometry args={\[1, 1, 1\]} /\>  
      ) : (  
        \<sphereGeometry args={\[0.5, 8, 8\]} /\>  
      )}  
      \<meshStandardMaterial  
        color={data.color}  
        transparent  
        opacity={data.opacity}  
        roughness={0.3}  
        metalness={0.7}  
      /\>  
    \</mesh\>  
  );  
};

// Scene graph — camera orbit \+ all particles  
const ParticleScene \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const orbitAngle \= frame \* 0.008;  
  const camX \= Math.sin(orbitAngle) \* 14;  
  const camZ \= Math.cos(orbitAngle) \* 14;  
  const camY \= Math.sin(frame \* 0.003) \* 3;

  return (  
    \<\>  
      \<ambientLight intensity={0.4} /\>  
      \<pointLight position={\[5, 5, 5\]} intensity={1.2} color="\#00AAFF" /\>  
      \<pointLight position={\[-5, \-5, \-5\]} intensity={0.8} color="\#00FF88" /\>  
      \<pointLight position={\[0, 8, 0\]} intensity={0.6} color="\#FF6B6B" /\>  
      {particleData.map((p) \=\> (  
        \<Particle key={p.id} data={p} frame={frame} /\>  
      ))}  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
    Main composition: premium dark NEON/GLOW archetype.  
    100 independent particles with unique orbits, rotations, and colors.  
    A slow camera orbit gives cinematic depth to the particle field.  
  \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  const TIMING \= { FADE\_IN: 20, FADE\_OUT: 15 };

  const globalOpacity \= interpolate(  
    frame,  
    \[0, TIMING.FADE\_IN, durationInFrames \- TIMING.FADE\_OUT, durationInFrames\],  
    \[0, 1, 1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const titleOpacity \= interpolate(frame, \[0, 30, 90, 110\], \[0, 1, 1, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleY \= interpolate(frame, \[0, 30\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const subtitleOpacity \= interpolate(frame, \[20, 50, 90, 110\], \[0, 1, 1, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const counterOpacity \= interpolate(  
    frame,  
    \[60, 80, durationInFrames \- 30, durationInFrames \- 15\],  
    \[0, 1, 1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const fontSize \= Math.max(28, Math.round(width \* 0.045));  
  const subFontSize \= Math.max(14, Math.round(width \* 0.018));  
  const counterFontSize \= Math.max(12, Math.round(width \* 0.014));

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at center, ${COLORS.surface1} 0%, ${COLORS.bg} 70%)\`,  
        opacity: globalOpacity,  
      }}  
    \>  
      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 0 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 14\], fov: 60 }}  
        \>  
          \<ParticleScene frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 1,  
          background:  
            "radial-gradient(ellipse at center, transparent 30%, rgba(5,5,16,0.7) 100%)",  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Title \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-start",  
          paddingTop: Math.round(height \* 0.08),  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: fontSize,  
              fontWeight: 800,  
              letterSpacing: "-0.02em",  
              lineHeight: 1.1,  
              background: \`linear-gradient(135deg, ${COLORS.accent} 0%, ${COLORS.glow} 100%)\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            100 PARTICLE FIELD  
          \</div\>  
        \</div\>

        \<div  
          style={{  
            opacity: subtitleOpacity,  
            marginTop: Math.round(height \* 0.015),  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: subFontSize,  
              fontWeight: 400,  
              letterSpacing: "0.12em",  
              color: "rgba(255,255,255,0.5)",  
              textTransform: "uppercase",  
            }}  
          \>  
            Independent 3D Motion · Dynamic Colors · Orbital Camera  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Stats badge \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "flex-end",  
          padding: Math.round(height \* 0.04),  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            opacity: counterOpacity,  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "flex-end",  
            gap: 6,  
          }}  
        \>  
          {\[  
            { label: "PARTICLES", value: "100" },  
            { label: "SHAPES", value: "CUBE \+ SPHERE" },  
            { label: "COLORS", value: "5 VARIANTS" },  
          \].map((stat, i) \=\> (  
            \<div  
              key={i}  
              style={{  
                display: "flex",  
                alignItems: "center",  
                gap: 10,  
                background: "rgba(11,11,26,0.7)",  
                borderLeft: \`2px solid ${COLORS.accent}\`,  
                padding: "6px 12px",  
                backdropFilter: "blur(8px)",  
              }}  
            \>  
              \<span  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: counterFontSize,  
                  fontWeight: 700,  
                  letterSpacing: "0.06em",  
                  color: COLORS.accent,  
                }}  
              \>  
                {stat.value}  
              \</span\>  
              \<span  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: counterFontSize,  
                  fontWeight: 400,  
                  letterSpacing: "0.08em",  
                  color: "rgba(255,255,255,0.4)",  
                }}  
              \>  
                {stat.label}  
              \</span\>  
            \</div\>  
          ))}  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Bottom orbit indicator \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.04),  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            opacity: counterOpacity \* 0.6,  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(10, Math.round(width \* 0.011)),  
            fontWeight: 400,  
            letterSpacing: "0.15em",  
            color: "rgba(255,255,255,0.3)",  
            textTransform: "uppercase",  
          }}  
        \>  
          ◉ Orbital Camera Active  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma esfera 3D com resolução extremamente alta para uma textura suave perfeita.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
 \* A stunning 3D sphere with ultra-high resolution geometry and smooth material rendering.  
 \* Features a slow elegant rotation, dynamic lighting, and a premium dark background.  
 \* Designed for a cinematic, premium aesthetic with perfect surface smoothness.  
 \*/

const SphereScene \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 80 },  
  });

  const rotationY \= frame \* 0.008;  
  const rotationX \= frame \* 0.003;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.12;

  return (  
    \<\>  
      {/\* Ambient fill light \*/}  
      \<ambientLight intensity={0.15} /\>

      {/\* Primary key light \- warm top \*/}  
      \<directionalLight  
        position={\[3, 5, 4\]}  
        intensity={1.6}  
        color="\#FFFFFF"  
      /\>

      {/\* Rim light \- cool blue \*/}  
      \<pointLight  
        position={\[-5, 2, \-3\]}  
        intensity={1.2}  
        color="\#60A5FA"  
      /\>

      {/\* Bottom fill \- soft warm \*/}  
      \<pointLight  
        position={\[2, \-4, 2\]}  
        intensity={0.5}  
        color="\#34D399"  
      /\>

      {/\* Back accent \*/}  
      \<pointLight  
        position={\[0, 0, \-6\]}  
        intensity={0.4}  
        color="\#A78BFA"  
      /\>

      {/\* Ultra-high resolution sphere \*/}  
      \<mesh  
        rotation={\[rotationX, rotationY, 0\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        {/\* 512x512 segments for ultra-smooth surface \*/}  
        \<sphereGeometry args={\[2.2, 512, 512\]} /\>  
        \<meshStandardMaterial  
          color="\#1A1A2E"  
          metalness={0.92}  
          roughness={0.08}  
          envMapIntensity={1.5}  
        /\>  
      \</mesh\>

      {/\* Subtle inner glow sphere \*/}  
      \<mesh  
        rotation={\[rotationX \* 0.5, rotationY \* 0.5, 0\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleProgress \* 0.98, scaleProgress \* 0.98, scaleProgress \* 0.98\]}  
      \>  
        \<sphereGeometry args={\[2.18, 256, 256\]} /\>  
        \<meshStandardMaterial  
          color="\#60A5FA"  
          metalness={0.3}  
          roughness={0.95}  
          transparent  
          opacity={0.04}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Ultra-high resolution 3D sphere animation using ThreeCanvas.  
   \* Premium dark cinematic aesthetic with multi-point studio lighting.  
   \* Smooth entrance via spring animation and elegant floating motion.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: '\#000000',  
    surface1: '\#0A0A14',  
    surface2: '\#111122',  
    text: '\#FFFFFF',  
    textMuted: '\#A0A0A8',  
    accent: '\#60A5FA',  
    accentGreen: '\#34D399',  
    accentPurple: '\#A78BFA',  
  };

  const TIMING \= { FADE\_IN: 20, FADE\_OUT: 40 };

  // Fade in  
  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Text fade in  
  const textOpacity \= interpolate(frame, \[30, 60\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const textY \= interpolate(frame, \[30, 60\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const baseFontSize \= Math.max(12, Math.round(width \* 0.012));  
  const titleFontSize \= Math.max(24, Math.round(width \* 0.028));

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, \#0D0D24 0%, \#050510 50%, \#000000 100%)\`,  
        opacity: globalOpacity,  
      }}  
    \>  
      {/\* Background glow orb \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, rgba(96, 165, 250, 0.06) 0%, transparent 65%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 6\], fov: 50 }}  
        \>  
          \<SphereScene frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Top label \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          display: 'flex',  
          flexDirection: 'column',  
          alignItems: 'center',  
          justifyContent: 'flex-start',  
          paddingTop: Math.round(height \* 0.06),  
          opacity: textOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: 'Inter, sans-serif',  
            fontSize: baseFontSize,  
            fontWeight: 500,  
            letterSpacing: '0.25em',  
            color: COLORS.accentGreen,  
            textTransform: 'uppercase',  
            marginBottom: 12,  
          }}  
        \>  
          Ultra High Resolution  
        \</div\>  
        \<div  
          style={{  
            fontFamily: 'Inter, sans-serif',  
            fontSize: titleFontSize,  
            fontWeight: 300,  
            letterSpacing: '0.06em',  
            color: COLORS.text,  
            textTransform: 'uppercase',  
          }}  
        \>  
          Perfect Surface  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Bottom label \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          display: 'flex',  
          flexDirection: 'column',  
          alignItems: 'center',  
          justifyContent: 'flex-end',  
          paddingBottom: Math.round(height \* 0.06),  
          opacity: textOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            display: 'flex',  
            gap: 32,  
            alignItems: 'center',  
          }}  
        \>  
          {\[  
            { label: 'Segments', value: '512×512' },  
            { label: 'Metalness', value: '92%' },  
            { label: 'Smoothness', value: '100%' },  
          \].map((item, i) \=\> (  
            \<div  
              key={i}  
              style={{  
                display: 'flex',  
                flexDirection: 'column',  
                alignItems: 'center',  
                gap: 4,  
              }}  
            \>  
              \<div  
                style={{  
                  fontFamily: 'Inter, sans-serif',  
                  fontSize: Math.max(18, Math.round(width \* 0.018)),  
                  fontWeight: 700,  
                  color: COLORS.accent,  
                  letterSpacing: '-0.01em',  
                }}  
              \>  
                {item.value}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: 'Inter, sans-serif',  
                  fontSize: Math.max(10, Math.round(width \* 0.009)),  
                  fontWeight: 400,  
                  color: COLORS.textMuted,  
                  letterSpacing: '0.12em',  
                  textTransform: 'uppercase',  
                }}  
              \>  
                {item.label}  
              \</div\>  
            \</div\>  
          ))}  
        \</div\>

        {/\* Divider line \*/}  
        \<div  
          style={{  
            width: Math.round(width \* 0.15),  
            height: 1,  
            background: \`linear-gradient(90deg, transparent, ${COLORS.accent}44, transparent)\`,  
            marginTop: 20,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          background: \`radial-gradient(ellipse at 50% 50%, transparent 45%, rgba(0,0,0,0.55) 100%)\`,  
          pointerEvents: 'none',  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D onde um objeto pulsa em sincronia com uma música.

resultado:

\#\# Error Type  
Runtime ReferenceError

\#\# Error Message  
useWindowedAudioData is not defined

    at Object.react\_stack\_bottom\_frame (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:14826:24)  
    at renderWithHooks (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:4651:24)  
    at updateFunctionComponent (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:6112:21)  
    at beginWork (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:6708:24)  
    at runWithFiberInDEV (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:965:74)  
    at performUnitOfWork (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9562:97)  
    at workLoopSync (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9456:40)  
    at renderRootSync (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9440:13)  
    at performWorkOnRoot (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9105:47)  
    at performSyncWorkOnRoot (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:10238:9)  
    at flushSyncWorkAcrossRoots\_impl (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:10154:316)  
    at flushSpawnedWork (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9914:13)  
    at commitRoot (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9720:432)  
    at commitRootWhenReady (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9194:9)  
    at performWorkOnRoot (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:9166:25)  
    at performWorkOnRootViaSchedulerTask (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_react-dom\_1e674e59.\_.js:10230:9)  
    at MessagePort.performWorkUntilDeadline (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_compiled\_a0e4c7b4.\_.js:2647:64)  
    at useLazyComponent.useMemo6\[lazy\].Wrapper (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_remotion\_dist\_esm\_80ffd44d.\_.js:1178:201)  
    at PlayerUI (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_%40remotion\_player\_dist\_esm\_index\_mjs\_3acbceb2.\_.js:3309:241)  
    at PlayerFn (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_%40remotion\_player\_dist\_esm\_index\_mjs\_3acbceb2.\_.js:3849:225)  
    at renderContent (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/src\_58467ae3.\_.js:1630:233)  
    at AnimationPlayer (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/src\_58467ae3.\_.js:1697:23)  
    at GeneratePageContent (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/src\_58467ae3.\_.js:6473:243)  
    at GeneratePage (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/src\_58467ae3.\_.js:6549:221)  
    at ClientPageRoot (file://C:/Users/pieru/OneDrive/Área de Trabalho/Nova pasta (3)/.next/dev/static/chunks/node\_modules\_next\_dist\_be32b49c.\_.js:2403:50)

Next.js version: 16.1.7 (Turbopack)

prompt:

Crie uma animação 3D com um objeto girando e uma legenda descritiva aparecendo embaixo em tempo real.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

// Rotating 3D object animation with a dynamic caption that types in below.  
// A premium dark aesthetic with a glowing gem-like dodecahedron spinning in 3D space.  
// The caption reveals word-by-word with smooth spring animations.

const RotatingGem \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const rotY \= frame \* 0.03;  
  const rotX \= Math.sin(frame \* 0.015) \* 0.4;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.15;

  const scaleSpring \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 80 },  
    durationInFrames: 45,  
  });

  return (  
    \<\>  
      \<ambientLight intensity={0.3} /\>  
      \<pointLight position={\[4, 4, 6\]} intensity={1.8} color="\#60A5FA" /\>  
      \<pointLight position={\[-4, \-2, 4\]} intensity={1.2} color="\#818CF8" /\>  
      \<pointLight position={\[0, 6, 2\]} intensity={0.8} color="\#ffffff" /\>

      {/\* Main gem \*/}  
      \<mesh  
        rotation={\[rotX, rotY, rotX \* 0.5\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleSpring \* 1.4, scaleSpring \* 1.4, scaleSpring \* 1.4\]}  
      \>  
        \<dodecahedronGeometry args={\[1.2, 0\]} /\>  
        \<meshStandardMaterial  
          color="\#1E3A5F"  
          metalness={0.85}  
          roughness={0.1}  
          emissive="\#0A1A3A"  
          emissiveIntensity={0.4}  
        /\>  
      \</mesh\>

      {/\* Inner glow sphere \*/}  
      \<mesh  
        rotation={\[-rotX \* 0.5, \-rotY \* 0.7, 0\]}  
        position={\[0, floatY, 0\]}  
        scale={\[scaleSpring \* 0.9, scaleSpring \* 0.9, scaleSpring \* 0.9\]}  
      \>  
        \<icosahedronGeometry args={\[0.8, 0\]} /\>  
        \<meshStandardMaterial  
          color="\#3B82F6"  
          metalness={0.6}  
          roughness={0.15}  
          emissive="\#1D4ED8"  
          emissiveIntensity={0.8}  
          transparent  
          opacity={0.55}  
        /\>  
      \</mesh\>

      {/\* Orbit ring \*/}  
      \<mesh  
        rotation={\[1.1, rotY \* 0.4, 0.3\]}  
        position={\[0, floatY \* 0.3, 0\]}  
        scale={\[scaleSpring \* 1.0, scaleSpring \* 1.0, scaleSpring \* 1.0\]}  
      \>  
        \<torusGeometry args={\[1.9, 0.03, 16, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#60A5FA"  
          emissive="\#3B82F6"  
          emissiveIntensity={1.5}  
          metalness={0.9}  
          roughness={0.05}  
        /\>  
      \</mesh\>

      {/\* Second orbit ring \*/}  
      \<mesh  
        rotation={\[-0.6, rotY \* 0.6 \+ 1.0, 0.8\]}  
        position={\[0, floatY \* 0.3, 0\]}  
        scale={\[scaleSpring \* 1.0, scaleSpring \* 1.0, scaleSpring \* 1.0\]}  
      \>  
        \<torusGeometry args={\[2.1, 0.02, 16, 80\]} /\>  
        \<meshStandardMaterial  
          color="\#818CF8"  
          emissive="\#6366F1"  
          emissiveIntensity={1.2}  
          metalness={0.9}  
          roughness={0.05}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* A cinematic 3D animation featuring a rotating crystalline dodecahedron  
   \* with glowing orbit rings, set against a deep space backdrop.  
   \* A typewriter-style caption with animated words reveals the object's name below.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // ─── THEME ────────────────────────────────────────  
  const THEME \= { archetype: "premium\_dark", pacing: "medium" };  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#0A0F1E",  
    surface2: "\#111827",  
    text: "\#FFFFFF",  
    textMuted: "\#94A3B8",  
    accent: "\#60A5FA",  
    accentAlt: "\#818CF8",  
  };  
  const TIMING \= { FADE: 20, STAGGER: 8, CAPTION\_START: 35, BASE: 12 };  
  const LAYOUT \= { PADDING: Math.round(width \* 0.06) };

  // ─── TYPOGRAPHY ───────────────────────────────────  
  const TITLE\_SIZE \= Math.max(32, Math.round(width \* 0.048));  
  const CAPTION\_SIZE \= Math.max(14, Math.round(width \* 0.016));  
  const LABEL\_SIZE \= Math.max(11, Math.round(width \* 0.012));

  // ─── CAPTION WORDS ────────────────────────────────  
  const captionWords \= \["QUANTUM", "CRYSTAL", "LATTICE", "STRUCTURE"\];  
  const subtitleWords \= \[  
    "A",  
    "symmetrical",  
    "dodecahedral",  
    "form",  
    "—",  
    "rotating",  
    "in",  
    "real",  
    "time",  
  \];

  // ─── BACKGROUND OPACITY ───────────────────────────  
  const bgFade \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });

  // ─── TITLE ENTRANCE ───────────────────────────────  
  const titleY \= interpolate(  
    frame,  
    \[0, Math.round(fps \* 0.7)\],  
    \[40, 0\],  
    {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
    }  
  );  
  const titleOpacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // ─── STATS / INFO LABELS ──────────────────────────  
  const statsOpacity \= interpolate(frame, \[40, 70\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // ─── ANIMATED WORD CAPTION ────────────────────────  
  const wordDelay \= TIMING.BASE;

  const getWordOpacity \= (wordIndex: number, startFrame: number) \=\> {  
    const wordStart \= startFrame \+ wordIndex \* wordDelay;  
    return interpolate(frame, \[wordStart, wordStart \+ TIMING.FADE\], \[0, 1\], {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    });  
  };

  const getWordY \= (wordIndex: number, startFrame: number) \=\> {  
    const wordStart \= startFrame \+ wordIndex \* wordDelay;  
    return interpolate(frame, \[wordStart, wordStart \+ TIMING.FADE\], \[16, 0\], {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
      easing: Easing.bezier(0.16, 1, 0.3, 1),  
    });  
  };

  // ─── TITLE CHARS REVEAL ───────────────────────────  
  const titleText \= "CRYSTALLINE OBJECT";  
  const charRevealDuration \= 2;  
  const totalCharFrames \= titleText.length \* charRevealDuration \+ 10;  
  const revealedChars \= Math.floor(  
    interpolate(frame, \[5, 5 \+ totalCharFrames\], \[0, titleText.length\], {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    })  
  );

  // ─── DIVIDER LINE ─────────────────────────────────  
  const lineWidth \= interpolate(frame, \[30, 70\], \[0, 100\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });

  // ─── ROTATION DATA ────────────────────────────────  
  const currentAngle \= Math.round(((frame \* 0.03 \* 180\) / Math.PI) % 360);

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, \#0D1B35 0%, \#050A14 45%, \#000000 100%)\`,  
        opacity: bgFade,  
      }}  
    \>  
      {/\* Subtle grid overlay \*/}  
      \<AbsoluteFill  
        style={{  
          backgroundImage: \`linear-gradient(rgba(96,165,250,0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(96,165,250,0.04) 1px, transparent 1px)\`,  
          backgroundSize: \`${Math.round(width \* 0.07)}px ${Math.round(width \* 0.07)}px\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Canvas — upper portion \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: 0,  
          left: 0,  
          width: "100%",  
          height: "65%",  
          zIndex: 1,  
        }}  
      \>  
        \<ThreeCanvas  
          width={width}  
          height={Math.round(height \* 0.65)}  
          camera={{ position: \[0, 0, 5.5\], fov: 60 }}  
        \>  
          \<RotatingGem frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</div\>

      {/\* TOP label \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: Math.round(height \* 0.038),  
          left: LAYOUT.PADDING,  
          zIndex: 10,  
          opacity: statsOpacity,  
          display: "flex",  
          alignItems: "center",  
          gap: 10,  
        }}  
      \>  
        \<div  
          style={{  
            width: 6,  
            height: 6,  
            borderRadius: "50%",  
            background: COLORS.accent,  
            boxShadow: \`0 0 8px ${COLORS.accent}\`,  
          }}  
        /\>  
        \<span  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: LABEL\_SIZE,  
            fontWeight: 500,  
            letterSpacing: "0.18em",  
            color: COLORS.accent,  
            textTransform: "uppercase",  
          }}  
        \>  
          LIVE RENDER · 3D OBJECT  
        \</span\>  
      \</div\>

      {/\* Top right — angle counter \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: Math.round(height \* 0.035),  
          right: LAYOUT.PADDING,  
          zIndex: 10,  
          opacity: statsOpacity,  
          textAlign: "right",  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: LABEL\_SIZE,  
            fontWeight: 500,  
            letterSpacing: "0.12em",  
            color: COLORS.textMuted,  
            textTransform: "uppercase",  
          }}  
        \>  
          ROTATION  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(18, Math.round(width \* 0.022)),  
            fontWeight: 700,  
            letterSpacing: "-0.01em",  
            color: COLORS.text,  
            lineHeight: 1.1,  
          }}  
        \>  
          {String(currentAngle).padStart(3, "0")}°  
        \</div\>  
      \</div\>

      {/\* Bottom info panel \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: 0,  
          left: 0,  
          width: "100%",  
          height: "38%",  
          zIndex: 5,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "center",  
          padding: \`0 ${LAYOUT.PADDING}px\`,  
          paddingBottom: Math.round(height \* 0.04),  
          boxSizing: "border-box",  
          background:  
            "linear-gradient(to bottom, transparent 0%, rgba(0,0,0,0.6) 30%, rgba(0,0,0,0.85) 100%)",  
        }}  
      \>  
        {/\* Typewriter title \*/}  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: TITLE\_SIZE,  
            fontWeight: 800,  
            letterSpacing: "-0.02em",  
            color: COLORS.text,  
            lineHeight: 1.1,  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            marginBottom: Math.round(height \* 0.018),  
            textAlign: "center",  
          }}  
        \>  
          {titleText.slice(0, revealedChars)}  
          \<span  
            style={{  
              color: COLORS.accent,  
              opacity: revealedChars \< titleText.length ? 1 : 0,  
            }}  
          \>  
            |  
          \</span\>  
        \</div\>

        {/\* Accent divider line \*/}  
        \<div  
          style={{  
            width: \`${lineWidth}%\`,  
            height: 1,  
            background: \`linear-gradient(90deg, transparent, ${COLORS.accent}, ${COLORS.accentAlt}, transparent)\`,  
            marginBottom: Math.round(height \* 0.022),  
            opacity: statsOpacity,  
          }}  
        /\>

        {/\* Main caption — large words \*/}  
        \<div  
          style={{  
            display: "flex",  
            gap: Math.round(width \* 0.022),  
            marginBottom: Math.round(height \* 0.014),  
            overflow: "hidden",  
          }}  
        \>  
          {captionWords.map((word, i) \=\> (  
            \<div  
              key={word}  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: CAPTION\_SIZE \* 1.55,  
                fontWeight: 700,  
                letterSpacing: "0.08em",  
                color: i % 2 \=== 0 ? COLORS.text : COLORS.accent,  
                textTransform: "uppercase",  
                opacity: getWordOpacity(i, TIMING.CAPTION\_START),  
                transform: \`translateY(${getWordY(i, TIMING.CAPTION\_START)}px)\`,  
              }}  
            \>  
              {word}  
            \</div\>  
          ))}  
        \</div\>

        {/\* Subtitle — smaller words streaming in \*/}  
        \<div  
          style={{  
            display: "flex",  
            flexWrap: "wrap",  
            justifyContent: "center",  
            gap: \`0 ${Math.round(width \* 0.006)}px\`,  
            maxWidth: Math.round(width \* 0.7),  
            overflow: "hidden",  
          }}  
        \>  
          {subtitleWords.map((word, i) \=\> (  
            \<span  
              key={\`${word}-${i}\`}  
              style={{  
                fontFamily: "Inter, sans-serif",  
                fontSize: CAPTION\_SIZE,  
                fontWeight: 400,  
                letterSpacing: "0.04em",  
                color: COLORS.textMuted,  
                opacity: getWordOpacity(  
                  i,  
                  TIMING.CAPTION\_START \+ captionWords.length \* wordDelay \+ 10  
                ),  
                transform: \`translateY(${getWordY(  
                  i,  
                  TIMING.CAPTION\_START \+ captionWords.length \* wordDelay \+ 10  
                )}px)\`,  
                display: "inline-block",  
              }}  
            \>  
              {word}\&nbsp;  
            \</span\>  
          ))}  
        \</div\>

        {/\* Bottom stat row \*/}  
        \<div  
          style={{  
            display: "flex",  
            gap: Math.round(width \* 0.04),  
            marginTop: Math.round(height \* 0.025),  
            opacity: interpolate(frame, \[90, 120\], \[0, 1\], {  
              extrapolateLeft: "clamp",  
              extrapolateRight: "clamp",  
            }),  
          }}  
        \>  
          {\[  
            { label: "FACES", value: "12" },  
            { label: "VERTICES", value: "20" },  
            { label: "EDGES", value: "30" },  
          \].map((stat) \=\> (  
            \<div  
              key={stat.label}  
              style={{  
                textAlign: "center",  
                padding: \`${Math.round(height \* 0.008)}px ${Math.round(width \* 0.016)}px\`,  
                border: \`1px solid rgba(96,165,250,0.2)\`,  
                borderRadius: 6,  
                background: "rgba(96,165,250,0.05)",  
              }}  
            \>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: Math.max(18, Math.round(width \* 0.02)),  
                  fontWeight: 700,  
                  color: COLORS.accent,  
                  letterSpacing: "0.04em",  
                }}  
              \>  
                {stat.value}  
              \</div\>  
              \<div  
                style={{  
                  fontFamily: "Inter, sans-serif",  
                  fontSize: Math.max(9, Math.round(width \* 0.01)),  
                  fontWeight: 500,  
                  color: COLORS.textMuted,  
                  letterSpacing: "0.12em",  
                  textTransform: "uppercase",  
                }}  
              \>  
                {stat.label}  
              \</div\>  
            \</div\>  
          ))}  
        \</div\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação de 2 cenas: a primeira com um cubo 3D girando (5 segundos), a segunda com um texto animado simples (5 segundos).

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Sequence,  
} from "remotion";  
import { TransitionSeries, linearTiming } from "@remotion/transitions";  
import { fade } from "@remotion/transitions/fade";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* Two-scene animation: Scene 1 features a 3D rotating cube with dynamic lighting,  
 \* Scene 2 reveals bold animated text with staggered word entrances.  
 \* A smooth fade transition connects the two scenes seamlessly.  
 \*/

// ─── Sub-components ───────────────────────────────────────────────────────────

const RotatingCube: React.FC\<{ frame: number; fps: number }\> \= ({ frame, fps }) \=\> {  
  const scaleProgress \= spring({ frame, fps, config: { damping: 14, stiffness: 90 } });  
  const rotX \= frame \* 0.018;  
  const rotY \= frame \* 0.028;  
  const rotZ \= frame \* 0.010;

  return (  
    \<mesh  
      rotation={\[rotX, rotY, rotZ\]}  
      scale={\[scaleProgress \* 1.6, scaleProgress \* 1.6, scaleProgress \* 1.6\]}  
    \>  
      \<boxGeometry args={\[1, 1, 1\]} /\>  
      \<meshStandardMaterial color="\#60A5FA" roughness={0.25} metalness={0.6} /\>  
    \</mesh\>  
  );  
};

const Scene1: React.FC \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
  };

  const labelOpacity \= interpolate(frame, \[20, 45\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const labelY \= interpolate(frame, \[20, 45\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, \#1A1A2E 0%, ${COLORS.bg} 70%)\`,  
        fontFamily: "Inter, sans-serif",  
      }}  
    \>  
      {/\* 3D Canvas \*/}  
      \<ThreeCanvas width={width} height={height}\>  
        \<ambientLight intensity={0.4} /\>  
        \<pointLight position={\[4, 4, 4\]} intensity={1.2} color="\#60A5FA" /\>  
        \<pointLight position={\[-4, \-2, 2\]} intensity={0.5} color="\#A78BFA" /\>  
        \<directionalLight position={\[0, 5, 5\]} intensity={0.6} /\>  
        \<RotatingCube frame={frame} fps={fps} /\>  
      \</ThreeCanvas\>

      {/\* Label \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-end",  
          paddingBottom: Math.round(height \* 0.1),  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            opacity: labelOpacity,  
            transform: \`translateY(${labelY}px)\`,  
            display: "flex",  
            flexDirection: "column",  
            alignItems: "center",  
            gap: 8,  
          }}  
        \>  
          \<div  
            style={{  
              width: 40,  
              height: 2,  
              background: COLORS.accent,  
              borderRadius: 2,  
            }}  
          /\>  
          \<span  
            style={{  
              color: COLORS.textMuted,  
              fontSize: Math.max(13, Math.round(width \* 0.016)),  
              fontWeight: 400,  
              letterSpacing: "0.18em",  
              textTransform: "uppercase",  
            }}  
          \>  
            Interactive 3D  
          \</span\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

const Scene2: React.FC \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
  };

  const TIMING \= { BASE: 12, STAGGER: 14 };

  const words \= \["Design", "Beyond", "Limits"\];

  const makeWordAnim \= (idx: number) \=\> {  
    const start \= idx \* TIMING.STAGGER;  
    const end \= start \+ TIMING.BASE \+ 10;  
    return {  
      opacity: interpolate(frame, \[start, end\], \[0, 1\], {  
        extrapolateLeft: "clamp",  
        extrapolateRight: "clamp",  
      }),  
      y: interpolate(frame, \[start, start \+ TIMING.BASE\], \[40, 0\], {  
        extrapolateLeft: "clamp",  
        extrapolateRight: "clamp",  
      }),  
    };  
  };

  const subtitleStart \= words.length \* TIMING.STAGGER \+ 6;  
  const subtitleOpacity \= interpolate(frame, \[subtitleStart, subtitleStart \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const subtitleY \= interpolate(frame, \[subtitleStart, subtitleStart \+ 20\], \[16, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const lineScale \= interpolate(frame, \[subtitleStart, subtitleStart \+ 25\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleSize \= Math.max(48, Math.round(width \* 0.072));  
  const subtitleSize \= Math.max(16, Math.round(width \* 0.022));

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`linear-gradient(160deg, \#0A0A14 0%, \#000000 50%, \#0A1A0A 100%)\`,  
        fontFamily: "Inter, sans-serif",  
        display: "flex",  
        flexDirection: "column",  
        alignItems: "center",  
        justifyContent: "center",  
      }}  
    \>  
      {/\* Accent dot grid (static, decorative) \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: "12%",  
          right: "8%",  
          width: 80,  
          height: 80,  
          opacity: 0.15,  
          backgroundImage: \`radial-gradient(circle, ${COLORS.accent} 1.5px, transparent 1.5px)\`,  
          backgroundSize: "16px 16px",  
        }}  
      /\>  
      \<div  
        style={{  
          position: "absolute",  
          bottom: "15%",  
          left: "6%",  
          width: 60,  
          height: 60,  
          opacity: 0.1,  
          backgroundImage: \`radial-gradient(circle, ${COLORS.textMuted} 1px, transparent 1px)\`,  
          backgroundSize: "12px 12px",  
        }}  
      /\>

      {/\* Title words \*/}  
      \<div  
        style={{  
          display: "flex",  
          flexDirection: "row",  
          gap: Math.round(width \* 0.025),  
          overflow: "hidden",  
          marginBottom: Math.round(height \* 0.03),  
        }}  
      \>  
        {words.map((word, idx) \=\> {  
          const anim \= makeWordAnim(idx);  
          const isAccent \= idx \=== 2;  
          return (  
            \<div  
              key={word}  
              style={{  
                opacity: anim.opacity,  
                transform: \`translateY(${anim.y}px)\`,  
                fontSize: titleSize,  
                fontWeight: 800,  
                letterSpacing: "-0.03em",  
                lineHeight: 1.05,  
                color: isAccent ? COLORS.accent : COLORS.text,  
              }}  
            \>  
              {word}  
            \</div\>  
          );  
        })}  
      \</div\>

      {/\* Accent line \*/}  
      \<div  
        style={{  
          width: Math.round(width \* 0.18),  
          height: 3,  
          background: \`linear-gradient(90deg, ${COLORS.accent}, transparent)\`,  
          borderRadius: 2,  
          transformOrigin: "left center",  
          transform: \`scaleX(${lineScale})\`,  
          marginBottom: Math.round(height \* 0.035),  
        }}  
      /\>

      {/\* Subtitle \*/}  
      \<div  
        style={{  
          opacity: subtitleOpacity,  
          transform: \`translateY(${subtitleY}px)\`,  
          color: COLORS.textMuted,  
          fontSize: subtitleSize,  
          fontWeight: 400,  
          letterSpacing: "0.14em",  
          textTransform: "uppercase",  
        }}  
      \>  
        Crafted with precision & motion  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

// ─── Main Export ───────────────────────────────────────────────────────────────

export const MyAnimation \= () \=\> {  
  /\*  
   \* Main composition orchestrating two scenes via TransitionSeries.  
   \* Scene 1: Rotating 3D cube (150 frames), Scene 2: Animated text reveal (150 frames).  
   \* A 15-frame fade transition bridges the two scenes (total: 285 frames at 30fps).  
   \*/  
  const { fps } \= useVideoConfig();

  return (  
    \<TransitionSeries\>  
      \<TransitionSeries.Sequence durationInFrames={150} premountFor={fps}\>  
        \<Scene1 /\>  
      \</TransitionSeries.Sequence\>

      \<TransitionSeries.Transition  
        presentation={fade()}  
        timing={linearTiming({ durationInFrames: 15 })}  
      /\>

      \<TransitionSeries.Sequence durationInFrames={150} premountFor={fps}\>  
        \<Scene2 /\>  
      \</TransitionSeries.Sequence\>  
    \</TransitionSeries\>  
  );  
};

prompt:

Crie uma animação 3D com um cubo girando no centro da tela.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
 \* A cinematic 3D animation featuring a reflective cube rotating at the center of the screen.  
 \* The cube has a premium dark aesthetic with a smooth spring-based entrance scale animation.  
 \* Continuous Y-axis rotation combined with subtle X-axis tilt creates a dynamic, polished look.  
 \*/

export const MyAnimation \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    surface2: "\#1A1A1E",  
    accent: "\#60A5FA",  
    accent2: "\#34D399",  
    glow: "\#3B82F6",  
  };

  const TIMING \= { BASE: 20, SPRING\_DAMPING: 14, SPRING\_STIFFNESS: 90 };

  // Spring-based entrance scale  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: {  
      damping: TIMING.SPRING\_DAMPING,  
      stiffness: TIMING.SPRING\_STIFFNESS,  
    },  
  });

  // Rotation values driven by frame  
  const rotationY \= frame \* 0.025;  
  const rotationX \= Math.sin(frame \* 0.018) \* 0.4;  
  const rotationZ \= Math.sin(frame \* 0.012) \* 0.15;

  // Floating Y offset  
  const floatY \= Math.sin(frame \* 0.06) \* 0.18;

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, \#0D1B2A 0%, \#000000 70%)\`,  
      }}  
    \>  
      {/\* Subtle grid overlay \*/}  
      \<AbsoluteFill  
        style={{  
          backgroundImage: \`  
            linear-gradient(rgba(96,165,250,0.03) 1px, transparent 1px),  
            linear-gradient(90deg, rgba(96,165,250,0.03) 1px, transparent 1px)  
          \`,  
          backgroundSize: "60px 60px",  
          zIndex: 0,  
        }}  
      /\>

      {/\* Glow behind cube \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "center",  
          justifyContent: "center",  
          zIndex: 1,  
        }}  
      \>  
        \<div  
          style={{  
            width: Math.round(width \* 0.35),  
            height: Math.round(width \* 0.35),  
            borderRadius: "50%",  
            background: \`radial-gradient(circle, rgba(59,130,246,0.18) 0%, transparent 70%)\`,  
            transform: \`scale(${scaleProgress})\`,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 2 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.3} /\>  
          \<directionalLight position={\[5, 8, 5\]} intensity={1.2} color="\#ffffff" /\>  
          \<pointLight position={\[-4, \-3, 3\]} intensity={0.6} color="\#60A5FA" /\>  
          \<pointLight position={\[4, 3, \-3\]} intensity={0.4} color="\#34D399" /\>

          {/\* Rotating cube \*/}  
          \<mesh  
            position={\[0, floatY, 0\]}  
            rotation={\[rotationX, rotationY, rotationZ\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<boxGeometry args={\[1.8, 1.8, 1.8\]} /\>  
            \<meshStandardMaterial  
              color="\#1E3A5F"  
              metalness={0.85}  
              roughness={0.12}  
              emissive="\#0A2040"  
              emissiveIntensity={0.3}  
            /\>  
          \</mesh\>

          {/\* Wireframe overlay for depth \*/}  
          \<mesh  
            position={\[0, floatY, 0\]}  
            rotation={\[rotationX, rotationY, rotationZ\]}  
            scale={\[scaleProgress \* 1.02, scaleProgress \* 1.02, scaleProgress \* 1.02\]}  
          \>  
            \<boxGeometry args={\[1.8, 1.8, 1.8\]} /\>  
            \<meshBasicMaterial color="\#60A5FA" wireframe opacity={0.4} transparent /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Bottom label \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.08),  
          zIndex: 3,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: Math.max(14, Math.round(width \* 0.018)),  
            fontWeight: 300,  
            letterSpacing: "0.3em",  
            color: "rgba(160,160,168,0.7)",  
            textTransform: "uppercase",  
            opacity: scaleProgress,  
          }}  
        \>  
          3D Cube Rotation  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

\*\*Prompt A (minimal):\*\*  
\`\`\`  
Cubo 3D.  
\`\`\`

\*\*Prompt B (detalhado):\*\*  
\`\`\`  
Crie uma animação com um cubo 3D azul metálico girando lentamente no centro da tela com fundo escuro.

resultado A:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

/\*  
  A 3D rotating cube animation with a premium dark aesthetic.  
  The cube features smooth spring-based entrance scaling and continuous rotation.  
  Ambient and directional lighting give it depth and a polished metallic look.  
\*/

export const MyAnimation \= () \=\> {  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    surface2: "\#1A1A1E",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accent2: "\#34D399",  
  };

  const TIMING \= { BASE: 20, FADE: 40, SPRING\_DAMPING: 14, SPRING\_STIFFNESS: 80 };

  // Spring entrance scale  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: TIMING.SPRING\_DAMPING, stiffness: TIMING.SPRING\_STIFFNESS },  
  });

  // Continuous rotations  
  const rotationY \= frame \* 0.025;  
  const rotationX \= frame \* 0.015;

  // Background fade in  
  const bgOpacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Title fade in  
  const titleOpacity \= interpolate(frame, \[TIMING.BASE, TIMING.BASE \+ TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleY \= interpolate(frame, \[TIMING.BASE, TIMING.BASE \+ TIMING.FADE\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, \#0D1B35 0%, \#000000 70%)\`,  
        opacity: bgOpacity,  
      }}  
    \>  
      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5\], fov: 60 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.35} /\>  
          \<directionalLight position={\[5, 8, 5\]} intensity={1.1} color="\#FFFFFF" /\>  
          \<pointLight position={\[-5, \-3, 3\]} intensity={0.5} color={COLORS.accent} /\>  
          \<pointLight position={\[4, \-4, \-2\]} intensity={0.4} color={COLORS.accent2} /\>

          {/\* Cube \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<boxGeometry args={\[2.2, 2.2, 2.2\]} /\>  
            \<meshStandardMaterial  
              color="\#1E3A5F"  
              metalness={0.75}  
              roughness={0.2}  
            /\>  
          \</mesh\>

          {/\* Wireframe overlay \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, 0\]}  
            scale={\[scaleProgress \* 1.002, scaleProgress \* 1.002, scaleProgress \* 1.002\]}  
          \>  
            \<boxGeometry args={\[2.2, 2.2, 2.2\]} /\>  
            \<meshStandardMaterial  
              color={COLORS.accent}  
              wireframe  
              transparent  
              opacity={0.35}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Subtle grid overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 2,  
          background:  
            "repeating-linear-gradient(0deg, transparent, transparent 59px, rgba(96,165,250,0.04) 60px), repeating-linear-gradient(90deg, transparent, transparent 59px, rgba(96,165,250,0.04) 60px)",  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Title \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 3,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-end",  
          paddingBottom: Math.round(height \* 0.1),  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 800,  
              fontSize: Math.max(32, Math.round(width \* 0.055)),  
              letterSpacing: "-0.02em",  
              lineHeight: 1.1,  
              color: COLORS.text,  
              marginBottom: 10,  
            }}  
          \>  
            CUBO{" "}  
            \<span  
              style={{  
                background: \`linear-gradient(135deg, ${COLORS.accent}, ${COLORS.accent2})\`,  
                WebkitBackgroundClip: "text",  
                WebkitTextFillColor: "transparent",  
              }}  
            \>  
              3D  
            \</span\>  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 400,  
              fontSize: Math.max(12, Math.round(width \* 0.018)),  
              letterSpacing: "0.15em",  
              color: COLORS.textMuted,  
              textTransform: "uppercase",  
            }}  
          \>  
            Rotação Contínua · WebGL  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Vignette \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 4,  
          background:  
            "radial-gradient(ellipse at 50% 50%, transparent 40%, rgba(0,0,0,0.65) 100%)",  
          pointerEvents: "none",  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

resultado B:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";

export const MyAnimation \= () \=\> {  
  /\*  
   \* A premium dark animation featuring a metallic blue 3D cube rotating slowly at the center.  
   \* The cube has a polished metallic finish with ambient and directional lighting for depth.  
   \* A subtle entrance animation scales the cube in with a spring effect.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    accent: "\#60A5FA",  
    glow: "\#1A3FE0",  
  };

  const TIMING \= { ENTRANCE: 20 };

  // Calculations  
  const rotationY \= frame \* 0.018;  
  const rotationX \= frame \* 0.007;  
  const rotationZ \= frame \* 0.004;

  const floatY \= Math.sin(frame \* 0.04) \* 0.12;

  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 90, mass: 1.2 },  
  });

  const globalOpacity \= interpolate(frame, \[0, TIMING.ENTRANCE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 50%, ${COLORS.surface1} 0%, ${COLORS.bg} 70%)\`,  
        opacity: globalOpacity,  
      }}  
    \>  
      {/\* Subtle glow backdrop \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 45% 35% at 50% 50%, rgba(26, 63, 224, 0.12) 0%, transparent 70%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 5\], fov: 55 }}  
        \>  
          {/\* Lighting setup \*/}  
          \<ambientLight intensity={0.25} color="\#8ab4f8" /\>  
          \<directionalLight  
            position={\[5, 8, 6\]}  
            intensity={1.4}  
            color="\#c8d8ff"  
          /\>  
          \<directionalLight  
            position={\[-6, \-4, \-3\]}  
            intensity={0.35}  
            color="\#1A3FE0"  
          /\>  
          \<pointLight  
            position={\[0, 0, 4\]}  
            intensity={0.6}  
            color="\#60A5FA"  
          /\>  
          \<pointLight  
            position={\[-4, 3, 2\]}  
            intensity={0.4}  
            color="\#3b82f6"  
          /\>

          {/\* Metallic blue cube \*/}  
          \<mesh  
            rotation={\[rotationX, rotationY, rotationZ\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<boxGeometry args={\[2, 2, 2\]} /\>  
            \<meshStandardMaterial  
              color="\#1e40af"  
              metalness={0.92}  
              roughness={0.08}  
              envMapIntensity={1.5}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background:  
            "radial-gradient(ellipse 80% 80% at 50% 50%, transparent 40%, rgba(5,5,16,0.65) 100%)",  
          zIndex: 2,  
          pointerEvents: "none",  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D com uma esfera vermelha que pulsa com tensão crescente, como um alarme prestes a disparar.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring, Easing } from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import { useFrame } from "@react-three/fiber";  
import \* as THREE from "three";

/\*  
 \* A pulsing red sphere animation that builds tension like an alarm about to trigger.  
 \* The sphere grows, pulses faster, and the environment reacts with increasing urgency.  
 \* Shockwave rings emanate outward as tension peaks at the final moment.  
 \*/

const NUM\_RINGS \= 4;

const PulsingSphere \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  // Tension progress: 0 to 1 over the full duration  
  const tension \= interpolate(frame, \[0, 150\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
  });

  // Pulse frequency increases with tension  
  const basePulseSpeed \= 0.04 \+ tension \* 0.18;  
  const pulseAmp \= 0.08 \+ tension \* 0.22;  
  const pulseSine \= Math.sin(frame \* basePulseSpeed \* Math.PI \* 2);  
  const pulseScale \= 1 \+ pulseSine \* pulseAmp;

  // Entrance spring  
  const entrance \= spring({ frame, fps, config: { damping: 200, stiffness: 80 } });  
  const baseScale \= interpolate(entrance, \[0, 1\], \[0, 1\]);

  const finalScale \= baseScale \* pulseScale;

  // Color shifts from dark red to bright crimson to orange-white at peak  
  const r \= interpolate(tension, \[0, 0.5, 1\], \[0.5, 1.0, 1.0\]);  
  const g \= interpolate(tension, \[0, 0.5, 1\], \[0.0, 0.0, 0.25\]);  
  const b \= interpolate(tension, \[0, 0.5, 1\], \[0.0, 0.0, 0.0\]);

  // Emissive intensity grows with tension  
  const emissiveIntensity \= interpolate(tension, \[0, 1\], \[0.1, 1.2\]);

  // Shockwave rings  
  const rings \= Array.from({ length: NUM\_RINGS }, (\_, i) \=\> {  
    const ringOffset \= i \* (fps \* 0.6);  
    const ringFrame \= frame \- ringOffset;  
    if (ringFrame \< 0\) return null;  
    const ringProgress \= interpolate(ringFrame, \[0, fps \* 1.2\], \[0, 1\], {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
    });  
    const ringScale \= interpolate(ringProgress, \[0, 1\], \[1, 3.5 \+ tension \* 2\]);  
    const ringOpacity \= interpolate(ringProgress, \[0, 0.3, 1\], \[0, 0.6, 0\]);  
    return { ringScale, ringOpacity, key: i };  
  });

  return (  
    \<\>  
      {/\* Ambient \+ directional lighting \*/}  
      \<ambientLight intensity={0.3} /\>  
      \<pointLight position={\[0, 0, 0\]} intensity={interpolate(tension, \[0, 1\], \[2, 8\])} color={new THREE.Color(r, g \* 0.3, b)} /\>  
      \<directionalLight position={\[5, 5, 5\]} intensity={0.6} /\>  
      \<directionalLight position={\[-5, \-3, \-5\]} intensity={0.2} color={new THREE.Color(1, 0, 0)} /\>

      {/\* Shockwave rings \*/}  
      {rings.map((ring) \=\>  
        ring ? (  
          \<mesh key={ring.key} rotation={\[Math.PI / 2, 0, 0\]} scale={\[ring.ringScale, ring.ringScale, 1\]}\>  
            \<torusGeometry args={\[1, 0.03, 8, 64\]} /\>  
            \<meshStandardMaterial  
              color={new THREE.Color(r, g \* 0.4, b)}  
              transparent  
              opacity={ring.ringOpacity \* (0.4 \+ tension \* 0.6)}  
              emissive={new THREE.Color(r \* 0.8, 0, 0)}  
              emissiveIntensity={0.5}  
            /\>  
          \</mesh\>  
        ) : null  
      )}

      {/\* Main pulsing sphere \*/}  
      \<mesh scale={\[finalScale, finalScale, finalScale\]}\>  
        \<sphereGeometry args={\[1, 64, 64\]} /\>  
        \<meshStandardMaterial  
          color={new THREE.Color(r, g, b)}  
          emissive={new THREE.Color(r \* 0.6, g \* 0.1, 0)}  
          emissiveIntensity={emissiveIntensity}  
          roughness={interpolate(tension, \[0, 1\], \[0.4, 0.1\])}  
          metalness={interpolate(tension, \[0, 1\], \[0.1, 0.6\])}  
        /\>  
      \</mesh\>

      {/\* Inner glow sphere \*/}  
      \<mesh scale={\[finalScale \* 1.05, finalScale \* 1.05, finalScale \* 1.05\]}\>  
        \<sphereGeometry args={\[1, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color={new THREE.Color(1, 0.1, 0)}  
          transparent  
          opacity={interpolate(tension, \[0, 1\], \[0.0, 0.18\])}  
          emissive={new THREE.Color(1, 0.2, 0)}  
          emissiveIntensity={2}  
          side={THREE.BackSide}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Red sphere alarm animation using 3D ThreeCanvas with increasing tension.  
   \* The sphere pulses faster and brighter, with shockwave rings emanating outward.  
   \* Background and overlays react to the escalating urgency.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // Design archetype: BOLD & CONTRAST with alarm urgency  
  const COLORS \= {  
    bg: "\#0A0000",  
    surface1: "\#1A0000",  
    text: "\#F5F5F5",  
    accent: "\#E01A1A",  
    warn: "\#FF4422",  
  };  
  const TIMING \= { BASE: 15, FADE: 30, STAGGER: 8 };

  const tension \= interpolate(frame, \[0, 150\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
  });

  // Screen flash at high tension  
  const pulseSpeed \= 0.04 \+ tension \* 0.18;  
  const flashSine \= Math.sin(frame \* pulseSpeed \* Math.PI \* 2);  
  const flashOpacity \= interpolate(tension, \[0.5, 1\], \[0, 0.12\]) \* Math.max(0, flashSine);

  // Background red bleed grows with tension  
  const bgRedOpacity \= interpolate(tension, \[0, 1\], \[0, 0.35\]);

  // Status text  
  const statusOpacity \= interpolate(frame, \[20, 40\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const warningOpacity \= interpolate(tension, \[0.4, 0.6\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Warning text blink at high tension  
  const blinkRate \= 0.08 \+ tension \* 0.25;  
  const blinkSine \= Math.sin(frame \* blinkRate \* Math.PI \* 2);  
  const blinkOpacity \= tension \> 0.7 ? interpolate(blinkSine, \[-1, 1\], \[0.3, 1\]) : 1;

  // Tension bar  
  const barWidth \= Math.round(width \* 0.6);  
  const barFill \= interpolate(tension, \[0, 1\], \[0, barWidth\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Vignette opacity  
  const vignetteOpacity \= interpolate(tension, \[0, 1\], \[0.3, 0.75\]);

  const titleSize \= Math.max(16, Math.round(height \* 0.028));  
  const warningSize \= Math.max(20, Math.round(height \* 0.038));  
  const labelSize \= Math.max(11, Math.round(height \* 0.018));

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Background gradient that bleeds red with tension \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at center, rgba(120,0,0,${bgRedOpacity}) 0%, transparent 70%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Scene \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 0, 4\], fov: 60 }}\>  
          \<PulsingSphere frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at center, transparent 35%, rgba(0,0,0,${vignetteOpacity}) 100%)\`,  
          zIndex: 2,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Flash overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`rgba(255, 30, 0, ${flashOpacity})\`,  
          zIndex: 3,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* UI: Top status bar \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-start",  
          paddingTop: Math.round(height \* 0.06),  
          opacity: statusOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: titleSize,  
            fontWeight: 700,  
            color: COLORS.text,  
            letterSpacing: "0.22em",  
            textTransform: "uppercase",  
            opacity: 0.7,  
          }}  
        \>  
          SYSTEM ALERT  
        \</div\>

        {/\* Tension bar \*/}  
        \<div  
          style={{  
            marginTop: Math.round(height \* 0.025),  
            width: barWidth,  
            height: Math.round(height \* 0.008),  
            background: "rgba(255,255,255,0.12)",  
            borderRadius: 4,  
            overflow: "hidden",  
          }}  
        \>  
          \<div  
            style={{  
              width: barFill,  
              height: "100%",  
              background: \`linear-gradient(90deg, \#8B0000, \#E01A1A ${interpolate(tension, \[0, 1\], \[50, 80\])}%, \#FF6622)\`,  
              borderRadius: 4,  
            }}  
          /\>  
        \</div\>

        \<div  
          style={{  
            marginTop: Math.round(height \* 0.012),  
            fontFamily: "monospace",  
            fontSize: labelSize,  
            color: COLORS.accent,  
            letterSpacing: "0.15em",  
            opacity: 0.85,  
          }}  
        \>  
          TENSION {Math.round(tension \* 100)}%  
        \</div\>  
      \</AbsoluteFill\>

      {/\* UI: Bottom warning \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 5,  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-end",  
          paddingBottom: Math.round(height \* 0.07),  
          opacity: warningOpacity \* blinkOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: warningSize,  
            fontWeight: 900,  
            color: COLORS.warn,  
            letterSpacing: "0.3em",  
            textTransform: "uppercase",  
            textShadow: \`0 0 20px rgba(224,26,26,0.8)\`,  
          }}  
        \>  
          ⚠ CRITICAL ⚠  
        \</div\>  
        \<div  
          style={{  
            marginTop: Math.round(height \* 0.01),  
            fontFamily: "monospace",  
            fontSize: labelSize,  
            color: COLORS.text,  
            letterSpacing: "0.15em",  
            opacity: 0.6,  
          }}  
        \>  
          IMMINENT DETONATION  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D que transmita paz e contemplação — algo que a pessoa olharia por longos minutos sem se cansar.

resultado:  
import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring, Easing } from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef, useMemo } from "react";  
import \* as THREE from "three";

/\*  
  A serene, contemplative 3D animation featuring slowly rotating geometric forms  
  suspended in a deep, meditative space. Soft light gradients and unhurried motion  
  create a sense of infinite calm — something one could watch indefinitely.  
\*/

const FloatingRing \= ({ frame, fps, index }: { frame: number; fps: number; index: number }) \=\> {  
  const delay \= index \* 18;  
  const speed \= 0.003 \+ index \* 0.0008;  
  const tilt \= (index \* Math.PI) / 5 \+ Math.PI / 7;

  const rotY \= (frame \- delay) \* speed;  
  const rotX \= tilt \+ Math.sin((frame \- delay) \* 0.007 \+ index) \* 0.08;  
  const floatY \= Math.sin((frame \- delay) \* 0.012 \+ index \* 1.2) \* 0.18;  
  const scale \= 1 \+ Math.sin((frame \- delay) \* 0.009 \+ index \* 0.7) \* 0.04;

  const scaleIn \= spring({  
    frame: frame \- delay,  
    fps,  
    config: { damping: 200, stiffness: 60 },  
    durationInFrames: 90,  
  });

  const opacity \= interpolate(  
    frame \- delay,  
    \[0, 60\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.bezier(0.45, 0, 0.55, 1\) }  
  );

  const radii: \[number, number, number\] \= \[  
    \[1.0, 0.025, 64, 3\]\[0\],  
    \[1.55, 0.018, 64, 3\]\[0\],  
    \[2.1, 0.014, 64, 3\]\[0\],  
    \[0.62, 0.032, 64, 3\]\[0\],  
    \[2.7, 0.012, 64, 3\]\[0\],  
  \]\[index\] as unknown as \[number, number, number\];

  const tubeRadii \= \[0.025, 0.018, 0.014, 0.032, 0.012\]\[index\];  
  const outerRadius \= \[1.0, 1.55, 2.1, 0.62, 2.7\]\[index\];

  const colors \= \["\#7EC8C8", "\#B8A9E0", "\#A8D5BA", "\#F0C9A0", "\#8BB8E8"\];  
  const color \= colors\[index % colors.length\];

  return (  
    \<group  
      rotation={\[rotX, rotY, index \* 0.4\]}  
      position={\[0, floatY, 0\]}  
      scale={\[scaleIn \* scale, scaleIn \* scale, scaleIn \* scale\]}  
    \>  
      \<mesh\>  
        \<torusGeometry args={\[outerRadius, tubeRadii, 16, 80\]} /\>  
        \<meshStandardMaterial  
          color={color}  
          transparent  
          opacity={opacity \* (0.55 \+ index \* 0.04)}  
          roughness={0.3}  
          metalness={0.6}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const CoreSphere \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleIn \= spring({  
    frame,  
    fps,  
    config: { damping: 200, stiffness: 40 },  
    durationInFrames: 120,  
  });

  const breathe \= 1 \+ Math.sin(frame \* 0.018) \* 0.06;  
  const rotY \= frame \* 0.004;  
  const opacity \= interpolate(frame, \[0, 80\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
  });

  return (  
    \<group rotation={\[0.3, rotY, 0\]} scale={\[scaleIn \* breathe, scaleIn \* breathe, scaleIn \* breathe\]}\>  
      \<mesh\>  
        \<sphereGeometry args={\[0.28, 64, 64\]} /\>  
        \<meshStandardMaterial  
          color="\#D4E8F5"  
          transparent  
          opacity={opacity \* 0.85}  
          roughness={0.05}  
          metalness={0.9}  
          envMapIntensity={1}  
        /\>  
      \</mesh\>  
      \<mesh\>  
        \<sphereGeometry args={\[0.36, 32, 32\]} /\>  
        \<meshStandardMaterial  
          color="\#9BCFE8"  
          transparent  
          opacity={opacity \* 0.12}  
          roughness={0.0}  
          metalness={0.0}  
          side={THREE.BackSide}  
        /\>  
      \</mesh\>  
    \</group\>  
  );  
};

const ParticleField \= ({ frame }: { frame: number }) \=\> {  
  const count \= 60;  
  const particles \= useMemo(() \=\> {  
    return Array.from({ length: count }, (\_, i) \=\> {  
      const phi \= Math.acos(2 \* ((i \* 0.618033988749895) % 1\) \- 1);  
      const theta \= 2 \* Math.PI \* ((i \* 0.618033988749895) % 1\) \* 7.3;  
      const r \= 2.8 \+ ((i \* 137.508) % 1.4);  
      return {  
        x: r \* Math.sin(phi) \* Math.cos(theta),  
        y: r \* Math.sin(phi) \* Math.sin(theta),  
        z: r \* Math.cos(phi),  
        speed: 0.003 \+ (i % 7\) \* 0.0005,  
        phase: i \* 0.42,  
        size: 0.012 \+ (i % 4\) \* 0.006,  
      };  
    });  
  }, \[\]);

  return (  
    \<\>  
      {particles.map((p, i) \=\> {  
        const opacity \= interpolate(frame, \[i \* 3, i \* 3 \+ 50\], \[0, 1\], {  
          extrapolateLeft: "clamp",  
          extrapolateRight: "clamp",  
        });  
        const drift \= Math.sin(frame \* p.speed \+ p.phase) \* 0.06;  
        const driftX \= Math.cos(frame \* p.speed \* 0.7 \+ p.phase) \* 0.04;  
        return (  
          \<mesh key={i} position={\[p.x \+ driftX, p.y \+ drift, p.z\]}\>  
            \<sphereGeometry args={\[p.size, 6, 6\]} /\>  
            \<meshStandardMaterial  
              color="\#C8DFF5"  
              transparent  
              opacity={opacity \* 0.45}  
              roughness={0.1}  
              metalness={0.8}  
            /\>  
          \</mesh\>  
        );  
      })}  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
    Main composition — a slow, infinite contemplative loop of tori, a breathing  
    central sphere, and a sparse particle field, all set against a deep gradient void.  
  \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // ── Theme tokens ──────────────────────────────────────────────────────────────  
  const COLORS \= {  
    bg: "\#020810",  
    gradMid: "\#060E1C",  
    gradEdge: "\#030A14",  
    vignette: "rgba(2,8,16,0.72)",  
  };  
  const TIMING \= { FADE\_IN: 40 };

  // ── Derived ───────────────────────────────────────────────────────────────────  
  const masterOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
  });

  const bgPulse \= interpolate(  
    Math.sin(frame \* 0.008),  
    \[-1, 1\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const bgColor1 \= \`rgba(${4 \+ Math.round(bgPulse \* 3)}, ${10 \+ Math.round(bgPulse \* 4)}, ${22 \+ Math.round(bgPulse \* 6)}, 1)\`;

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Background gradient \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, ${bgColor1} 0%, \#020810 60%, \#010508 100%)\`,  
          opacity: masterOpacity,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ opacity: masterOpacity }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 6\], fov: 48 }}  
        \>  
          {/\* Lighting \*/}  
          \<ambientLight intensity={0.18} color="\#8aafd4" /\>  
          \<pointLight position={\[4, 4, 4\]} intensity={1.1} color="\#b8d4f0" /\>  
          \<pointLight position={\[-5, \-2, 3\]} intensity={0.55} color="\#c4a8e8" /\>  
          \<pointLight position={\[0, \-4, \-3\]} intensity={0.35} color="\#80c8c0" /\>  
          \<directionalLight position={\[2, 6, 2\]} intensity={0.4} color="\#e0eeff" /\>

          {/\* Core glowing sphere \*/}  
          \<CoreSphere frame={frame} fps={fps} /\>

          {/\* Floating rings \*/}  
          {\[0, 1, 2, 3, 4\].map((i) \=\> (  
            \<FloatingRing key={i} frame={frame} fps={fps} index={i} /\>  
          ))}

          {/\* Particle field \*/}  
          \<ParticleField frame={frame} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, transparent 42%, ${COLORS.vignette} 100%)\`,  
          opacity: masterOpacity,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Subtle scan-line texture at very low opacity \*/}  
      \<AbsoluteFill  
        style={{  
          backgroundImage:  
            "repeating-linear-gradient(0deg, rgba(255,255,255,0.013) 0px, rgba(255,255,255,0.013) 1px, transparent 1px, transparent 3px)",  
          opacity: masterOpacity \* 0.5,  
          pointerEvents: "none",  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D com um único objeto no centro absoluto, onde o vazio ao redor faz parte da composição.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring, Easing } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

export const MyAnimation \= () \=\> {  
  /\*  
   \* A single geometric form floats in absolute stillness at the center of an infinite void.  
   \* The emptiness is intentional — the negative space amplifies the object's presence.  
   \* Subtle rotation and breathing animation give the form life without breaking the silence.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // Theme tokens  
  const COLORS \= {  
    bg: '\#000000',  
    surface1: '\#0A0A0A',  
    accent: '\#C8C8D4',  
    accentWarm: '\#E8D5C0',  
    glow: 'rgba(200, 200, 212, 0.06)',  
  };

  const TIMING \= {  
    BREATHE\_SPEED: 0.018,  
    ROTATE\_SPEED: 0.008,  
    FLOAT\_SPEED: 0.012,  
    INTRO\_DURATION: fps \* 1.5,  
  };

  // Derived animation values  
  const introScale \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 60, mass: 1.2 },  
  });

  const breathe \= Math.sin(frame \* TIMING.BREATHE\_SPEED) \* 0.06 \+ 1;  
  const floatY \= Math.sin(frame \* TIMING.FLOAT\_SPEED) \* 0.15;  
  const rotationY \= frame \* TIMING.ROTATE\_SPEED;  
  const rotationX \= Math.sin(frame \* TIMING.BREATHE\_SPEED \* 0.7) \* 0.15;

  const scale \= introScale \* breathe;

  // Background vignette opacity  
  const vignetteOpacity \= interpolate(frame, \[0, fps\], \[0, 1\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
    easing: Easing.out(Easing.cubic),  
  });

  // Subtle label fade in  
  const labelOpacity \= interpolate(frame, \[fps \* 1.2, fps \* 2.2\], \[0, 0.35\], {  
    extrapolateLeft: 'clamp',  
    extrapolateRight: 'clamp',  
    easing: Easing.out(Easing.cubic),  
  });

  // Rotating gem sub-component  
  const GemObject \= () \=\> {  
    return (  
      \<\>  
        {/\* Ambient light — very dim for dramatic contrast \*/}  
        \<ambientLight intensity={0.08} /\>

        {/\* Key light — warm, slightly above \*/}  
        \<directionalLight  
          position={\[3, 4, 5\]}  
          intensity={1.4}  
          color="\#F0E8DC"  
        /\>

        {/\* Fill light — cool, opposite side \*/}  
        \<directionalLight  
          position={\[-4, \-2, \-3\]}  
          intensity={0.3}  
          color="\#C0C8E8"  
        /\>

        {/\* Rim light — edge highlight \*/}  
        \<pointLight  
          position={\[0, 6, \-4\]}  
          intensity={0.6}  
          color="\#FFFFFF"  
        /\>

        {/\* Central gem — octahedron for crystalline feel \*/}  
        \<mesh  
          rotation={\[rotationX, rotationY, rotationY \* 0.3\]}  
          position={\[0, floatY, 0\]}  
          scale={\[scale, scale, scale\]}  
        \>  
          \<octahedronGeometry args={\[1.1, 0\]} /\>  
          \<meshPhysicalMaterial  
            color="\#D8D4E8"  
            metalness={0.7}  
            roughness={0.05}  
            reflectivity={1}  
            clearcoat={1}  
            clearcoatRoughness={0.02}  
            envMapIntensity={1}  
          /\>  
        \</mesh\>

        {/\* Inner wireframe ghost — creates depth \*/}  
        \<mesh  
          rotation={\[rotationX \+ 0.4, rotationY \* 1.3, rotationY \* 0.5\]}  
          position={\[0, floatY \* 0.5, 0\]}  
          scale={\[scale \* 1.55, scale \* 1.55, scale \* 1.55\]}  
        \>  
          \<octahedronGeometry args={\[1.1, 0\]} /\>  
          \<meshBasicMaterial  
            color="\#FFFFFF"  
            wireframe={true}  
            opacity={0.04}  
            transparent={true}  
          /\>  
        \</mesh\>  
      \</\>  
    );  
  };

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg }}\>

      {/\* Radial vignette — builds depth from corners \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, transparent 30%, rgba(0,0,0,0.85) 100%)\`,  
          opacity: vignetteOpacity,  
          zIndex: 0,  
        }}  
      /\>

      {/\* Very subtle center glow — grounds the object \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 50%, ${COLORS.glow} 0%, transparent 55%)\`,  
          opacity: introScale,  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 4.5\], fov: 55 }}  
        \>  
          \<GemObject /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Horizontal rule — top left, ultra-minimal \*/}  
      \<div  
        style={{  
          position: 'absolute',  
          top: Math.round(height \* 0.078),  
          left: Math.round(width \* 0.055),  
          width: Math.round(width \* 0.04),  
          height: 1,  
          background: COLORS.accent,  
          opacity: labelOpacity,  
          zIndex: 10,  
        }}  
      /\>

      {/\* Label — top left \*/}  
      \<div  
        style={{  
          position: 'absolute',  
          top: Math.round(height \* 0.072),  
          left: Math.round(width \* 0.055) \+ Math.round(width \* 0.055),  
          fontFamily: 'Inter, sans-serif',  
          fontSize: Math.max(10, Math.round(width \* 0.013)),  
          fontWeight: 300,  
          letterSpacing: '0.22em',  
          color: COLORS.accent,  
          opacity: labelOpacity,  
          zIndex: 10,  
          textTransform: 'uppercase',  
        }}  
      \>  
        VOID / FORM  
      \</div\>

      {/\* Bottom right counter — adds editorial tension \*/}  
      \<div  
        style={{  
          position: 'absolute',  
          bottom: Math.round(height \* 0.072),  
          right: Math.round(width \* 0.055),  
          fontFamily: 'Inter, sans-serif',  
          fontSize: Math.max(9, Math.round(width \* 0.011)),  
          fontWeight: 300,  
          letterSpacing: '0.18em',  
          color: COLORS.accent,  
          opacity: labelOpacity \* 0.6,  
          zIndex: 10,  
          textTransform: 'uppercase',  
        }}  
      \>  
        01 / 01  
      \</div\>

      {/\* Bottom center thin line — grounding element \*/}  
      \<div  
        style={{  
          position: 'absolute',  
          bottom: Math.round(height \* 0.076),  
          left: '50%',  
          transform: 'translateX(-50%)',  
          width: Math.round(width \* 0.025),  
          height: 1,  
          background: COLORS.accentWarm,  
          opacity: labelOpacity \* 0.4,  
          zIndex: 10,  
        }}  
      /\>

    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D com 3 objetos onde fica claro sem dúvida qual é o principal, qual é o secundário e qual é o terciário.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import \* as THREE from "three";

/\* ─── Sub-components ─── \*/

const PrimaryOrb \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleSpring \= spring({ frame, fps, config: { damping: 14, stiffness: 80 } });  
  const floatY \= Math.sin(frame \* 0.04) \* 0.18;  
  const rotY \= frame \* 0.018;

  return (  
    \<mesh position={\[0, floatY, 0\]} scale={\[scaleSpring \* 2.2, scaleSpring \* 2.2, scaleSpring \* 2.2\]} rotation={\[0.3, rotY, 0\]}\>  
      \<icosahedronGeometry args={\[1, 3\]} /\>  
      \<meshStandardMaterial color="\#60A5FA" metalness={0.6} roughness={0.2} /\>  
    \</mesh\>  
  );  
};

const SecondaryOrb \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleSpring \= spring({ frame: Math.max(0, frame \- 18), fps, config: { damping: 12, stiffness: 70 } });  
  const angle \= frame \* 0.03 \+ Math.PI \* 0.5;  
  const radius \= 3.8;  
  const x \= Math.cos(angle) \* radius;  
  const z \= Math.sin(angle) \* radius \* 0.4;  
  const floatY \= Math.sin(frame \* 0.06 \+ 1.2) \* 0.1 \- 0.4;  
  const rotY \= frame \* 0.04;

  return (  
    \<mesh  
      position={\[x, floatY, z\]}  
      scale={\[scaleSpring \* 1.1, scaleSpring \* 1.1, scaleSpring \* 1.1\]}  
      rotation={\[0.2, rotY, 0.15\]}  
    \>  
      \<octahedronGeometry args={\[1, 0\]} /\>  
      \<meshStandardMaterial color="\#34D399" metalness={0.5} roughness={0.3} /\>  
    \</mesh\>  
  );  
};

const TertiaryOrb \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleSpring \= spring({ frame: Math.max(0, frame \- 36), fps, config: { damping: 10, stiffness: 60 } });  
  const angle \= frame \* 0.025 \- Math.PI \* 0.6;  
  const radius \= 5.2;  
  const x \= Math.cos(angle) \* radius \* 0.7;  
  const z \= Math.sin(angle) \* radius \* 0.25;  
  const floatY \= Math.sin(frame \* 0.05 \+ 2.5) \* 0.07 \+ 1.0;  
  const rotY \= \-frame \* 0.06;

  return (  
    \<mesh  
      position={\[x, floatY, z\]}  
      scale={\[scaleSpring \* 0.55, scaleSpring \* 0.55, scaleSpring \* 0.55\]}  
      rotation={\[0.4, rotY, \-0.2\]}  
    \>  
      \<tetrahedronGeometry args={\[1, 0\]} /\>  
      \<meshStandardMaterial color="\#A0A0A8" metalness={0.3} roughness={0.5} /\>  
    \</mesh\>  
  );  
};

/\* ─── Main export ─── \*/

export const MyAnimation \= () \=\> {  
  /\*  
   \* A three-tier 3D hierarchy: a large primary icosahedron in the center (blue),  
   \* a medium secondary octahedron orbiting it (green), and a tiny tertiary  
   \* tetrahedron floating at the edge (grey). Each entrance is staggered.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  /\* ── Tokens ── \*/  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    accent: "\#60A5FA",  
    secondary: "\#34D399",  
    tertiary: "\#A0A0A8",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
  };

  const TIMING \= { FADE\_IN: 20, LABEL\_DELAY: 30 };

  /\* ── Global fade in ── \*/  
  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\_IN\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  /\* ── Label animations ── \*/  
  const label1Opacity \= interpolate(frame, \[TIMING.LABEL\_DELAY, TIMING.LABEL\_DELAY \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const label2Opacity \= interpolate(frame, \[TIMING.LABEL\_DELAY \+ 18, TIMING.LABEL\_DELAY \+ 38\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const label3Opacity \= interpolate(frame, \[TIMING.LABEL\_DELAY \+ 36, TIMING.LABEL\_DELAY \+ 56\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const titleOpacity \= interpolate(frame, \[10, 35\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleY \= interpolate(frame, \[10, 35\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  /\* ── Font sizes ── \*/  
  const titleSize \= Math.max(28, Math.round(width \* 0.042));  
  const labelSize \= Math.max(11, Math.round(width \* 0.014));  
  const dotSize \= Math.max(8, Math.round(width \* 0.01));

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, \#0D0D2B 0%, ${COLORS.bg} 70%)\`,  
        opacity: globalOpacity,  
      }}  
    \>  
      {/\* ── 3D Canvas ── \*/}  
      \<ThreeCanvas  
        width={width}  
        height={height}  
        camera={{ position: \[0, 1.5, 10\], fov: 60 }}  
      \>  
        \<ambientLight intensity={0.35} /\>  
        \<directionalLight position={\[5, 8, 6\]} intensity={1.1} color="\#FFFFFF" /\>  
        \<pointLight position={\[-6, \-4, 4\]} intensity={0.6} color="\#60A5FA" /\>  
        \<pointLight position={\[6, 2, \-3\]} intensity={0.4} color="\#34D399" /\>

        \<PrimaryOrb frame={frame} fps={fps} /\>  
        \<SecondaryOrb frame={frame} fps={fps} /\>  
        \<TertiaryOrb frame={frame} fps={fps} /\>  
      \</ThreeCanvas\>

      {/\* ── Title ── \*/}  
      \<AbsoluteFill  
        style={{  
          pointerEvents: "none",  
          display: "flex",  
          flexDirection: "column",  
          alignItems: "center",  
          justifyContent: "flex-start",  
          paddingTop: Math.round(height \* 0.055),  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: titleSize,  
              fontWeight: 800,  
              letterSpacing: "-0.02em",  
              color: COLORS.text,  
              lineHeight: 1.1,  
            }}  
          \>  
            Hierarquia Visual 3D  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: Math.max(12, Math.round(width \* 0.016)),  
              fontWeight: 400,  
              letterSpacing: "0.06em",  
              color: COLORS.textMuted,  
              marginTop: 8,  
              textTransform: "uppercase",  
            }}  
          \>  
            Primário · Secundário · Terciário  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* ── Legend panel ── \*/}  
      \<AbsoluteFill  
        style={{  
          pointerEvents: "none",  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.06),  
        }}  
      \>  
        \<div  
          style={{  
            display: "flex",  
            gap: Math.round(width \* 0.04),  
            alignItems: "center",  
          }}  
        \>  
          {/\* Primary \*/}  
          \<div style={{ opacity: label1Opacity, display: "flex", alignItems: "center", gap: 10 }}\>  
            \<div  
              style={{  
                width: dotSize \* 2.4,  
                height: dotSize \* 2.4,  
                borderRadius: "50%",  
                background: COLORS.accent,  
                boxShadow: \`0 0 14px 4px ${COLORS.accent}88\`,  
              }}  
            /\>  
            \<div style={{ fontFamily: "Inter, sans-serif" }}\>  
              \<div style={{ fontSize: labelSize \* 1.15, fontWeight: 700, color: COLORS.text, letterSpacing: "-0.01em" }}\>  
                PRIMÁRIO  
              \</div\>  
              \<div style={{ fontSize: labelSize \* 0.9, fontWeight: 400, color: COLORS.textMuted, letterSpacing: "0.03em" }}\>  
                Grande · Icosaedro · Azul  
              \</div\>  
            \</div\>  
          \</div\>

          {/\* Divider \*/}  
          \<div style={{ width: 1, height: 32, background: "\#FFFFFF18" }} /\>

          {/\* Secondary \*/}  
          \<div style={{ opacity: label2Opacity, display: "flex", alignItems: "center", gap: 10 }}\>  
            \<div  
              style={{  
                width: dotSize \* 1.5,  
                height: dotSize \* 1.5,  
                borderRadius: "50%",  
                background: COLORS.secondary,  
                boxShadow: \`0 0 10px 3px ${COLORS.secondary}66\`,  
              }}  
            /\>  
            \<div style={{ fontFamily: "Inter, sans-serif" }}\>  
              \<div style={{ fontSize: labelSize \* 1.0, fontWeight: 600, color: COLORS.text, letterSpacing: "-0.01em" }}\>  
                SECUNDÁRIO  
              \</div\>  
              \<div style={{ fontSize: labelSize \* 0.85, fontWeight: 400, color: COLORS.textMuted, letterSpacing: "0.03em" }}\>  
                Médio · Octaedro · Verde  
              \</div\>  
            \</div\>  
          \</div\>

          {/\* Divider \*/}  
          \<div style={{ width: 1, height: 32, background: "\#FFFFFF18" }} /\>

          {/\* Tertiary \*/}  
          \<div style={{ opacity: label3Opacity, display: "flex", alignItems: "center", gap: 10 }}\>  
            \<div  
              style={{  
                width: dotSize,  
                height: dotSize,  
                borderRadius: "50%",  
                background: COLORS.tertiary,  
              }}  
            /\>  
            \<div style={{ fontFamily: "Inter, sans-serif" }}\>  
              \<div style={{ fontSize: labelSize \* 0.88, fontWeight: 500, color: COLORS.textMuted, letterSpacing: "-0.01em" }}\>  
                TERCIÁRIO  
              \</div\>  
              \<div style={{ fontSize: labelSize \* 0.78, fontWeight: 400, color: "\#6E6E76", letterSpacing: "0.03em" }}\>  
                Pequeno · Tetraedro · Cinza  
              \</div\>  
            \</div\>  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* ── Subtle vignette ── \*/}  
      \<AbsoluteFill  
        style={{  
          background: "radial-gradient(ellipse at 50% 50%, transparent 55%, rgba(5,5,16,0.65) 100%)",  
          pointerEvents: "none",  
          zIndex: 0,  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação onde um objeto 3D entra com energia e para em uma posição final precisa, como se houvesse um click de encaixe.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring, Easing } from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

/\*  
 \* A 3D metallic cube enters from the left with high energy, overshoots slightly,  
 \* then snaps precisely into the center with a satisfying "click" lock effect.  
 \* The scene uses a premium dark aesthetic with cinematic lighting and HUD overlays.  
 \*/

const SnapRing \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const snapFrame \= 42;  
  const ringScale \= spring({  
    frame: frame \- snapFrame,  
    fps,  
    config: { damping: 8, stiffness: 300 },  
  });  
  const ringOpacity \= interpolate(frame, \[snapFrame, snapFrame \+ 5, snapFrame \+ 25, snapFrame \+ 35\], \[0, 1, 1, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const scale \= interpolate(ringScale, \[0, 1\], \[0.4, 1.6\]);

  return (  
    \<mesh rotation={\[Math.PI / 2, 0, 0\]} scale={\[scale, scale, scale\]}\>  
      \<torusGeometry args={\[1.4, 0.04, 16, 100\]} /\>  
      \<meshStandardMaterial  
        color="\#60A5FA"  
        emissive="\#60A5FA"  
        emissiveIntensity={ringOpacity \* 2}  
        transparent  
        opacity={ringOpacity}  
      /\>  
    \</mesh\>  
  );  
};

const SnapRing2 \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const snapFrame \= 44;  
  const ringScale \= spring({  
    frame: frame \- snapFrame,  
    fps,  
    config: { damping: 6, stiffness: 250 },  
  });  
  const ringOpacity \= interpolate(frame, \[snapFrame, snapFrame \+ 4, snapFrame \+ 20, snapFrame \+ 32\], \[0, 0.7, 0.7, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const scale \= interpolate(ringScale, \[0, 1\], \[0.2, 2.2\]);

  return (  
    \<mesh rotation={\[Math.PI / 2, 0, 0\]} scale={\[scale, scale, scale\]}\>  
      \<torusGeometry args={\[1.4, 0.02, 16, 100\]} /\>  
      \<meshStandardMaterial  
        color="\#34D399"  
        emissive="\#34D399"  
        emissiveIntensity={ringOpacity \* 3}  
        transparent  
        opacity={ringOpacity \* 0.6}  
      /\>  
    \</mesh\>  
  );  
};

const MainCube \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  // Entry spring \- fast, energetic, slight overshoot  
  const entrySpring \= spring({  
    frame,  
    fps,  
    config: { damping: 9, stiffness: 180 },  
    durationInFrames: 55,  
  });

  // Snap correction spring \- tight, precise  
  const snapSpring \= spring({  
    frame: frame \- 38,  
    fps,  
    config: { damping: 200, stiffness: 400 },  
    durationInFrames: 20,  
  });

  const posX \= interpolate(entrySpring, \[0, 1\], \[-12, 0.18\]);  
  const snapCorrect \= interpolate(snapSpring, \[0, 1\], \[0, \-0.18\]);  
  const finalX \= posX \+ snapCorrect;

  const rotY \= interpolate(frame, \[0, 55, 60\], \[0.8, 0.1, 0\], {  
    easing: Easing.out(Easing.cubic),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const scaleSnap \= spring({  
    frame: frame \- 40,  
    fps,  
    config: { damping: 7, stiffness: 350 },  
  });  
  const scale \= interpolate(scaleSnap, \[0, 0.5, 1\], \[1, 0.88, 1\]);

  return (  
    \<mesh position={\[finalX, 0, 0\]} rotation={\[0.15, rotY, 0\]} scale={\[scale, scale, scale\]}\>  
      \<boxGeometry args={\[2, 2, 2\]} /\>  
      \<meshStandardMaterial  
        color="\#1A1A1E"  
        metalness={0.95}  
        roughness={0.1}  
        emissive="\#60A5FA"  
        emissiveIntensity={0.05}  
      /\>  
    \</mesh\>  
  );  
};

const EdgeGlow \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const snapFrame \= 42;  
  const glowIntensity \= spring({  
    frame: frame \- snapFrame,  
    fps,  
    config: { damping: 10, stiffness: 200 },  
  });  
  const fade \= interpolate(frame, \[snapFrame, snapFrame \+ 6, snapFrame \+ 30, snapFrame \+ 50\], \[0, 1, 1, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const emissive \= interpolate(glowIntensity, \[0, 1\], \[0, 1.5\]);

  return (  
    \<mesh position={\[0, 0, 0\]} scale={\[1.02, 1.02, 1.02\]}\>  
      \<boxGeometry args={\[2, 2, 2\]} /\>  
      \<meshStandardMaterial  
        color="\#60A5FA"  
        emissive="\#60A5FA"  
        emissiveIntensity={emissive \* fade}  
        transparent  
        opacity={0.12 \* fade}  
        wireframe  
      /\>  
    \</mesh\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* Metallic cube slides in from off-screen with spring physics, snaps to center  
   \* with a precise click-lock effect, emitting ring pulses and edge glow on arrival.  
   \* Premium dark aesthetic with HUD overlays and cinematic ambient lighting.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  // — Theme Tokens —  
  const COLORS \= {  
    bg: "\#000000",  
    surface1: "\#111113",  
    surface2: "\#1A1A1E",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#60A5FA",  
    accentGreen: "\#34D399",  
  };

  const TIMING \= { SNAP\_FRAME: 42, FADE\_IN: 15, HUD\_DELAY: 20 };  
  const BASE\_PADDING \= Math.round(width \* 0.04);

  // HUD Label fade  
  const hudOpacity \= interpolate(frame, \[TIMING.HUD\_DELAY, TIMING.HUD\_DELAY \+ 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const hudTranslate \= interpolate(frame, \[TIMING.HUD\_DELAY, TIMING.HUD\_DELAY \+ 20\], \[10, 0\], {  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Snap indicator  
  const snapOpacity \= interpolate(  
    frame,  
    \[TIMING.SNAP\_FRAME \- 2, TIMING.SNAP\_FRAME \+ 4, TIMING.SNAP\_FRAME \+ 30, TIMING.SNAP\_FRAME \+ 50\],  
    \[0, 1, 1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // Flash on snap  
  const flashOpacity \= interpolate(  
    frame,  
    \[TIMING.SNAP\_FRAME, TIMING.SNAP\_FRAME \+ 3, TIMING.SNAP\_FRAME \+ 10\],  
    \[0, 0.35, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // Scan line animation  
  const scanY \= interpolate(frame, \[0, 90\], \[0, height\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Status text  
  const status \= frame \< TIMING.SNAP\_FRAME ? "INCOMING" : "LOCKED";  
  const statusColor \= frame \< TIMING.SNAP\_FRAME ? COLORS.textMuted : COLORS.accentGreen;

  const fontSize \= Math.max(11, Math.round(width \* 0.011));  
  const titleSize \= Math.max(20, Math.round(width \* 0.026));

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Background radial \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 70% 60% at 50% 50%, \#0D1929 0%, \#000000 70%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* Grid lines \*/}  
      \<AbsoluteFill style={{ zIndex: 0, opacity: 0.25 }}\>  
        {\[...Array(9)\].map((\_, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              left: \`${(i \+ 1\) \* 10}%\`,  
              top: 0,  
              width: 1,  
              height: "100%",  
              background: \`linear-gradient(to bottom, transparent, ${COLORS.accent}33, transparent)\`,  
            }}  
          /\>  
        ))}  
        {\[...Array(5)\].map((\_, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              top: \`${(i \+ 1\) \* 16.66}%\`,  
              left: 0,  
              width: "100%",  
              height: 1,  
              background: \`linear-gradient(to right, transparent, ${COLORS.accent}22, transparent)\`,  
            }}  
          /\>  
        ))}  
      \</AbsoluteFill\>

      {/\* Scan line \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: scanY,  
          left: 0,  
          width: "100%",  
          height: 2,  
          background: \`linear-gradient(to right, transparent 0%, ${COLORS.accent}66 30%, ${COLORS.accent}AA 50%, ${COLORS.accent}66 70%, transparent 100%)\`,  
          zIndex: 0,  
          opacity: 0.5,  
        }}  
      /\>

      {/\* Three.js Scene \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 0, 7\], fov: 60 }}\>  
          \<ambientLight intensity={0.3} /\>  
          \<directionalLight position={\[5, 8, 5\]} intensity={1.2} color="\#FFFFFF" /\>  
          \<directionalLight position={\[-5, \-3, \-3\]} intensity={0.4} color="\#60A5FA" /\>  
          \<pointLight position={\[0, 0, 4\]} intensity={0.8} color="\#60A5FA" distance={10} /\>  
          \<pointLight position={\[3, 3, 2\]} intensity={0.5} color="\#FFFFFF" distance={8} /\>

          \<MainCube frame={frame} fps={fps} /\>  
          \<EdgeGlow frame={frame} fps={fps} /\>  
          \<SnapRing frame={frame} fps={fps} /\>  
          \<SnapRing2 frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Flash effect on snap \*/}  
      \<AbsoluteFill  
        style={{  
          background: COLORS.accent,  
          opacity: flashOpacity,  
          zIndex: 100,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* HUD — Top Left \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: BASE\_PADDING,  
          left: BASE\_PADDING,  
          opacity: hudOpacity,  
          transform: \`translateY(${hudTranslate}px)\`,  
          zIndex: 10,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: fontSize,  
            color: COLORS.textMuted,  
            letterSpacing: "0.15em",  
            textTransform: "uppercase",  
            marginBottom: 4,  
          }}  
        \>  
          OBJECT TRACKING  
        \</div\>  
        \<div  
          style={{  
            display: "flex",  
            alignItems: "center",  
            gap: 8,  
          }}  
        \>  
          \<div  
            style={{  
              width: 6,  
              height: 6,  
              borderRadius: "50%",  
              background: statusColor,  
              boxShadow: frame \>= TIMING.SNAP\_FRAME ? \`0 0 8px ${COLORS.accentGreen}\` : "none",  
            }}  
          /\>  
          \<div  
            style={{  
              fontFamily: "monospace",  
              fontSize: fontSize,  
              color: statusColor,  
              letterSpacing: "0.12em",  
              fontWeight: 700,  
            }}  
          \>  
            {status}  
          \</div\>  
        \</div\>  
      \</div\>

      {/\* HUD — Top Right \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: BASE\_PADDING,  
          right: BASE\_PADDING,  
          opacity: hudOpacity,  
          transform: \`translateY(${hudTranslate}px)\`,  
          zIndex: 10,  
          textAlign: "right",  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: fontSize,  
            color: COLORS.textMuted,  
            letterSpacing: "0.12em",  
          }}  
        \>  
          UNIT\_ID: 0xA3F7  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: fontSize,  
            color: COLORS.textMuted,  
            letterSpacing: "0.12em",  
            marginTop: 3,  
          }}  
        \>  
          CLASS: PRECISION-1  
        \</div\>  
      \</div\>

      {/\* Cross-hair center \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: "50%",  
          left: "50%",  
          transform: "translate(-50%, \-50%)",  
          width: Math.round(width \* 0.12),  
          height: Math.round(width \* 0.12),  
          zIndex: 2,  
          opacity: interpolate(frame, \[0, 20, TIMING.SNAP\_FRAME \+ 10, TIMING.SNAP\_FRAME \+ 30\], \[0, 0.5, 0.5, 0\], {  
            extrapolateLeft: "clamp",  
            extrapolateRight: "clamp",  
          }),  
        }}  
      \>  
        {/\* Corners \*/}  
        {\[  
          { top: 0, left: 0, borderTop: \`2px solid ${COLORS.accent}\`, borderLeft: \`2px solid ${COLORS.accent}\` },  
          { top: 0, right: 0, borderTop: \`2px solid ${COLORS.accent}\`, borderRight: \`2px solid ${COLORS.accent}\` },  
          { bottom: 0, left: 0, borderBottom: \`2px solid ${COLORS.accent}\`, borderLeft: \`2px solid ${COLORS.accent}\` },  
          { bottom: 0, right: 0, borderBottom: \`2px solid ${COLORS.accent}\`, borderRight: \`2px solid ${COLORS.accent}\` },  
        \].map((style, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              width: "20%",  
              height: "20%",  
              ...style,  
            }}  
          /\>  
        ))}  
      \</div\>

      {/\* SNAPPED indicator \*/}  
      \<div  
        style={{  
          position: "absolute",  
          top: "50%",  
          left: "50%",  
          transform: \`translate(-50%, ${Math.round(height \* 0.22)}px)\`,  
          opacity: snapOpacity,  
          zIndex: 10,  
          textAlign: "center",  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: Math.max(10, Math.round(width \* 0.009)),  
            color: COLORS.accentGreen,  
            letterSpacing: "0.3em",  
            fontWeight: 700,  
            textTransform: "uppercase",  
          }}  
        \>  
          ● POSITION LOCKED  
        \</div\>  
      \</div\>

      {/\* Bottom center title \*/}  
      \<div  
        style={{  
          position: "absolute",  
          bottom: BASE\_PADDING \* 1.5,  
          left: 0,  
          right: 0,  
          textAlign: "center",  
          zIndex: 10,  
          opacity: hudOpacity,  
        }}  
      \>  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: titleSize,  
            fontWeight: 800,  
            color: COLORS.text,  
            letterSpacing: "-0.02em",  
            lineHeight: 1.1,  
          }}  
        \>  
          SNAP TO PRECISION  
        \</div\>  
        \<div  
          style={{  
            fontFamily: "monospace",  
            fontSize: Math.max(10, Math.round(width \* 0.01)),  
            color: COLORS.textMuted,  
            letterSpacing: "0.2em",  
            marginTop: 6,  
          }}  
        \>  
          ZERO-TOLERANCE ALIGNMENT SYSTEM  
        \</div\>  
      \</div\>

      {/\* Corner decorators \*/}  
      {\[  
        { bottom: BASE\_PADDING, left: BASE\_PADDING },  
        { bottom: BASE\_PADDING, right: BASE\_PADDING },  
      \].map((pos, i) \=\> (  
        \<div  
          key={i}  
          style={{  
            position: "absolute",  
            width: Math.round(width \* 0.025),  
            height: Math.round(width \* 0.025),  
            borderBottom: \`1px solid ${COLORS.accent}66\`,  
            borderLeft: i \=== 0 ? \`1px solid ${COLORS.accent}66\` : undefined,  
            borderRight: i \=== 1 ? \`1px solid ${COLORS.accent}66\` : undefined,  
            opacity: hudOpacity,  
            zIndex: 10,  
            ...pos,  
          }}  
        /\>  
      ))}  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D com 4 elementos que entram em tempos diferentes, criando um ritmo como numa peça musical — não em compasso regular.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import \* as THREE from "three";

/\*  
  Four 3D elements enter with irregular, musical timing —   
  like syncopated beats in jazz, not a metronome.  
  Each shape has its own personality: entry curve, color, and motion signature.  
\*/

const FloatingBox \= ({  
  frame,  
  fps,  
  entryFrame,  
  color,  
  emissive,  
  position,  
  rotationSpeed,  
  floatAmp,  
  floatFreq,  
  geometry \= "box",  
}: {  
  frame: number;  
  fps: number;  
  entryFrame: number;  
  color: string;  
  emissive: string;  
  position: \[number, number, number\];  
  rotationSpeed: \[number, number, number\];  
  floatAmp: number;  
  floatFreq: number;  
  geometry?: "box" | "sphere" | "torus" | "octahedron";  
}) \=\> {  
  const localFrame \= Math.max(0, frame \- entryFrame);

  const scaleSpring \= spring({  
    frame: localFrame,  
    fps,  
    config: { damping: 10, stiffness: 80 },  
    durationInFrames: 45,  
  });

  const floatY \= Math.sin(frame \* floatFreq) \* floatAmp;  
  const floatX \= Math.cos(frame \* floatFreq \* 0.7) \* floatAmp \* 0.4;

  const rotX \= frame \* rotationSpeed\[0\];  
  const rotY \= frame \* rotationSpeed\[1\];  
  const rotZ \= frame \* rotationSpeed\[2\];

  const opacity \= interpolate(localFrame, \[0, 20\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  const s \= scaleSpring;

  return (  
    \<mesh  
      position={\[position\[0\] \+ floatX, position\[1\] \+ floatY, position\[2\]\]}  
      rotation={\[rotX, rotY, rotZ\]}  
      scale={\[s, s, s\]}  
    \>  
      {geometry \=== "box" && \<boxGeometry args={\[1.2, 1.2, 1.2\]} /\>}  
      {geometry \=== "sphere" && \<sphereGeometry args={\[0.75, 32, 32\]} /\>}  
      {geometry \=== "torus" && \<torusGeometry args={\[0.6, 0.25, 16, 60\]} /\>}  
      {geometry \=== "octahedron" && \<octahedronGeometry args={\[0.85\]} /\>}  
      \<meshStandardMaterial  
        color={color}  
        emissive={emissive}  
        emissiveIntensity={0.35}  
        roughness={0.25}  
        metalness={0.7}  
        transparent  
        opacity={opacity}  
      /\>  
    \</mesh\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
    A 3D musical composition: four geometric shapes enter at  
    irregular rhythmic intervals — timed like a jazz syncopation,  
    building tension and release across the full duration.  
  \*/  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  // ─── THEME & TOKENS ───────────────────────────────────────────  
  const THEME \= { archetype: "neon\_glow", pacing: "syncopated" };  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    accent1: "\#00FF88",  
    accent2: "\#00AAFF",  
    accent3: "\#FF6B35",  
    accent4: "\#BF5FFF",  
    textMuted: "\#4A4A6A",  
  };  
  const TIMING \= {  
    // Musical "bars" at \~24fps feel — irregular syncopation  
    BEAT1: 0,    // Downbeat — first hit  
    BEAT2: 28,   // Syncopated early (off the expected 30\)  
    BEAT3: 62,   // Late — tension before resolution  
    BEAT4: 79,   // Quick answer to beat 3  
    TOTAL: 180,  
  };

  // ─── GLOBAL MOTION ────────────────────────────────────────────  
  const cameraZ \= interpolate(frame, \[0, TIMING.TOTAL\], \[7, 5.5\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.45, 0, 0.55, 1),  
  });

  const breathe \= Math.sin(frame \* 0.018) \* 0.12;

  // ─── BACKGROUND PULSE ─────────────────────────────────────────  
  const bgPulse \= interpolate(  
    Math.sin(frame \* 0.04),  
    \[-1, 1\],  
    \[0, 0.03\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // ─── LABEL TIMING ─────────────────────────────────────────────  
  const label1Opacity \= interpolate(frame, \[TIMING.BEAT1, TIMING.BEAT1 \+ 18\], \[0, 1\], {  
    extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic),  
  });  
  const label2Opacity \= interpolate(frame, \[TIMING.BEAT2, TIMING.BEAT2 \+ 18\], \[0, 1\], {  
    extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic),  
  });  
  const label3Opacity \= interpolate(frame, \[TIMING.BEAT3, TIMING.BEAT3 \+ 18\], \[0, 1\], {  
    extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic),  
  });  
  const label4Opacity \= interpolate(frame, \[TIMING.BEAT4, TIMING.BEAT4 \+ 18\], \[0, 1\], {  
    extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.cubic),  
  });

  // Title fade  
  const titleOpacity \= interpolate(frame, \[0, 25\], \[0, 1\], {  
    extrapolateLeft: "clamp", extrapolateRight: "clamp",  
  });

  // Beat indicator animations  
  const beatIndicators \= \[  
    TIMING.BEAT1, TIMING.BEAT2, TIMING.BEAT3, TIMING.BEAT4,  
  \].map((beat) \=\> {  
    const pulse \= interpolate(  
      frame,  
      \[beat, beat \+ 8, beat \+ 24\],  
      \[0, 1, 0\],  
      { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
    );  
    return pulse;  
  });

  const BASE\_FONT \= Math.max(11, Math.round(width \* 0.012));  
  const TITLE\_FONT \= Math.max(18, Math.round(width \* 0.022));

  return (  
    \<AbsoluteFill  
      style={{  
        background: \`radial-gradient(ellipse at 50% 40%, rgba(20,10,50,${0.9 \+ bgPulse}) 0%, ${COLORS.bg} 70%)\`,  
      }}  
    \>  
      {/\* Ambient grid overlay \*/}  
      \<AbsoluteFill  
        style={{  
          backgroundImage: \`  
            linear-gradient(rgba(0,255,136,0.03) 1px, transparent 1px),  
            linear-gradient(90deg, rgba(0,255,136,0.03) 1px, transparent 1px)  
          \`,  
          backgroundSize: "60px 60px",  
          zIndex: 0,  
        }}  
      /\>

      {/\* 3D Canvas \*/}  
      \<AbsoluteFill style={{ zIndex: 1 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0 \+ breathe \* 0.5, cameraZ\], fov: 60 }}  
        \>  
          \<ambientLight intensity={0.3} /\>  
          \<pointLight position={\[5, 5, 5\]} intensity={1.2} color="\#ffffff" /\>  
          \<pointLight position={\[-4, \-3, 3\]} intensity={0.8} color="\#4455ff" /\>  
          \<pointLight position={\[3, \-4, 2\]} intensity={0.6} color="\#ff4455" /\>

          {/\* BEAT 1 — Cube, downbeat anchor \*/}  
          \<FloatingBox  
            frame={frame}  
            fps={fps}  
            entryFrame={TIMING.BEAT1}  
            color={COLORS.accent1}  
            emissive="\#003322"  
            position={\[-2.2, 0.8, 0\]}  
            rotationSpeed={\[0.008, 0.015, 0.003\]}  
            floatAmp={0.12}  
            floatFreq={0.025}  
            geometry="box"  
          /\>

          {/\* BEAT 2 — Sphere, early syncopation \*/}  
          \<FloatingBox  
            frame={frame}  
            fps={fps}  
            entryFrame={TIMING.BEAT2}  
            color={COLORS.accent2}  
            emissive="\#002244"  
            position={\[2.0, 1.0, \-0.3\]}  
            rotationSpeed={\[0.012, 0.006, 0.009\]}  
            floatAmp={0.18}  
            floatFreq={0.019}  
            geometry="sphere"  
          /\>

          {/\* BEAT 3 — Torus, late tension \*/}  
          \<FloatingBox  
            frame={frame}  
            fps={fps}  
            entryFrame={TIMING.BEAT3}  
            color={COLORS.accent3}  
            emissive="\#331500"  
            position={\[-1.8, \-1.2, 0.2\]}  
            rotationSpeed={\[0.02, 0.01, 0.015\]}  
            floatAmp={0.14}  
            floatFreq={0.031}  
            geometry="torus"  
          /\>

          {/\* BEAT 4 — Octahedron, quick answer \*/}  
          \<FloatingBox  
            frame={frame}  
            fps={fps}  
            entryFrame={TIMING.BEAT4}  
            color={COLORS.accent4}  
            emissive="\#220033"  
            position={\[2.1, \-1.1, \-0.1\]}  
            rotationSpeed={\[0.006, 0.018, 0.012\]}  
            floatAmp={0.1}  
            floatFreq={0.022}  
            geometry="octahedron"  
          /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* ─── HUD LABELS ─────────────────────────────── \*/}  
      \<AbsoluteFill style={{ zIndex: 5, pointerEvents: "none" }}\>

        {/\* Title \*/}  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.06),  
            left: "50%",  
            transform: "translateX(-50%)",  
            opacity: titleOpacity,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: TITLE\_FONT,  
              fontWeight: 300,  
              letterSpacing: "0.25em",  
              color: "rgba(255,255,255,0.55)",  
              textTransform: "uppercase",  
            }}  
          \>  
            Syncopation  
          \</div\>  
        \</div\>

        {/\* Beat indicators — bottom timeline \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.07),  
            left: "50%",  
            transform: "translateX(-50%)",  
            display: "flex",  
            gap: Math.round(width \* 0.025),  
            alignItems: "center",  
          }}  
        \>  
          {\[  
            { color: COLORS.accent1, label: "I", beat: 0 },  
            { color: COLORS.accent2, label: "II", beat: 1 },  
            { color: COLORS.accent3, label: "III", beat: 2 },  
            { color: COLORS.accent4, label: "IV", beat: 3 },  
          \].map((item, i) \=\> {  
            const pulse \= beatIndicators\[i\];  
            const labelOpacities \= \[label1Opacity, label2Opacity, label3Opacity, label4Opacity\];  
            return (  
              \<div  
                key={i}  
                style={{  
                  display: "flex",  
                  flexDirection: "column",  
                  alignItems: "center",  
                  gap: 6,  
                  opacity: labelOpacities\[i\],  
                }}  
              \>  
                \<div  
                  style={{  
                    fontFamily: "Inter, sans-serif",  
                    fontSize: BASE\_FONT,  
                    fontWeight: 400,  
                    letterSpacing: "0.1em",  
                    color: item.color,  
                    textTransform: "uppercase",  
                  }}  
                \>  
                  {item.label}  
                \</div\>  
                \<div  
                  style={{  
                    width: Math.round(width \* 0.012),  
                    height: Math.round(width \* 0.012),  
                    borderRadius: "50%",  
                    background: item.color,  
                    boxShadow: \`0 0 ${4 \+ pulse \* 14}px ${pulse \* 6}px ${item.color}88\`,  
                    transform: \`scale(${0.8 \+ pulse \* 0.5})\`,  
                    transition: "none",  
                  }}  
                /\>  
              \</div\>  
            );  
          })}  
        \</div\>

        {/\* Beat timing markers — subtle left rail \*/}  
        \<div  
          style={{  
            position: "absolute",  
            left: Math.round(width \* 0.04),  
            top: "50%",  
            transform: "translateY(-50%)",  
            display: "flex",  
            flexDirection: "column",  
            gap: Math.round(height \* 0.02),  
          }}  
        \>  
          {\[  
            { label: "0f", color: COLORS.accent1, opacity: label1Opacity },  
            { label: "28f", color: COLORS.accent2, opacity: label2Opacity },  
            { label: "62f", color: COLORS.accent3, opacity: label3Opacity },  
            { label: "79f", color: COLORS.accent4, opacity: label4Opacity },  
          \].map((item, i) \=\> (  
            \<div  
              key={i}  
              style={{  
                display: "flex",  
                alignItems: "center",  
                gap: 8,  
                opacity: item.opacity \* 0.6,  
              }}  
            \>  
              \<div  
                style={{  
                  width: 20,  
                  height: 1,  
                  background: item.color,  
                }}  
              /\>  
              \<span  
                style={{  
                  fontFamily: "Inter, monospace",  
                  fontSize: Math.max(9, Math.round(width \* 0.009)),  
                  color: item.color,  
                  letterSpacing: "0.05em",  
                  fontWeight: 500,  
                }}  
              \>  
                {item.label}  
              \</span\>  
            \</div\>  
          ))}  
        \</div\>

      \</AbsoluteFill\>

      {/\* Vignette \*/}  
      \<AbsoluteFill  
        style={{  
          background: "radial-gradient(ellipse at 50% 50%, transparent 50%, rgba(5,5,16,0.7) 100%)",  
          zIndex: 6,  
          pointerEvents: "none",  
        }}  
      /\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

\`\`\`  
Crie uma animação 3D que parece ser observada por alguém de baixo para cima, com o objeto dominando o frame — como olhar para um arranha-céu.  
\`\`\`

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";

// Skyscraper-like 3D structure viewed from below, looking up  
// The camera is positioned at ground level looking upward at a towering structure  
// Strong perspective distortion gives the illusion of massive vertical scale

const SkyscraperMesh: React.FC\<{ frame: number; fps: number }\> \= ({  
  frame,  
  fps,  
}) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 60 },  
  });

  const slowRotation \= frame \* 0.004;  
  const floatY \= Math.sin(frame \* 0.025) \* 0.08;

  const floors \= 18;  
  const floorHeight \= 0.55;  
  const totalHeight \= floors \* floorHeight;

  return (  
    \<\>  
      {/\* Ambient \+ directional lights for dramatic top-lit look \*/}  
      \<ambientLight intensity={0.15} color="\#1a2a6c" /\>  
      \<directionalLight  
        position={\[0, 20, 5\]}  
        intensity={1.4}  
        color="\#b8d4ff"  
      /\>  
      \<pointLight position={\[-4, 8, 2\]} intensity={0.6} color="\#4466ff" /\>  
      \<pointLight position={\[4, 12, \-2\]} intensity={0.4} color="\#88aaff" /\>  
      \<pointLight position={\[0, \-2, 6\]} intensity={0.3} color="\#ff9944" /\>

      {/\* Main tower group \*/}  
      \<group  
        rotation={\[0, slowRotation, 0\]}  
        position={\[0, floatY \- 2.5, 0\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        {/\* Main rectangular core \*/}  
        \<mesh position={\[0, totalHeight / 2, 0\]}\>  
          \<boxGeometry args={\[1.6, totalHeight, 1.6\]} /\>  
          \<meshStandardMaterial  
            color="\#1a2444"  
            metalness={0.85}  
            roughness={0.15}  
          /\>  
        \</mesh\>

        {/\* Floor slabs / horizontal bands \*/}  
        {Array.from({ length: floors }).map((\_, i) \=\> {  
          const y \= i \* floorHeight \+ floorHeight \* 0.5;  
          const widthScale \= 1.0 \- i \* 0.012;  
          return (  
            \<mesh key={i} position={\[0, y, 0\]}\>  
              \<boxGeometry  
                args={\[  
                  1.7 \* widthScale,  
                  0.06,  
                  1.7 \* widthScale,  
                \]}  
              /\>  
              \<meshStandardMaterial  
                color="\#334477"  
                metalness={0.9}  
                roughness={0.1}  
              /\>  
            \</mesh\>  
          );  
        })}

        {/\* Wing structures on the sides \*/}  
        \<mesh position={\[1.1, totalHeight \* 0.35, 0\]}\>  
          \<boxGeometry args={\[0.5, totalHeight \* 0.55, 0.9\]} /\>  
          \<meshStandardMaterial  
            color="\#0f1a33"  
            metalness={0.8}  
            roughness={0.2}  
          /\>  
        \</mesh\>  
        \<mesh position={\[-1.1, totalHeight \* 0.35, 0\]}\>  
          \<boxGeometry args={\[0.5, totalHeight \* 0.55, 0.9\]} /\>  
          \<meshStandardMaterial  
            color="\#0f1a33"  
            metalness={0.8}  
            roughness={0.2}  
          /\>  
        \</mesh\>

        {/\* Mid setback \*/}  
        \<mesh position={\[0, totalHeight \* 0.62, 0\]}\>  
          \<boxGeometry args={\[1.3, totalHeight \* 0.25, 1.3\]} /\>  
          \<meshStandardMaterial  
            color="\#1c2e55"  
            metalness={0.9}  
            roughness={0.12}  
          /\>  
        \</mesh\>

        {/\* Spire \*/}  
        \<mesh position={\[0, totalHeight \+ 1.1, 0\]}\>  
          \<coneGeometry args={\[0.12, 2.2, 8\]} /\>  
          \<meshStandardMaterial  
            color="\#99bbff"  
            metalness={1.0}  
            roughness={0.05}  
            emissive="\#3366cc"  
            emissiveIntensity={0.3}  
          /\>  
        \</mesh\>

        {/\* Antenna tip glow \*/}  
        \<mesh position={\[0, totalHeight \+ 2.25, 0\]}\>  
          \<sphereGeometry args={\[0.055, 8, 8\]} /\>  
          \<meshStandardMaterial  
            color="\#ff4444"  
            emissive="\#ff2200"  
            emissiveIntensity={2}  
          /\>  
        \</mesh\>

        {/\* Ground base plaza \*/}  
        \<mesh position={\[0, \-0.12, 0\]}\>  
          \<boxGeometry args={\[3.2, 0.2, 3.2\]} /\>  
          \<meshStandardMaterial  
            color="\#0a0f1e"  
            metalness={0.5}  
            roughness={0.4}  
          /\>  
        \</mesh\>  
      \</group\>

      {/\* Atmospheric particles — distant buildings \*/}  
      {\[-5, \-3.5, 3, 5\].map((x, i) \=\> (  
        \<mesh key={\`bldg-${i}\`} position={\[x, \-1.5, \-4 \- i \* 0.5\]}\>  
          \<boxGeometry args={\[0.6, 3 \+ i \* 0.8, 0.6\]} /\>  
          \<meshStandardMaterial  
            color="\#0d1525"  
            metalness={0.7}  
            roughness={0.3}  
            transparent  
            opacity={0.7}  
          /\>  
        \</mesh\>  
      ))}  
    \</\>  
  );  
};

export const MyAnimation \= () \=\> {  
  /\*  
   \* A dramatic low-angle 3D skyscraper view — as if standing at the base  
   \* and looking up at a massive glass-and-steel tower dominating the skyline.  
   \* The camera perspective is tilted upward to create vertigo-inducing scale.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // Design archetype: NEON/GLOW — urban night skyline  
  const COLORS \= {  
    bg: "\#020510",  
    sky1: "\#010210",  
    sky2: "\#0a1535",  
    sky3: "\#1a2a6c",  
    accent: "\#4488ff",  
    glow: "\#0044ff",  
    fog: "\#0a1535",  
  };

  const TEXT \= {  
    headline: "SKYSCRAPER",  
    sub: "LOOK UP",  
    tag: "CITY OF TOMORROW",  
  };

  const TIMING \= { BASE: fps \* 0.5, FADE: fps \* 1 };

  const progress \= frame / durationInFrames;

  // Overall fade in  
  const globalOpacity \= interpolate(frame, \[0, TIMING.FADE\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // Text entrance  
  const headlineY \= interpolate(  
    frame,  
    \[fps \* 1.2, fps \* 2\],  
    \[40, 0\],  
    {  
      extrapolateLeft: "clamp",  
      extrapolateRight: "clamp",  
      easing: Easing.out(Easing.bezier(0.16, 1, 0.3, 1)),  
    }  
  );  
  const headlineOpacity \= interpolate(  
    frame,  
    \[fps \* 1.2, fps \* 2\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const subOpacity \= interpolate(  
    frame,  
    \[fps \* 1.8, fps \* 2.6\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  const tagOpacity \= interpolate(  
    frame,  
    \[fps \* 2.4, fps \* 3.2\],  
    \[0, 1\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // Atmospheric fog fade at bottom  
  const fogOpacity \= 0.65;

  // Subtle vignette pulse  
  const vignettePulse \= 0.7 \+ Math.sin(frame \* 0.03) \* 0.05;

  const baseFontSize \= Math.max(28, Math.round(width \* 0.09));  
  const subFontSize \= Math.max(12, Math.round(width \* 0.022));  
  const tagFontSize \= Math.max(10, Math.round(width \* 0.016));

  return (  
    \<AbsoluteFill  
      style={{  
        background: COLORS.bg,  
        opacity: globalOpacity,  
        overflow: "hidden",  
      }}  
    \>  
      {/\* Sky gradient background \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse at 50% 100%, ${COLORS.sky3} 0%, ${COLORS.sky2} 35%, ${COLORS.sky1} 70%, ${COLORS.bg} 100%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* Stars layer \*/}  
      \<AbsoluteFill style={{ zIndex: 1, overflow: "hidden" }}\>  
        {\[...Array(32)\].map((\_, i) \=\> {  
          const px \= ((i \* 137.508) % 100).toFixed(2);  
          const py \= ((i \* 89.3) % 55).toFixed(2);  
          const size \= 1 \+ (i % 3\) \* 0.5;  
          const twinkle \=  
            0.4 \+ 0.6 \* Math.abs(Math.sin(frame \* 0.04 \+ i \* 0.7));  
          return (  
            \<div  
              key={i}  
              style={{  
                position: "absolute",  
                left: \`${px}%\`,  
                top: \`${py}%\`,  
                width: size,  
                height: size,  
                borderRadius: "50%",  
                background: "\#ffffff",  
                opacity: twinkle \* 0.8,  
              }}  
            /\>  
          );  
        })}  
      \</AbsoluteFill\>

      {/\* 3D Canvas \- low angle camera looking up \*/}  
      \<AbsoluteFill style={{ zIndex: 2 }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{  
            position: \[0, \-3.5, 7\],  
            fov: 72,  
            rotation: \[0.38, 0, 0\],  
          }}  
        \>  
          \<SkyscraperMesh frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* Bottom atmospheric fog \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 3,  
          background: \`linear-gradient(to top, ${COLORS.fog}ee 0%, ${COLORS.fog}88 15%, transparent 40%)\`,  
          opacity: fogOpacity,  
        }}  
      /\>

      {/\* Vignette overlay \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 4,  
          background: \`radial-gradient(ellipse at 50% 50%, transparent 40%, rgba(0,0,0,${vignettePulse}) 100%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Horizontal accent lines \*/}  
      \<AbsoluteFill style={{ zIndex: 5, pointerEvents: "none" }}\>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.16),  
            left: 0,  
            right: 0,  
            height: 1,  
            background: \`linear-gradient(to right, transparent, ${COLORS.accent}66, transparent)\`,  
            opacity: tagOpacity,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* Text: LOOK UP — top left \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 6,  
          padding: Math.round(width \* 0.04),  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.07),  
            left: Math.round(width \* 0.05),  
            opacity: subOpacity,  
            display: "flex",  
            flexDirection: "column",  
            gap: 4,  
          }}  
        \>  
          \<div  
            style={{  
              width: 32,  
              height: 2,  
              background: COLORS.accent,  
              marginBottom: 8,  
            }}  
          /\>  
          \<span  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: subFontSize,  
              fontWeight: 300,  
              letterSpacing: "0.35em",  
              color: COLORS.accent,  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.sub}  
          \</span\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* Main headline — bottom \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 6,  
          pointerEvents: "none",  
        }}  
      \>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.18),  
            left: Math.round(width \* 0.05),  
            right: Math.round(width \* 0.05),  
            opacity: headlineOpacity,  
            transform: \`translateY(${headlineY}px)\`,  
          }}  
        \>  
          \<h1  
            style={{  
              margin: 0,  
              fontFamily: "Inter, sans-serif",  
              fontSize: baseFontSize,  
              fontWeight: 900,  
              letterSpacing: "-0.02em",  
              lineHeight: 1.0,  
              color: "transparent",  
              background: \`linear-gradient(180deg, \#ffffff 0%, \#aaccff 60%, ${COLORS.accent} 100%)\`,  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
              backgroundClip: "text",  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.headline}  
          \</h1\>  
        \</div\>

        {/\* Tagline \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.12),  
            left: Math.round(width \* 0.05),  
            opacity: tagOpacity,  
            display: "flex",  
            alignItems: "center",  
            gap: 12,  
          }}  
        \>  
          \<span  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: tagFontSize,  
              fontWeight: 400,  
              letterSpacing: "0.25em",  
              color: "\#6688bb",  
              textTransform: "uppercase",  
            }}  
          \>  
            {TEXT.tag}  
          \</span\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D onde o objeto principal não está no centro da tela — a composição usa a regra dos terços para criar tensão visual.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import \* as THREE from "three";

/\* Floating geometric cluster positioned at rule-of-thirds intersection \*/  
const GeometricCluster \= ({ frame, fps }: { frame: number; fps: number }) \=\> {  
  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 14, stiffness: 80 },  
  });

  const rotY \= frame \* 0.018;  
  const rotX \= frame \* 0.009;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.18;  
  const floatZ \= Math.cos(frame \* 0.03) \* 0.1;

  const accentRotY \= frame \* \-0.03;  
  const accentRotX \= frame \* 0.022;

  const ringRot \= frame \* 0.025;

  return (  
    \<\>  
      {/\* Ambient \+ directional lighting \*/}  
      \<ambientLight intensity={0.15} /\>  
      \<directionalLight position={\[6, 8, 5\]} intensity={1.1} color="\#ffffff" /\>  
      \<directionalLight position={\[-4, \-3, \-2\]} intensity={0.4} color="\#60A5FA" /\>  
      \<pointLight position={\[3, 4, 6\]} intensity={1.8} color="\#34D399" distance={20} /\>  
      \<pointLight position={\[-5, 2, 3\]} intensity={0.9} color="\#60A5FA" distance={15} /\>

      {/\* Main icosahedron — positioned at right 1/3 intersection \*/}  
      \<group  
        position={\[2.4, 0.8 \+ floatY, floatZ\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
        rotation={\[rotX, rotY, 0\]}  
      \>  
        \<mesh\>  
          \<icosahedronGeometry args={\[1.1, 1\]} /\>  
          \<meshStandardMaterial  
            color="\#1A1A1E"  
            metalness={0.9}  
            roughness={0.08}  
            envMapIntensity={1}  
          /\>  
        \</mesh\>  
        {/\* Wireframe overlay \*/}  
        \<mesh\>  
          \<icosahedronGeometry args={\[1.13, 1\]} /\>  
          \<meshBasicMaterial  
            color="\#34D399"  
            wireframe  
            transparent  
            opacity={0.35}  
          /\>  
        \</mesh\>  
      \</group\>

      {/\* Accent octahedron — upper-left third \*/}  
      \<group  
        position={\[-2.8, 1.6 \+ Math.sin(frame \* 0.055) \* 0.22, \-0.5\]}  
        scale={\[scaleProgress \* 0.42, scaleProgress \* 0.42, scaleProgress \* 0.42\]}  
        rotation={\[accentRotX, accentRotY, frame \* 0.015\]}  
      \>  
        \<mesh\>  
          \<octahedronGeometry args={\[1, 0\]} /\>  
          \<meshStandardMaterial  
            color="\#0E1625"  
            metalness={0.95}  
            roughness={0.05}  
          /\>  
        \</mesh\>  
        \<mesh\>  
          \<octahedronGeometry args={\[1.05, 0\]} /\>  
          \<meshBasicMaterial  
            color="\#60A5FA"  
            wireframe  
            transparent  
            opacity={0.55}  
          /\>  
        \</mesh\>  
      \</group\>

      {/\* Toroidal ring orbiting main object \*/}  
      \<group  
        position={\[2.4, 0.8 \+ floatY, floatZ\]}  
        rotation={\[Math.PI / 3, ringRot, 0.3\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<mesh\>  
          \<torusGeometry args={\[1.65, 0.035, 12, 80\]} /\>  
          \<meshStandardMaterial  
            color="\#34D399"  
            metalness={0.6}  
            roughness={0.2}  
            emissive="\#34D399"  
            emissiveIntensity={0.4}  
          /\>  
        \</mesh\>  
      \</group\>

      {/\* Second ring at different angle \*/}  
      \<group  
        position={\[2.4, 0.8 \+ floatY, floatZ\]}  
        rotation={\[-Math.PI / 5, ringRot \* 0.7, 0.9\]}  
        scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
      \>  
        \<mesh\>  
          \<torusGeometry args={\[1.85, 0.022, 10, 80\]} /\>  
          \<meshStandardMaterial  
            color="\#60A5FA"  
            metalness={0.6}  
            roughness={0.2}  
            emissive="\#60A5FA"  
            emissiveIntensity={0.25}  
            transparent  
            opacity={0.7}  
          /\>  
        \</mesh\>  
      \</group\>

      {/\* Tiny floating satellites \*/}  
      {\[0, 1, 2, 3, 4\].map((i) \=\> {  
        const angle \= (i / 5\) \* Math.PI \* 2 \+ frame \* 0.02;  
        const radius \= 2.3;  
        const sx \= 2.4 \+ Math.cos(angle) \* radius;  
        const sy \= 0.8 \+ Math.sin(angle \* 0.5) \* 0.4;  
        const sz \= Math.sin(angle) \* radius \* 0.5;  
        const sc \= scaleProgress \* (0.06 \+ i \* 0.015);  
        return (  
          \<mesh key={i} position={\[sx, sy, sz\]} scale={\[sc, sc, sc\]}\>  
            \<octahedronGeometry args={\[1, 0\]} /\>  
            \<meshStandardMaterial  
              color={i % 2 \=== 0 ? "\#34D399" : "\#60A5FA"}  
              emissive={i % 2 \=== 0 ? "\#34D399" : "\#60A5FA"}  
              emissiveIntensity={0.9}  
              metalness={0.5}  
              roughness={0.2}  
            /\>  
          \</mesh\>  
        );  
      })}

      {/\* Ground-plane reflection hint \*/}  
      \<mesh position={\[0, \-2.5, 0\]} rotation={\[-Math.PI / 2, 0, 0\]}\>  
        \<planeGeometry args={\[20, 20\]} /\>  
        \<meshStandardMaterial  
          color="\#050810"  
          metalness={0.1}  
          roughness={0.9}  
          transparent  
          opacity={0.6}  
        /\>  
      \</mesh\>  
    \</\>  
  );  
};

export const ThirdRuleAnimation \= () \=\> {  
  /\*  
   \* A cinematic 3D composition using the rule of thirds to place the main  
   \* geometric subject off-center, creating visual tension and depth.  
   \* Typography anchors the left third while the 3D object commands the right.  
   \*/  
  const frame \= useCurrentFrame();  
  const { width, height, fps, durationInFrames } \= useVideoConfig();

  // ─── THEME ────────────────────────────────────────────────────────────────  
  const COLORS \= {  
    bg: "\#020408",  
    surface1: "\#060C14",  
    surface2: "\#0D1520",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent: "\#34D399",  
    accentBlue: "\#60A5FA",  
  };  
  const TIMING \= { INTRO: 18, STAGGER: 10, FADE: 25 };

  // ─── GRID LINES (rule of thirds) ──────────────────────────────────────────  
  const gridOpacity \= interpolate(frame, \[0, TIMING.INTRO \+ 30, TIMING.INTRO \+ 60\], \[0, 0.08, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  // ─── TEXT ANIMATIONS ──────────────────────────────────────────────────────  
  const line1Enter \= spring({ frame: Math.max(0, frame \- TIMING.INTRO), fps, config: { damping: 16, stiffness: 90 } });  
  const line2Enter \= spring({ frame: Math.max(0, frame \- TIMING.INTRO \- TIMING.STAGGER), fps, config: { damping: 16, stiffness: 90 } });  
  const line3Enter \= spring({ frame: Math.max(0, frame \- TIMING.INTRO \- TIMING.STAGGER \* 2), fps, config: { damping: 16, stiffness: 90 } });  
  const subtitleEnter \= spring({ frame: Math.max(0, frame \- TIMING.INTRO \- TIMING.STAGGER \* 3.5), fps, config: { damping: 18, stiffness: 70 } });

  const tagEnter \= spring({ frame: Math.max(0, frame \- TIMING.INTRO \- TIMING.STAGGER \* 5), fps, config: { damping: 20, stiffness: 60 } });

  const globalFadeOut \= interpolate(  
    frame,  
    \[durationInFrames \- TIMING.FADE, durationInFrames\],  
    \[1, 0\],  
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }  
  );

  // ─── FONT SIZES ───────────────────────────────────────────────────────────  
  const titleSize \= Math.max(36, Math.round(width \* 0.062));  
  const subtitleSize \= Math.max(14, Math.round(width \* 0.018));  
  const tagSize \= Math.max(11, Math.round(width \* 0.013));

  // ─── SCANLINE pulse ───────────────────────────────────────────────────────  
  const scanlineY \= (frame \* 1.8) % height;

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>

      {/\* ── Radial vignette bg ── \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 70% 70% at 70% 40%, ${COLORS.surface2} 0%, ${COLORS.bg} 80%)\`,  
          zIndex: 0,  
        }}  
      /\>

      {/\* ── Rule-of-thirds grid overlay (fades in then out) ── \*/}  
      \<AbsoluteFill style={{ zIndex: 1, pointerEvents: "none" }}\>  
        {/\* Vertical 1/3 \*/}  
        \<div style={{ position: "absolute", left: "33.33%", top: 0, bottom: 0, width: 1, background: COLORS.accentBlue, opacity: gridOpacity }} /\>  
        \<div style={{ position: "absolute", left: "66.66%", top: 0, bottom: 0, width: 1, background: COLORS.accentBlue, opacity: gridOpacity }} /\>  
        {/\* Horizontal 1/3 \*/}  
        \<div style={{ position: "absolute", top: "33.33%", left: 0, right: 0, height: 1, background: COLORS.accentBlue, opacity: gridOpacity }} /\>  
        \<div style={{ position: "absolute", top: "66.66%", left: 0, right: 0, height: 1, background: COLORS.accentBlue, opacity: gridOpacity }} /\>  
        {/\* Intersection dots \*/}  
        {\[\[33.33, 33.33\], \[33.33, 66.66\], \[66.66, 33.33\], \[66.66, 66.66\]\].map((\[x, y\], i) \=\> (  
          \<div  
            key={i}  
            style={{  
              position: "absolute",  
              left: \`${x}%\`,  
              top: \`${y}%\`,  
              width: 8,  
              height: 8,  
              borderRadius: "50%",  
              background: COLORS.accent,  
              transform: "translate(-50%, \-50%)",  
              opacity: gridOpacity \* 6,  
            }}  
          /\>  
        ))}  
      \</AbsoluteFill\>

      {/\* ── Scanline ── \*/}  
      \<AbsoluteFill style={{ zIndex: 1, pointerEvents: "none", overflow: "hidden" }}\>  
        \<div  
          style={{  
            position: "absolute",  
            left: 0,  
            right: 0,  
            top: scanlineY,  
            height: 2,  
            background: \`linear-gradient(90deg, transparent, ${COLORS.accentBlue}22, transparent)\`,  
            opacity: 0.4,  
          }}  
        /\>  
      \</AbsoluteFill\>

      {/\* ── 3D Canvas ── \*/}  
      \<AbsoluteFill style={{ zIndex: 2, opacity: globalFadeOut }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 1, 7\], fov: 55 }}  
        \>  
          \<GeometricCluster frame={frame} fps={fps} /\>  
        \</ThreeCanvas\>  
      \</AbsoluteFill\>

      {/\* ── Left-third typography ── \*/}  
      \<AbsoluteFill  
        style={{  
          zIndex: 3,  
          display: "flex",  
          flexDirection: "column",  
          justifyContent: "center",  
          alignItems: "flex-start",  
          paddingLeft: Math.round(width \* 0.055),  
          paddingRight: Math.round(width \* 0.38),  
          opacity: globalFadeOut,  
        }}  
      \>  
        {/\* Accent rule \*/}  
        \<div  
          style={{  
            width: interpolate(tagEnter, \[0, 1\], \[0, 48\]),  
            height: 2,  
            background: COLORS.accent,  
            marginBottom: 20,  
            borderRadius: 2,  
          }}  
        /\>

        {/\* Tag label \*/}  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: tagSize,  
            fontWeight: 500,  
            letterSpacing: "0.18em",  
            textTransform: "uppercase",  
            color: COLORS.accent,  
            opacity: tagEnter,  
            transform: \`translateY(${interpolate(tagEnter, \[0, 1\], \[12, 0\])}px)\`,  
            marginBottom: 18,  
          }}  
        \>  
          Rule of Thirds  
        \</div\>

        {/\* Title lines \*/}  
        {\[  
          { text: "Visual", enter: line1Enter },  
          { text: "Tension", enter: line2Enter },  
          { text: "by Design", enter: line3Enter },  
        \].map(({ text, enter }, i) \=\> (  
          \<div  
            key={i}  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: titleSize,  
              fontWeight: i \< 2 ? 800 : 300,  
              letterSpacing: i \< 2 ? "-0.025em" : "0.04em",  
              lineHeight: 1.1,  
              color: i \=== 1 ? COLORS.accent : COLORS.text,  
              opacity: enter,  
              transform: \`translateY(${interpolate(enter, \[0, 1\], \[30, 0\])}px)\`,  
              marginBottom: i \=== 2 ? 0 : 4,  
            }}  
          \>  
            {text}  
          \</div\>  
        ))}

        {/\* Subtitle \*/}  
        \<div  
          style={{  
            fontFamily: "Inter, sans-serif",  
            fontSize: subtitleSize,  
            fontWeight: 300,  
            letterSpacing: "0.015em",  
            lineHeight: 1.5,  
            color: COLORS.textMuted,  
            opacity: subtitleEnter,  
            transform: \`translateY(${interpolate(subtitleEnter, \[0, 1\], \[16, 0\])}px)\`,  
            marginTop: 24,  
            maxWidth: 280,  
          }}  
        \>  
          Placing the subject off-center creates  
          dynamic composition and draws the eye  
          through negative space.  
        \</div\>

        {/\* Bottom accent bar \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.08),  
            left: Math.round(width \* 0.055),  
            display: "flex",  
            alignItems: "center",  
            gap: 12,  
            opacity: subtitleEnter,  
          }}  
        \>  
          \<div style={{ width: 6, height: 6, borderRadius: "50%", background: COLORS.accentBlue }} /\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontSize: tagSize,  
              fontWeight: 400,  
              letterSpacing: "0.12em",  
              textTransform: "uppercase",  
              color: COLORS.accentBlue,  
            }}  
          \>  
            3D Composition Study  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>

      {/\* ── Corner bracket (bottom-right) ── \*/}  
      \<AbsoluteFill style={{ zIndex: 3, pointerEvents: "none" }}\>  
        \<div  
          style={{  
            position: "absolute",  
            bottom: Math.round(height \* 0.06),  
            right: Math.round(width \* 0.04),  
            width: 32,  
            height: 32,  
            borderBottom: \`2px solid ${COLORS.textMuted}44\`,  
            borderRight: \`2px solid ${COLORS.textMuted}44\`,  
            opacity: globalFadeOut,  
          }}  
        /\>  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.06),  
            left: Math.round(width \* 0.04),  
            width: 32,  
            height: 32,  
            borderTop: \`2px solid ${COLORS.textMuted}44\`,  
            borderLeft: \`2px solid ${COLORS.textMuted}44\`,  
            opacity: globalFadeOut,  
          }}  
        /\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D extremamente minimalista: apenas o essencial, sem nenhum elemento decorativo.

resultado:

import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, spring, Easing } from "remotion";  
import { ThreeCanvas } from "@remotion/three";

export const MyAnimation \= () \=\> {  
  /\*  
   \* A single geometric form rotating in pure darkness.  
   \* No decoration, no text, no effects — only form and motion.  
   \* The essence of 3D animation distilled to its core.  
   \*/

  const frame \= useCurrentFrame();  
  const { width, height, fps } \= useVideoConfig();

  const COLORS \= {  
    bg: "\#000000",  
    surface: "\#FFFFFF",  
  };

  const TIMING \= {  
    ENTER: fps \* 1.2,  
  };

  const scaleProgress \= spring({  
    frame,  
    fps,  
    config: { damping: 18, stiffness: 60, mass: 1.2 },  
  });

  const opacity \= interpolate(frame, \[0, TIMING.ENTER\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.out(Easing.cubic),  
  });

  const rotationY \= frame \* 0.018;  
  const rotationX \= frame \* 0.007;  
  const floatY \= Math.sin(frame \* 0.04) \* 0.12;

  return (  
    \<AbsoluteFill style={{ backgroundColor: COLORS.bg }}\>  
      \<div style={{ width: "100%", height: "100%", opacity }}\>  
        \<ThreeCanvas  
          width={width}  
          height={height}  
          camera={{ position: \[0, 0, 4.5\], fov: 60 }}  
        \>  
          \<ambientLight intensity={0.15} /\>  
          \<directionalLight position={\[3, 5, 5\]} intensity={0.9} color="\#ffffff" /\>  
          \<directionalLight position={\[-3, \-2, \-4\]} intensity={0.1} color="\#aaaaff" /\>

          \<mesh  
            rotation={\[rotationX, rotationY, 0\]}  
            position={\[0, floatY, 0\]}  
            scale={\[scaleProgress, scaleProgress, scaleProgress\]}  
          \>  
            \<torusKnotGeometry args={\[0.8, 0.22, 200, 20, 2, 3\]} /\>  
            \<meshStandardMaterial  
              color={COLORS.surface}  
              roughness={0.05}  
              metalness={0.1}  
            /\>  
          \</mesh\>  
        \</ThreeCanvas\>  
      \</div\>  
    \</AbsoluteFill\>  
  );  
};

prompt:

Crie uma animação 3D de 10 segundos onde cada elemento introduzido ao longo do tempo pertence ao mesmo universo visual — como se tudo fosse desenhado pelo mesmo diretor.

resultado:

import {  
  useCurrentFrame,  
  useVideoConfig,  
  AbsoluteFill,  
  interpolate,  
  spring,  
  Easing,  
  Sequence,  
} from "remotion";  
import { ThreeCanvas } from "@remotion/three";  
import { useRef } from "react";  
import \* as THREE from "three";

/\*  
  A unified visual-universe animation: one director, one aesthetic language.  
  Three scenes — geometric awakening, orbital dance, crystalline monument —  
  all sharing the same neon-dark palette, spring physics, and typographic voice.  
\*/

// ─── Sub-scene A: Awakening ───────────────────────────────────────────────────  
const SceneAwakening \= ({ localFrame, fps }: { localFrame: number; fps: number }) \=\> {  
  const { width, height } \= useVideoConfig();

  const scaleIn \= spring({ frame: localFrame, fps, config: { damping: 200, stiffness: 80 } });  
  const rotY \= localFrame \* 0.025;  
  const rotX \= Math.sin(localFrame \* 0.018) \* 0.4;  
  const floatY \= Math.sin(localFrame \* 0.06) \* 0.12;

  const glowOpacity \= interpolate(localFrame, \[0, 40\], \[0, 0.6\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleOpacity \= interpolate(localFrame, \[20, 50\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });  
  const titleY \= interpolate(localFrame, \[20, 50\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });

  return (  
    \<AbsoluteFill\>  
      {/\* 3D Layer \*/}  
      \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 0, 5\], fov: 60 }}\>  
        \<ambientLight intensity={0.15} /\>  
        \<pointLight position={\[4, 4, 4\]} intensity={1.2} color="\#00AAFF" /\>  
        \<pointLight position={\[-4, \-3, 2\]} intensity={0.8} color="\#00FF88" /\>

        {/\* Central dodecahedron \*/}  
        \<mesh  
          rotation={\[rotX, rotY, localFrame \* 0.012\]}  
          position={\[0, floatY, 0\]}  
          scale={\[scaleIn \* 1.4, scaleIn \* 1.4, scaleIn \* 1.4\]}  
        \>  
          \<dodecahedronGeometry args={\[1, 0\]} /\>  
          \<meshStandardMaterial  
            color="\#0B0B1A"  
            emissive="\#00AAFF"  
            emissiveIntensity={0.35}  
            metalness={0.9}  
            roughness={0.1}  
            wireframe={false}  
          /\>  
        \</mesh\>

        {/\* Wireframe overlay \*/}  
        \<mesh  
          rotation={\[rotX \* 1.1, rotY \* 1.05, localFrame \* 0.008\]}  
          position={\[0, floatY, 0\]}  
          scale={\[scaleIn \* 1.45, scaleIn \* 1.45, scaleIn \* 1.45\]}  
        \>  
          \<dodecahedronGeometry args={\[1, 0\]} /\>  
          \<meshBasicMaterial color="\#00FF88" wireframe opacity={0.3} transparent /\>  
        \</mesh\>

        {/\* Orbiting ring \*/}  
        \<mesh  
          rotation={\[Math.PI / 2 \+ localFrame \* 0.015, localFrame \* 0.02, 0\]}  
          scale={\[scaleIn, scaleIn, scaleIn\]}  
        \>  
          \<torusGeometry args={\[2.0, 0.025, 8, 64\]} /\>  
          \<meshBasicMaterial color="\#00AAFF" opacity={0.5} transparent /\>  
        \</mesh\>  
      \</ThreeCanvas\>

      {/\* Glow radial \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 40% 35% at 50% 50%, rgba(0,170,255,${glowOpacity \* 0.25}) 0%, transparent 70%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Title \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.1),  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 800,  
              fontSize: Math.max(28, Math.round(width \* 0.042)),  
              letterSpacing: "-0.02em",  
              color: "\#FFFFFF",  
            }}  
          \>  
            AWAKENING  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 300,  
              fontSize: Math.max(12, Math.round(width \* 0.016)),  
              letterSpacing: "0.22em",  
              color: "\#00AAFF",  
              marginTop: 8,  
              textTransform: "uppercase",  
            }}  
          \>  
            Form meets light  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

// ─── Sub-scene B: Orbital Dance ───────────────────────────────────────────────  
const SceneOrbital \= ({ localFrame, fps }: { localFrame: number; fps: number }) \=\> {  
  const { width, height } \= useVideoConfig();

  const scaleIn \= spring({ frame: localFrame, fps, config: { damping: 200, stiffness: 80 } });  
  const glowOpacity \= interpolate(localFrame, \[0, 30\], \[0, 0.5\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleOpacity \= interpolate(localFrame, \[15, 45\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });  
  const titleY \= interpolate(localFrame, \[15, 45\], \[20, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });

  // Three orbiting satellites  
  const orbitRadius \= 2.0;  
  const orbitSpeed \= 0.022;  
  const satellites \= \[0, (Math.PI \* 2\) / 3, (Math.PI \* 4\) / 3\].map((offset, i) \=\> {  
    const angle \= localFrame \* orbitSpeed \+ offset;  
    const tilt \= i \* 0.4;  
    return {  
      x: Math.cos(angle) \* orbitRadius,  
      y: Math.sin(angle \* 0.6 \+ tilt) \* 0.5,  
      z: Math.sin(angle) \* orbitRadius \* 0.6,  
      color: \["\#00FF88", "\#00AAFF", "\#7C3AED"\]\[i\],  
    };  
  });

  return (  
    \<AbsoluteFill\>  
      \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 1.5, 6\], fov: 58 }}\>  
        \<ambientLight intensity={0.1} /\>  
        \<pointLight position={\[0, 4, 4\]} intensity={1.0} color="\#7C3AED" /\>  
        \<pointLight position={\[4, \-2, 2\]} intensity={0.9} color="\#00FF88" /\>  
        \<pointLight position={\[-4, 2, 2\]} intensity={0.8} color="\#00AAFF" /\>

        {/\* Central icosahedron \*/}  
        \<mesh  
          rotation={\[localFrame \* 0.01, localFrame \* 0.018, localFrame \* 0.008\]}  
          scale={\[scaleIn, scaleIn, scaleIn\]}  
        \>  
          \<icosahedronGeometry args={\[1, 0\]} /\>  
          \<meshStandardMaterial  
            color="\#050510"  
            emissive="\#7C3AED"  
            emissiveIntensity={0.5}  
            metalness={0.95}  
            roughness={0.05}  
          /\>  
        \</mesh\>

        {/\* Central wireframe \*/}  
        \<mesh  
          rotation={\[localFrame \* 0.012, localFrame \* 0.02, localFrame \* 0.006\]}  
          scale={\[scaleIn \* 1.04, scaleIn \* 1.04, scaleIn \* 1.04\]}  
        \>  
          \<icosahedronGeometry args={\[1, 0\]} /\>  
          \<meshBasicMaterial color="\#7C3AED" wireframe opacity={0.4} transparent /\>  
        \</mesh\>

        {/\* Orbiting satellites \*/}  
        {satellites.map((sat, i) \=\> (  
          \<mesh  
            key={i}  
            position={\[sat.x \* scaleIn, sat.y, sat.z \* scaleIn\]}  
            rotation={\[localFrame \* 0.04, localFrame \* 0.06, 0\]}  
            scale={\[0.22, 0.22, 0.22\]}  
          \>  
            \<tetrahedronGeometry args={\[1, 0\]} /\>  
            \<meshStandardMaterial  
              color={sat.color}  
              emissive={sat.color}  
              emissiveIntensity={0.7}  
              metalness={0.8}  
              roughness={0.1}  
            /\>  
          \</mesh\>  
        ))}

        {/\* Equatorial ring \*/}  
        \<mesh  
          rotation={\[Math.PI / 4, localFrame \* 0.018, 0\]}  
          scale={\[scaleIn, scaleIn, scaleIn\]}  
        \>  
          \<torusGeometry args={\[2.4, 0.018, 8, 80\]} /\>  
          \<meshBasicMaterial color="\#7C3AED" opacity={0.35} transparent /\>  
        \</mesh\>  
      \</ThreeCanvas\>

      {/\* Glow radial \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 40% 35% at 50% 45%, rgba(124,58,237,${glowOpacity \* 0.3}) 0%, transparent 70%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Title \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.1),  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 800,  
              fontSize: Math.max(28, Math.round(width \* 0.042)),  
              letterSpacing: "-0.02em",  
              color: "\#FFFFFF",  
            }}  
          \>  
            ORBITAL DANCE  
          \</div\>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 300,  
              fontSize: Math.max(12, Math.round(width \* 0.016)),  
              letterSpacing: "0.22em",  
              color: "\#7C3AED",  
              marginTop: 8,  
              textTransform: "uppercase",  
            }}  
          \>  
            Gravity in harmony  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

// ─── Sub-scene C: Crystalline Monument ────────────────────────────────────────  
const SceneCrystal \= ({ localFrame, fps }: { localFrame: number; fps: number }) \=\> {  
  const { width, height } \= useVideoConfig();

  const scaleIn \= spring({ frame: localFrame, fps, config: { damping: 200, stiffness: 60 } });  
  const glowOpacity \= interpolate(localFrame, \[0, 30\], \[0, 0.65\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });  
  const titleOpacity \= interpolate(localFrame, \[20, 55\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });  
  const titleY \= interpolate(localFrame, \[20, 55\], \[24, 0\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
    easing: Easing.bezier(0.16, 1, 0.3, 1),  
  });  
  const subtitleOpacity \= interpolate(localFrame, \[40, 75\], \[0, 1\], {  
    extrapolateLeft: "clamp",  
    extrapolateRight: "clamp",  
  });

  const floatY \= Math.sin(localFrame \* 0.04) \* 0.08;  
  const rotY \= localFrame \* 0.016;

  return (  
    \<AbsoluteFill\>  
      \<ThreeCanvas width={width} height={height} camera={{ position: \[0, 0.5, 5.5\], fov: 55 }}\>  
        \<ambientLight intensity={0.1} /\>  
        \<pointLight position={\[3, 5, 3\]} intensity={1.3} color="\#00FF88" /\>  
        \<pointLight position={\[-3, \-3, 3\]} intensity={0.9} color="\#00AAFF" /\>  
        \<pointLight position={\[0, 0, 5\]} intensity={0.6} color="\#FFFFFF" /\>

        {/\* Top crystal \*/}  
        \<mesh  
          rotation={\[0, rotY, 0\]}  
          position={\[0, floatY \+ 1.1, 0\]}  
          scale={\[scaleIn \* 0.7, scaleIn \* 1.5, scaleIn \* 0.7\]}  
        \>  
          \<octahedronGeometry args={\[0.9, 0\]} /\>  
          \<meshStandardMaterial  
            color="\#050510"  
            emissive="\#00FF88"  
            emissiveIntensity={0.5}  
            metalness={0.95}  
            roughness={0.05}  
          /\>  
        \</mesh\>

        {/\* Top wireframe \*/}  
        \<mesh  
          rotation={\[0, rotY \* 1.05, 0\]}  
          position={\[0, floatY \+ 1.1, 0\]}  
          scale={\[scaleIn \* 0.73, scaleIn \* 1.53, scaleIn \* 0.73\]}  
        \>  
          \<octahedronGeometry args={\[0.9, 0\]} /\>  
          \<meshBasicMaterial color="\#00FF88" wireframe opacity={0.25} transparent /\>  
        \</mesh\>

        {/\* Base crystal \*/}  
        \<mesh  
          rotation={\[Math.PI, \-rotY \* 0.8, 0\]}  
          position={\[0, floatY \- 1.1, 0\]}  
          scale={\[scaleIn \* 0.9, scaleIn \* 1.2, scaleIn \* 0.9\]}  
        \>  
          \<octahedronGeometry args={\[0.9, 0\]} /\>  
          \<meshStandardMaterial  
            color="\#050510"  
            emissive="\#00AAFF"  
            emissiveIntensity={0.5}  
            metalness={0.95}  
            roughness={0.05}  
          /\>  
        \</mesh\>

        {/\* Base wireframe \*/}  
        \<mesh  
          rotation={\[Math.PI, \-rotY \* 0.82, 0\]}  
          position={\[0, floatY \- 1.1, 0\]}  
          scale={\[scaleIn \* 0.93, scaleIn \* 1.23, scaleIn \* 0.93\]}  
        \>  
          \<octahedronGeometry args={\[0.9, 0\]} /\>  
          \<meshBasicMaterial color="\#00AAFF" wireframe opacity={0.25} transparent /\>  
        \</mesh\>

        {/\* Horizontal ring \*/}  
        \<mesh  
          rotation={\[Math.PI / 2, 0, localFrame \* 0.02\]}  
          position={\[0, floatY, 0\]}  
          scale={\[scaleIn, scaleIn, scaleIn\]}  
        \>  
          \<torusGeometry args={\[1.8, 0.022, 8, 64\]} /\>  
          \<meshBasicMaterial color="\#FFFFFF" opacity={0.2} transparent /\>  
        \</mesh\>

        {/\* Tilted ring \*/}  
        \<mesh  
          rotation={\[Math.PI / 3, localFrame \* 0.015, 0\]}  
          position={\[0, floatY, 0\]}  
          scale={\[scaleIn, scaleIn, scaleIn\]}  
        \>  
          \<torusGeometry args={\[2.2, 0.016, 8, 64\]} /\>  
          \<meshBasicMaterial color="\#00FF88" opacity={0.18} transparent /\>  
        \</mesh\>  
      \</ThreeCanvas\>

      {/\* Glow radial — dual tone \*/}  
      \<AbsoluteFill  
        style={{  
          background: \`radial-gradient(ellipse 35% 60% at 50% 50%, rgba(0,255,136,${glowOpacity \* 0.2}) 0%, rgba(0,170,255,${glowOpacity \* 0.12}) 50%, transparent 75%)\`,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Title \*/}  
      \<AbsoluteFill  
        style={{  
          display: "flex",  
          alignItems: "flex-end",  
          justifyContent: "center",  
          paddingBottom: Math.round(height \* 0.1),  
        }}  
      \>  
        \<div  
          style={{  
            opacity: titleOpacity,  
            transform: \`translateY(${titleY}px)\`,  
            textAlign: "center",  
          }}  
        \>  
          \<div  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 800,  
              fontSize: Math.max(28, Math.round(width \* 0.042)),  
              letterSpacing: "-0.02em",  
              background: "linear-gradient(90deg, \#00FF88, \#00AAFF)",  
              WebkitBackgroundClip: "text",  
              WebkitTextFillColor: "transparent",  
            }}  
          \>  
            CRYSTALLINE  
          \</div\>  
          \<div  
            style={{  
              opacity: subtitleOpacity,  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 300,  
              fontSize: Math.max(12, Math.round(width \* 0.016)),  
              letterSpacing: "0.22em",  
              color: "\#A0A0A8",  
              marginTop: 8,  
              textTransform: "uppercase",  
            }}  
          \>  
            One universe · One director  
          \</div\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

// ─── Main Composition ─────────────────────────────────────────────────────────  
export const MyAnimation \= () \=\> {  
  /\*  
    Three 3D scenes inhabit the same neon-dark universe — PREMIUM DARK/NEON hybrid.  
    Each shares identical spring physics (damping: 200), color language (cyan/green/violet),  
    and typographic voice (Inter 800 title \+ wide-tracked caption), ensuring directorial unity.  
  \*/  
  const frame \= useCurrentFrame();  
  const { fps, width, height } \= useVideoConfig();

  // THEME TOKENS  
  const COLORS \= {  
    bg: "\#050510",  
    surface1: "\#0B0B1A",  
    text: "\#FFFFFF",  
    textMuted: "\#A0A0A8",  
    accent1: "\#00FF88",  
    accent2: "\#00AAFF",  
    accent3: "\#7C3AED",  
  };  
  const TIMING \= { SCENE: 100, TRANSITION: 0 };

  // Scene durations (3 scenes × 100 frames \= 300 \= 10s at 30fps)  
  const SCENE\_A\_START \= 0;  
  const SCENE\_A\_DUR \= 100;  
  const SCENE\_B\_START \= 100;  
  const SCENE\_B\_DUR \= 100;  
  const SCENE\_C\_START \= 200;  
  const SCENE\_C\_DUR \= 100;

  // Thin top bar progress  
  const totalProgress \= frame / 299;

  return (  
    \<AbsoluteFill style={{ background: COLORS.bg, overflow: "hidden" }}\>  
      {/\* Vignette \*/}  
      \<AbsoluteFill  
        style={{  
          background:  
            "radial-gradient(ellipse 80% 80% at 50% 50%, transparent 40%, rgba(5,5,16,0.85) 100%)",  
          zIndex: 0,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Grid texture \*/}  
      \<AbsoluteFill  
        style={{  
          backgroundImage: \`linear-gradient(rgba(0,170,255,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(0,170,255,0.035) 1px, transparent 1px)\`,  
          backgroundSize: "60px 60px",  
          zIndex: 0,  
          pointerEvents: "none",  
        }}  
      /\>

      {/\* Scene A \*/}  
      \<Sequence from={SCENE\_A\_START} durationInFrames={SCENE\_A\_DUR} premountFor={fps}\>  
        \<SceneAwakening localFrame={frame \- SCENE\_A\_START} fps={fps} /\>  
      \</Sequence\>

      {/\* Scene B \*/}  
      \<Sequence from={SCENE\_B\_START} durationInFrames={SCENE\_B\_DUR} premountFor={fps}\>  
        \<SceneOrbital localFrame={frame \- SCENE\_B\_START} fps={fps} /\>  
      \</Sequence\>

      {/\* Scene C \*/}  
      \<Sequence from={SCENE\_C\_START} durationInFrames={SCENE\_C\_DUR} premountFor={fps}\>  
        \<SceneCrystal localFrame={frame \- SCENE\_C\_START} fps={fps} /\>  
      \</Sequence\>

      {/\* Scene label — top left \*/}  
      \<AbsoluteFill style={{ pointerEvents: "none", zIndex: 10 }}\>  
        \<div  
          style={{  
            position: "absolute",  
            top: Math.round(height \* 0.04),  
            left: Math.round(width \* 0.04),  
            display: "flex",  
            alignItems: "center",  
            gap: 10,  
          }}  
        \>  
          \<div  
            style={{  
              width: 8,  
              height: 8,  
              borderRadius: "50%",  
              background: COLORS.accent1,  
              opacity: 0.9,  
            }}  
          /\>  
          \<span  
            style={{  
              fontFamily: "Inter, sans-serif",  
              fontWeight: 500,  
              fontSize: Math.max(10, Math.round(width \* 0.012)),  
              letterSpacing: "0.15em",  
              color: COLORS.textMuted,  
              textTransform: "uppercase",  
            }}  
          \>  
            {frame \< SCENE\_B\_START  
              ? "01 · Awakening"  
              : frame \< SCENE\_C\_START  
              ? "02 · Orbital Dance"  
              : "03 · Crystalline"}  
          \</span\>  
        \</div\>

        {/\* Progress bar \*/}  
        \<div  
          style={{  
            position: "absolute",  
            bottom: 0,  
            left: 0,  
            right: 0,  
            height: 2,  
            background: "rgba(255,255,255,0.06)",  
          }}  
        \>  
          \<div  
            style={{  
              height: "100%",  
              width: \`${totalProgress \* 100}%\`,  
              background: \`linear-gradient(90deg, ${COLORS.accent2}, ${COLORS.accent1})\`,  
            }}  
          /\>  
        \</div\>  
      \</AbsoluteFill\>  
    \</AbsoluteFill\>  
  );  
};

