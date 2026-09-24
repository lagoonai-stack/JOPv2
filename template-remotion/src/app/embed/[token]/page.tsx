"use client";

import { Player } from "@remotion/player";
import { Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import { compileCode } from "../../../remotion/compiler";

interface EmbedPageProps {
  params: Promise<{ token: string }>;
}

export default function EmbedPage({ params }: EmbedPageProps) {
  const [token, setToken] = useState<string>("");
  const [Component, setComponent] = useState<React.ComponentType | null>(null);
  const [durationInFrames, setDurationInFrames] = useState(300);
  const [fps, setFps] = useState(30);
  const [width, setWidth] = useState(1920);
  const [height, setHeight] = useState(1080);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    params.then(p => setToken(p.token));
  }, [params]);

  useEffect(() => {
    if (!token) return;

    const loadComponent = async () => {
      try {
        // Fetch metadata first
        const metadataResponse = await fetch(`/tmp/${token}.json`);
        if (metadataResponse.ok) {
          const metadata = await metadataResponse.json();
          setDurationInFrames(metadata.durationInFrames || 300);
          setFps(metadata.fps || 30);
          setWidth(metadata.width || 1920);
          setHeight(metadata.height || 1080);
        }

        // Fetch the component code from /tmp/{token}.tsx
        const response = await fetch(`/tmp/${token}.tsx`);
        
        if (!response.ok) {
          throw new Error('Component not found');
        }

        const code = await response.text();
        
        // Compile the code
        const result = compileCode(code);
        
        if (result.error) {
          setError(result.error);
          setIsLoading(false);
          return;
        }
        
        if (result.Component) {
          setComponent(() => result.Component);
        }
        
        setIsLoading(false);
      } catch {
        setError('Failed to load component');
        setIsLoading(false);
      }
    };

    loadComponent();
  }, [token]);

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-black">
        <Loader2 className="h-8 w-8 animate-spin text-white" />
      </div>
    );
  }

  if (error || !Component) {
    return (
      <div className="flex h-screen items-center justify-center bg-black text-white">
        <div className="text-center">
          <p className="text-xl mb-2">{error || "Failed to load preview"}</p>
          <p className="text-sm text-gray-400">The preview may have expired</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen w-full bg-black flex items-center justify-center">
      <Player
        component={Component}
        durationInFrames={durationInFrames}
        fps={fps}
        compositionWidth={width}
        compositionHeight={height}
        style={{
          width: "100%",
          height: "100%",
        }}
        controls
        loop
        autoPlay
      />
    </div>
  );
}