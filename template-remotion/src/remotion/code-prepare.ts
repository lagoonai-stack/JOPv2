/**
 * Pure text preparation of LLM-generated component code.
 *
 * Shared by the browser compiler (src/remotion/compiler.ts) and the server-side
 * validator (src/lib/code-validator.ts) so both see exactly the same source: a
 * syntax check that ran on differently-prepared text would be worthless.
 *
 * Deliberately free of runtime imports — this module has to load inside a Node
 * route, where pulling in remotion / three / mapbox-gl would fail.
 */

export interface PreparedCode {
  /** Import and export statements removed, ready for Babel. */
  cleaned: string;
  /** Name of the component to return from the compiled module. */
  exportedName: string;
}

export function prepareGeneratedCode(code: string): PreparedCode {
    let cleaned = code;

    // Extract the last code block if markdown blocks are present
    const blockRegex = /```[a-zA-Z]*\r?\n([\s\S]*?)```/g;
    let match;
    let lastBlock = "";
    while ((match = blockRegex.exec(code)) !== null) {
      lastBlock = match[1];
    }
    
    if (lastBlock) {
      cleaned = lastBlock;
    } else {
      // Fallback for unclosed blocks or blocks without language tags
      const unclosedMatch = code.match(/```[a-zA-Z]*\r?\n([\s\S]*)$/);
      if (unclosedMatch) {
        cleaned = unclosedMatch[1];
      } else {
        // Fallback: just strip any stray markdown backticks
        cleaned = code.replace(/^[\s\S]*?```[a-zA-Z]*\r?\n/, "").replace(/```\s*$/, "");
        // Strip stray language tags that Claude sometimes prepends without backticks
        cleaned = cleaned.replace(/^\s*(?:typescript|tsx|ts|jsx|js)\s*\r?\n/i, "");
      }
    }

    // Remove type imports
    cleaned = cleaned.replace(/import\s+type\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\w+\s*,\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\*\s+as\s+\w+\s+from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\w+\s+from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s*["'][^"']+["'];?/g, "");

    cleaned = cleaned.trim();

    // Find the main component name
    let exportedName = "DynamicAnimation";
    
    // Look for `export const Name` or `export default Name` or `export function Name`
    // We want the LAST export in the file in case it exports helpers too.
    const exportRegex = /export\s+(?:const|function|default)\s+(?:function\s+)?([A-Za-z0-9_]+)/g;
    let exportMatch;
    while ((exportMatch = exportRegex.exec(cleaned)) !== null) {
      if (exportMatch[1] && exportMatch[1] !== "default") {
        exportedName = exportMatch[1];
      }
    }
    
    // Replace export default Name; with just nothing (we'll return it manually)
    cleaned = cleaned.replace(/export\s+default\s+(?:function\s+)?[A-Za-z0-9_]+;?/g, "");
    
    // Remove all remaining `export ` keywords
    cleaned = cleaned.replace(/export\s+const\s+/g, "const ");
    cleaned = cleaned.replace(/export\s+function\s+/g, "function ");

  return { cleaned, exportedName };
}
