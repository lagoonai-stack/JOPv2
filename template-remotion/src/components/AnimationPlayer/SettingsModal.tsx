"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Settings } from "lucide-react";
import { useEffect, useState } from "react";

interface SettingsModalProps {
  durationInFrames: number;
  onDurationChange: (duration: number) => void;
  fps: number;
  onFpsChange: (fps: number) => void;
  compositionWidth?: number;
  compositionHeight?: number;
  onCompositionWidthChange?: (width: number) => void;
  onCompositionHeightChange?: (height: number) => void;
}

export function SettingsModal({
  durationInFrames,
  onDurationChange,
  fps,
  onFpsChange,
  compositionWidth = 1920,
  compositionHeight = 1080,
  onCompositionWidthChange,
  onCompositionHeightChange,
}: SettingsModalProps) {
  const [open, setOpen] = useState(false);
  const [localDuration, setLocalDuration] = useState(String(durationInFrames));
  const [localFps, setLocalFps] = useState(String(fps));
  const [localWidth, setLocalWidth] = useState(String(compositionWidth));
  const [localHeight, setLocalHeight] = useState(String(compositionHeight));

  // Sync local state when props change
  useEffect(() => {
    setLocalDuration(String(durationInFrames));
    setLocalFps(String(fps));
    setLocalWidth(String(compositionWidth));
    setLocalHeight(String(compositionHeight));
  }, [durationInFrames, fps, compositionWidth, compositionHeight]);

  const handleDurationBlur = () => {
    const parsed = parseInt(localDuration);
    if (isNaN(parsed) || parsed < 1) {
      setLocalDuration(String(durationInFrames));
    } else {
      const clamped = Math.min(1000, Math.max(1, parsed));
      setLocalDuration(String(clamped));
      onDurationChange(clamped);
    }
  };

  const handleFpsBlur = () => {
    const parsed = parseInt(localFps);
    if (isNaN(parsed) || parsed < 1) {
      setLocalFps(String(fps));
    } else {
      const clamped = Math.min(60, Math.max(1, parsed));
      setLocalFps(String(clamped));
      onFpsChange(clamped);
    }
  };

  const handleWidthBlur = () => {
    const parsed = parseInt(localWidth);
    if (isNaN(parsed) || parsed < 100) {
      setLocalWidth(String(compositionWidth));
    } else {
      const clamped = Math.min(3840, Math.max(100, parsed));
      setLocalWidth(String(clamped));
      onCompositionWidthChange?.(clamped);
    }
  };

  const handleHeightBlur = () => {
    const parsed = parseInt(localHeight);
    if (isNaN(parsed) || parsed < 100) {
      setLocalHeight(String(compositionHeight));
    } else {
      const clamped = Math.min(3840, Math.max(100, parsed));
      setLocalHeight(String(clamped));
      onCompositionHeightChange?.(clamped);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Settings className="w-4 h-4" />
          Settings
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px] bg-background-elevated border-border text-foreground">
        <DialogHeader>
          <DialogTitle>Settings</DialogTitle>
          <DialogDescription className="text-muted-foreground">
            Configure your animation settings.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-6 py-4">
          <div className="grid gap-4">
            <h3 className="text-sm font-medium text-foreground">Animation</h3>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label
                  htmlFor="duration"
                  className="text-muted-foreground text-sm"
                >
                  Duration (frames)
                </label>
                <input
                  id="duration"
                  type="number"
                  min={1}
                  max={1000}
                  value={localDuration}
                  onChange={(e) => setLocalDuration(e.target.value)}
                  onBlur={handleDurationBlur}
                  className="w-full px-3 py-2 rounded border border-border bg-input text-foreground text-sm font-sans focus:outline-none focus:border-primary"
                />
              </div>
              <div className="grid gap-2">
                <label htmlFor="fps" className="text-muted-foreground text-sm">
                  FPS
                </label>
                <input
                  id="fps"
                  type="number"
                  min={1}
                  max={60}
                  value={localFps}
                  onChange={(e) => setLocalFps(e.target.value)}
                  onBlur={handleFpsBlur}
                  className="w-full px-3 py-2 rounded border border-border bg-input text-foreground text-sm font-sans focus:outline-none focus:border-primary"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label htmlFor="width" className="text-muted-foreground text-sm">
                  Width (px)
                </label>
                <input
                  id="width"
                  type="number"
                  min={100}
                  max={3840}
                  value={localWidth}
                  onChange={(e) => setLocalWidth(e.target.value)}
                  onBlur={handleWidthBlur}
                  className="w-full px-3 py-2 rounded border border-border bg-input text-foreground text-sm font-sans focus:outline-none focus:border-primary"
                />
              </div>
              <div className="grid gap-2">
                <label htmlFor="height" className="text-muted-foreground text-sm">
                  Height (px)
                </label>
                <input
                  id="height"
                  type="number"
                  min={100}
                  max={3840}
                  value={localHeight}
                  onChange={(e) => setLocalHeight(e.target.value)}
                  onBlur={handleHeightBlur}
                  className="w-full px-3 py-2 rounded border border-border bg-input text-foreground text-sm font-sans focus:outline-none focus:border-primary"
                />
              </div>
            </div>
            <p className="text-xs text-muted-foreground-dim">
              Video length: {(durationInFrames / fps).toFixed(2)}s (
              {durationInFrames} frames / {fps} FPS)
            </p>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Close
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
