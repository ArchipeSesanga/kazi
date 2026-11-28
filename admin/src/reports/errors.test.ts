import { describe, expect, it } from "vitest";
import { en, fr } from "../i18n/strings";
import { describeError } from "./errors";

describe("describeError", () => {
  it.each([
    ["functions/permission-denied", "", en.errors.permission],
    ["permission-denied", "", en.errors.permission],
    ["functions/unauthenticated", "", en.errors.session],
    ["functions/not-found", "listing-not-found", en.errors.notFound],
    ["functions/failed-precondition", "over-limit", en.errors.overLimit],
    ["functions/failed-precondition", "other", en.errors.generic],
    ["functions/invalid-argument", "invalid-input", en.errors.invalid],
    ["functions/resource-exhausted", "", en.errors.rateLimited],
    ["functions/unavailable", "", en.errors.network],
    ["functions/internal", "boom", en.errors.generic],
  ])("%s %s", (code, message, expected) => {
    expect(describeError({ code, message }, en)).toBe(expected);
  });

  it("falls back for unknown shapes and uses the given language", () => {
    expect(describeError(new Error("x"), en)).toBe(en.errors.generic);
    expect(describeError(null, fr)).toBe(fr.errors.generic);
    expect(describeError({ code: "functions/permission-denied" }, fr)).toBe(fr.errors.permission);
  });
});
