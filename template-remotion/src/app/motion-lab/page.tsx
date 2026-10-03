"use client";

import { Player } from "@remotion/player";
import { useMemo } from "react";
import { compileCode } from "../../remotion/compiler";
import { MOTION_DEMOS, type MotionDemo } from "./demos";

function DemoCard({ demo }: { demo: MotionDemo }) {
  const { Component, error } = useMemo(() => compileCode(demo.code), [demo.code]);
  const portrait = demo.height > demo.width;

  return (
    <section className="flex flex-col gap-3 rounded-xl border border-white/10 bg-white/[0.03] p-4">
      <header>
        <h2 className="text-base font-semibold text-white">{demo.title}</h2>
        <p className="font-mono text-xs text-white/50">{demo.description}</p>
      </header>
      {error || !Component ? (
        <pre className="whitespace-pre-wrap rounded bg-red-950/60 p-3 text-xs text-red-200">{error ?? "Sem componente"}</pre>
      ) : (
        <div className={portrait ? "mx-auto w-full max-w-[300px]" : "w-full"}>
          <Player
            component={Component}
            durationInFrames={demo.durationInFrames}
            fps={30}
            compositionWidth={demo.width}
            compositionHeight={demo.height}
            style={{ width: "100%", borderRadius: 8, overflow: "hidden" }}
            controls
            loop
            autoPlay
            acknowledgeRemotionLicense
          />
        </div>
      )}
    </section>
  );
}

export default function MotionLabPage() {
  return (
    <main className="min-h-screen bg-black px-4 py-8 text-white sm:px-8">
      <div className="mx-auto max-w-6xl">
        <h1 className="text-2xl font-bold">Motion lab</h1>
        <p className="mt-1 max-w-2xl text-sm text-white/60">
          Biblioteca de movimento disponível ao código gerado (src/remotion/design-system). Cada demo é
          compilada pelo mesmo compileCode do pipeline: se toca aqui, funciona nos vídeos.
        </p>
        <div className="mt-8 grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
          {MOTION_DEMOS.map((demo) => (
            <DemoCard key={demo.id} demo={demo} />
          ))}
        </div>
      </div>
    </main>
  );
}
