// Search normalisation — must stay identical to the Dart implementation
// (docs/03-TDD.md §8.1).

const STOP_WORDS = new Set([
  "de", "du", "des", "la", "le", "les", "et", "en", "a", "au", "aux",
  "un", "une", "pour", "sur", "avec", "the", "and", "of", "for", "in",
]);

export const MAX_SEARCH_KEYWORDS = 200;
const PREFIX_MIN = 2;
const PREFIX_MAX = 15;

/** distinct(normalize(text)) per TDD §8.1. */
export function tokens(text: string): string[] {
  const normalised = text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
  if (normalised === "") return [];
  const out: string[] = [];
  for (const t of normalised.split(/\s+/)) {
    if (t.length < 2 || STOP_WORDS.has(t) || out.includes(t)) continue;
    out.push(t);
  }
  return out;
}

/**
 * Distinct prefixes (length 2..15) of every token of every part. When the cap
 * is hit, the longest prefixes are dropped first.
 */
export function buildSearchKeywords(
  parts: Array<string | null | undefined>,
  max: number = MAX_SEARCH_KEYWORDS,
): string[] {
  const toks: string[] = [];
  for (const part of parts) {
    if (!part) continue;
    for (const t of tokens(part)) if (!toks.includes(t)) toks.push(t);
  }
  const out = new Set<string>();
  for (let k = PREFIX_MIN; k <= PREFIX_MAX; k++) {
    for (const t of toks) {
      if (t.length < k) continue;
      if (out.size >= max) return [...out];
      out.add(t.slice(0, k));
    }
  }
  return [...out];
}

/** Synonyms of a category in every language (fr, en, ln, sw). */
export function categorySynonyms(category?: {
  synonyms?: Partial<Record<"fr" | "en" | "ln" | "sw", string[]>>;
}): string[] {
  const s = category?.synonyms ?? {};
  return [...(s.fr ?? []), ...(s.en ?? []), ...(s.ln ?? []), ...(s.sw ?? [])].filter(
    (x): x is string => typeof x === "string" && x !== "",
  );
}
