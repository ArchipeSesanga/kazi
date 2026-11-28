import { describe, expect, it } from "vitest";
import { detectLang, en, fr } from "./strings";

function shape(o: unknown): unknown {
  if (typeof o === "function") return "fn";
  if (o && typeof o === "object") {
    return Object.fromEntries(Object.entries(o).map(([k, v]) => [k, shape(v)]));
  }
  return typeof o;
}

describe("i18n", () => {
  it("French and English have exactly the same keys and kinds of values", () => {
    expect(shape(fr)).toEqual(shape(en));
  });

  it("no empty strings", () => {
    const walk = (o: unknown, path = ""): string[] =>
      typeof o === "string"
        ? o.trim() === "" ? [path] : []
        : o && typeof o === "object"
          ? Object.entries(o).flatMap(([k, v]) => walk(v, `${path}.${k}`))
          : [];
    expect(walk(fr)).toEqual([]);
    expect(walk(en)).toEqual([]);
  });

  it("picks the stored language, else the browser's, defaulting to French", () => {
    expect(detectLang("en-US", null)).toBe("en");
    expect(detectLang("fr-CD", null)).toBe("fr");
    expect(detectLang("sw", null)).toBe("fr");
    expect(detectLang("en-US", "fr")).toBe("fr");
    expect(detectLang(undefined, "x")).toBe("fr");
  });
});
