import * as Babel from "@babel/standalone";
import { prepareGeneratedCode } from "@/remotion/code-prepare";

/**
 * Server-side inspection of LLM-generated component code.
 *
 * Until this existed, the first thing that ever looked at the generated code
 * was the user's browser: /embed/[token] compiles it with Babel and paints a
 * "Compilation Error" screen when it fails, with no way back — the SaaS path
 * has no follow-up or repair loop. Everything here runs before the preview
 * token is handed to Rails, so a broken generation is retried instead of
 * delivered.
 *
 * Two severities:
 *   - "error"   → would crash the compiler or render visibly broken frames.
 *                 Triggers a regeneration attempt.
 *   - "warning" → degrades quality but still renders. Reported and carried
 *                 into a correction prompt when a retry happens for some other
 *                 reason, never the sole trigger for one: missing clamps are
 *                 common enough that retrying on them alone would burn the
 *                 attempt budget on cosmetics.
 */

export type ProblemSeverity = "error" | "warning";

export interface CodeProblem {
  /** Stable identifier, for logging and metrics. */
  rule: string;
  severity: ProblemSeverity;
  /** Phrased as an instruction the model can act on. */
  message: string;
}

/**
 * Parse the code exactly as the browser compiler will. Catches the whole class
 * of failures that produces the "Compilation Error" screen: unclosed JSX,
 * stray prose, truncated output, bad TypeScript.
 */
export function checkSyntax(code: string): CodeProblem | null {
  if (!code?.trim()) {
    return {
      rule: "empty-output",
      severity: "error",
      message: "The model returned no code.",
    };
  }

  try {
    const { cleaned } = prepareGeneratedCode(code);
    const transpiled = Babel.transform(cleaned, {
      presets: ["react", "typescript"],
      filename: "dynamic-animation.tsx",
    });

    if (!transpiled.code) {
      return {
        rule: "transpile-empty",
        severity: "error",
        message: "Babel produced no output for this component.",
      };
    }
  } catch (error) {
    return {
      rule: "syntax",
      severity: "error",
      message: error instanceof Error ? error.message : String(error),
    };
  }

  return null;
}

/**
 * Extract the argument text of every call to `fnName`, by balancing parens.
 * Good enough for linting generated code; it does not try to be a parser.
 */
function callArguments(code: string, fnName: string): string[] {
  const calls: string[] = [];
  const opener = new RegExp(`(?<![A-Za-z0-9_.])${fnName}\\s*\\(`, "g");
  let match: RegExpExecArray | null;

  while ((match = opener.exec(code)) !== null) {
    let depth = 1;
    let i = match.index + match[0].length;

    while (i < code.length && depth > 0) {
      const char = code[i];
      if (char === "(") depth++;
      else if (char === ")") depth--;
      i++;
    }

    calls.push(code.slice(match.index + match[0].length, i - 1));
  }

  return calls;
}

/** Mechanical rules from the rendering invariants and the pre-delivery checklist. */
export function lintGeneratedCode(code: string): CodeProblem[] {
  const problems: CodeProblem[] = [];
  // Collapse whitespace so adjacency rules are not defeated by line breaks.
  const flat = code.replace(/\s+/g, " ");

  const overlayAdjacency = [
    /<TransitionSeries\.Transition\b[^>]*\/> <TransitionSeries\.Overlay\b/,
    /<\/TransitionSeries\.Transition> <TransitionSeries\.Overlay\b/,
    /<TransitionSeries\.Overlay\b[^>]*\/> <TransitionSeries\.Transition\b/,
    /<\/TransitionSeries\.Overlay> <TransitionSeries\.Transition\b/,
  ];
  if (overlayAdjacency.some((pattern) => pattern.test(flat))) {
    problems.push({
      rule: "overlay-adjacent-transition",
      severity: "error",
      message:
        "A <TransitionSeries.Overlay> sits next to a <TransitionSeries.Transition>. This crashes at render. Between two scenes use EITHER a Transition OR an Overlay, never both.",
    });
  }

  if (/<img[\s/>]/.test(code)) {
    problems.push({
      rule: "native-img",
      severity: "error",
      message:
        "Native <img> is used. Replace every one with <Img> from remotion, or frames can export blank because the asset is not guaranteed loaded.",
    });
  }

  if (
    /\b(transition|animation)(Property|Duration|Delay|TimingFunction|Name|IterationCount|Direction|FillMode)?\s*:\s*[`'"]/.test(
      code,
    )
  ) {
    problems.push({
      rule: "css-animation",
      severity: "error",
      message:
        "A CSS transition/animation property is set in an inline style. These do not render during export. Drive every motion value from useCurrentFrame() instead.",
    });
  }

  if (/className\s*=\s*[`'"][^`'"]*\b(animate-|transition-)/.test(code)) {
    problems.push({
      rule: "tailwind-animation",
      severity: "error",
      message:
        "Tailwind animate-* / transition-* utility classes are used. They do not render during export. Drive motion from useCurrentFrame() with inline styles.",
    });
  }

  if (/\buseFrame\s*\(/.test(code)) {
    problems.push({
      rule: "r3f-use-frame",
      severity: "error",
      message:
        "useFrame() from @react-three/fiber is used. It is not deterministic under render. Drive 3D motion from useCurrentFrame().",
    });
  }

  const unclamped = callArguments(code, "interpolate").filter(
    (args) => !/extrapolateLeft/.test(args) || !/extrapolateRight/.test(args),
  );
  if (unclamped.length > 0) {
    problems.push({
      rule: "interpolate-clamp",
      severity: "warning",
      message: `${unclamped.length} interpolate() call(s) are missing extrapolateLeft and/or extrapolateRight: "clamp". Add both to every interpolation.`,
    });
  }

  return problems;
}

/** Syntax first — a file that does not parse makes the lint findings noise. */
export function inspectGeneratedCode(code: string): CodeProblem[] {
  const syntaxProblem = checkSyntax(code);
  if (syntaxProblem) {
    return [syntaxProblem];
  }

  return lintGeneratedCode(code);
}

export function hasBlockingProblem(problems: CodeProblem[]): boolean {
  return problems.some((problem) => problem.severity === "error");
}

/** Renders the findings as the correction instructions sent back to the model. */
export function describeProblems(problems: CodeProblem[]): string {
  return problems
    .map((problem) => `- [${problem.severity}] ${problem.rule}: ${problem.message}`)
    .join("\n");
}
