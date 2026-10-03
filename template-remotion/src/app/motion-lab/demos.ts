/**
 * Motion lab demos — written the way generated code is written (source text,
 * imports included) and compiled by the same compileCode() the pipeline uses.
 * If a demo plays here, the component works for generated videos too.
 */
export interface MotionDemo {
  id: string;
  title: string;
  description: string;
  width: number;
  height: number;
  durationInFrames: number;
  code: string;
}

const strokes = String.raw`
import { AbsoluteFill, Sequence } from "remotion";

const line = { fontFamily: "-apple-system, SF Pro Display, system-ui, sans-serif", fontSize: 64, fontWeight: 800, color: "#FFFFFF", letterSpacing: 1, textTransform: "uppercase" as const };
const label = { fontFamily: "monospace", fontSize: 20, color: "rgba(255,255,255,0.4)", marginBottom: 10 };

export const StrokesDemo = () => {
  return (
    <AbsoluteFill style={{ background: "#000000", padding: 90, justifyContent: "center", gap: 46 }}>
      <div><div style={label}>Underline</div><div style={line}>DINHEIRO <Underline delay={10}>EXIGE</Underline> ESTRUTURA</div></div>
      <div><div style={label}>Strike</div><div style={line}>NÃO É <Strike delay={30} color="#FF4D4D">SORTE</Strike> É MÉTODO</div></div>
      <div><div style={label}>Scribble</div><div style={line}>ESQUEÇA O <Scribble delay={50} color="#FF4D4D">CAOS</Scribble></div></div>
      <div><div style={label}>CircleAround</div><div style={line}>O QUE <CircleAround delay={75} color="#FFD600">IMPORTA</CircleAround></div></div>
      <div><div style={label}>Highlighter</div><div style={{ ...line, color: "#000", background: "transparent" }}><span style={{ color: "#FFF" }}>FOCO NO </span><Highlighter delay={100} color="#FFD600">ESSENCIAL</Highlighter></div></div>
    </AbsoluteFill>
  );
};
`;

const morph = String.raw`
import { AbsoluteFill } from "remotion";

const text = { fontFamily: "-apple-system, SF Pro Display, system-ui, sans-serif", color: "#FFFFFF", textTransform: "uppercase" as const, letterSpacing: 2 };
const labels = ["CARD", "PÍLULA", "ANEL", "TELA"];

export const MorphDemo = () => {
  const keyframes = [
    { at: 0,   x: 540, y: 900, width: 760, height: 460, radius: 40,  color: "#141414", borderColor: "#2A2A2A", borderWidth: 2 },
    { at: 60,  x: 540, y: 900, width: 620, height: 140, radius: 70,  color: "#FFFFFF", borderColor: "#FFFFFF", borderWidth: 2 },
    { at: 120, x: 540, y: 900, width: 420, height: 420, radius: 210, color: "#000000", borderColor: "#FFFFFF", borderWidth: 14 },
    { at: 180, x: 540, y: 960, width: 1080, height: 1920, radius: 0, color: "#141414", borderColor: "#141414", borderWidth: 0 },
  ];
  return (
    <AbsoluteFill style={{ background: "#000000" }}>
      <MorphContainer keyframes={keyframes} morphFrames={22}>
        {({ index, t }) => (
          <AbsoluteFill style={{ justifyContent: "center", alignItems: "center", opacity: 1 - Math.min(1, t * 3) }}>
            <span style={{ ...text, fontSize: 40, fontWeight: 600, color: index === 1 ? "#000000" : "#FFFFFF" }}>{labels[index]}</span>
          </AbsoluteFill>
        )}
      </MorphContainer>
      <div style={{ ...text, position: "absolute", bottom: 450, left: 0, right: 0, textAlign: "center", fontSize: 26, fontWeight: 300 }}>
        UMA FORMA, QUATRO MOMENTOS
      </div>
    </AbsoluteFill>
  );
};
`;

const transitions = String.raw`
import { AbsoluteFill, Sequence } from "remotion";

const big = { fontFamily: "-apple-system, SF Pro Display, system-ui, sans-serif", fontSize: 92, fontWeight: 800, color: "#FFFFFF", textTransform: "uppercase" as const, lineHeight: 1.05 };
const small = { ...big, fontSize: 44, fontWeight: 300, color: "rgba(255,255,255,0.7)" };

export const TransitionsDemo = () => {
  const D = 90;
  // Push contínuo: o momento seguinte começa OVERLAP frames antes do fim do
  // anterior, então a saída de um e a entrada do outro acontecem juntas.
  const OVERLAP = 14;
  return (
    <AbsoluteFill style={{ background: "#000000" }}>
      <Sequence from={0} durationInFrames={D}>
        <SceneTransition durationInFrames={D} enter="blur" exit="left" distance="full" exitFrames={OVERLAP}>
          <AbsoluteFill style={{ justifyContent: "center", padding: 90 }}>
            <StaggerText text="ROTINA NÃO É PRISÃO" style={big} each={5} />
          </AbsoluteFill>
        </SceneTransition>
      </Sequence>
      <Sequence from={D - OVERLAP} durationInFrames={D}>
        <SceneTransition durationInFrames={D} enter="right" exit="up" distance="full" enterFrames={OVERLAP} exitFrames={OVERLAP}>
          <AbsoluteFill style={{ justifyContent: "center", padding: 90 }}>
            <Stagger each={6} from="left" distance={60}>
              <div style={small}>É O QUE TE</div>
              <div style={big}>LIBERTA</div>
            </Stagger>
          </AbsoluteFill>
        </SceneTransition>
      </Sequence>
      <Sequence from={D * 2 - OVERLAP * 2} durationInFrames={D}>
        <SceneTransition durationInFrames={D} enter="down" exit="zoom" distance="full" enterFrames={OVERLAP}>
          <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
            <StaggerText text="DISCIPLINA" by="char" each={2} blur style={big} />
          </AbsoluteFill>
        </SceneTransition>
      </Sequence>
    </AbsoluteFill>
  );
};
`;

const dots = String.raw`
import { AbsoluteFill, Sequence } from "remotion";

const label = { position: "absolute" as const, top: 60, left: 60, fontFamily: "monospace", fontSize: 26, color: "rgba(255,255,255,0.6)" };

export const DotsDemo = () => (
  <AbsoluteFill style={{ background: "#000000" }}>
    <Sequence from={0} durationInFrames={90}>
      <DotField animation="reveal" duration={40} origin={{ x: 0.5, y: 0.6 }} opacity={0.5} />
      <div style={label}>DotField · reveal</div>
    </Sequence>
    <Sequence from={90} durationInFrames={90}>
      <DotField animation="wave" spacing={30} opacity={0.45} />
      <div style={label}>DotField · wave</div>
    </Sequence>
    <Sequence from={180} durationInFrames={90}>
      <DotField animation="breathe" spacing={44} radius={3} opacity={0.4} />
      <div style={label}>DotField · breathe</div>
    </Sequence>
  </AbsoluteFill>
);
`;

const lines = String.raw`
import { AbsoluteFill, Sequence } from "remotion";

const label = { position: "absolute" as const, top: 60, left: 60, fontFamily: "monospace", fontSize: 26, color: "rgba(255,255,255,0.6)" };

export const LinesDemo = () => (
  <AbsoluteFill style={{ background: "#000000" }}>
    <Sequence from={0} durationInFrames={90}>
      <LineField animation="draw" direction="diagonal" count={22} opacity={0.35} />
      <div style={label}>LineField · draw · diagonal</div>
    </Sequence>
    <Sequence from={90} durationInFrames={90}>
      <LineField animation="wave" count={16} amplitude={30} opacity={0.35} />
      <div style={label}>LineField · wave</div>
    </Sequence>
    <Sequence from={180} durationInFrames={90}>
      <GridReveal cell={108} from="center" duration={36} opacity={0.3} />
      <div style={label}>GridReveal · center</div>
    </Sequence>
  </AbsoluteFill>
);
`;

const combo = String.raw`
import { AbsoluteFill, Sequence } from "remotion";

const big = { fontFamily: "-apple-system, SF Pro Display, system-ui, sans-serif", fontSize: 84, fontWeight: 800, color: "#FFFFFF", textTransform: "uppercase" as const, lineHeight: 1.1 };

export const ComboDemo = () => {
  const D = 120;
  return (
    <AbsoluteFill style={{ background: "#000000" }}>
      <Sequence from={0} durationInFrames={D}>
        <SceneTransition durationInFrames={D} enter="fade" exit="left">
          <GridReveal cell={120} duration={30} opacity={0.18} />
          <AbsoluteFill style={{ justifyContent: "center", padding: 90 }}>
            <div style={big}><StaggerText text="VOCÊ NÃO PRECISA DE" each={4} /></div>
            <div style={big}><Strike delay={40} color="#FF4D4D">MAIS TEMPO</Strike></div>
          </AbsoluteFill>
        </SceneTransition>
      </Sequence>
      <Sequence from={D} durationInFrames={D}>
        <SceneTransition durationInFrames={D} enter="right" exit="fade">
          <DotField animation="wave" spacing={34} opacity={0.25} />
          <AbsoluteFill style={{ justifyContent: "center", padding: 90 }}>
            <div style={big}><StaggerText text="PRECISA DE" each={4} /></div>
            <div style={{ ...big, color: "#000" }}><Highlighter delay={22} color="#FFFFFF">DIREÇÃO</Highlighter></div>
          </AbsoluteFill>
        </SceneTransition>
      </Sequence>
    </AbsoluteFill>
  );
};
`;

export const MOTION_DEMOS: MotionDemo[] = [
  { id: "strokes", title: "Traços sobre o lettering", description: "Underline · Strike · Scribble · CircleAround · Highlighter", width: 1080, height: 1080, durationInFrames: 150, code: strokes },
  { id: "morph", title: "Morph entre momentos (Modo A)", description: "MorphContainer: card → pílula → anel → tela", width: 1080, height: 1920, durationInFrames: 240, code: morph },
  { id: "transitions", title: "Transição direcional (Modo B) + lettering", description: "SceneTransition (empurrão de quadro inteiro) · Stagger · StaggerText", width: 1080, height: 1920, durationInFrames: 242, code: transitions },
  { id: "dots", title: "Pontilhismo", description: "DotField: reveal · wave · breathe", width: 1080, height: 1920, durationInFrames: 270, code: dots },
  { id: "lines", title: "Linhas e grid", description: "LineField: draw · wave · GridReveal", width: 1080, height: 1920, durationInFrames: 270, code: lines },
  { id: "combo", title: "Combinado", description: "Textura + transição + traço num mesmo vídeo", width: 1920, height: 1080, durationInFrames: 240, code: combo },
];
