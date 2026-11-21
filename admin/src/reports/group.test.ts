import { describe, expect, it } from "vitest";
import { report } from "../test/fakes";
import { groupReports } from "./group";

describe("groupReports", () => {
  it("groups by target with a count and a reason tally", () => {
    const g = groupReports([
      report({ id: "a", targetKey: "l1", reason: "scam" }),
      report({ id: "b", targetKey: "l1", reason: "scam" }),
      report({ id: "c", targetKey: "l1", reason: "fake" }),
      report({ id: "d", targetKey: "l2" }),
    ]);
    expect(g).toHaveLength(2);
    expect(g[0]).toMatchObject({ targetKey: "l1", count: 3, reasons: { scam: 2, fake: 1 } });
    expect(g[1]).toMatchObject({ targetKey: "l2", count: 1 });
  });

  it("a listing and a provider with the same id are different targets", () => {
    const g = groupReports([
      report({ id: "a", targetType: "listing", targetKey: "x" }),
      report({ id: "b", targetType: "provider", targetKey: "x" }),
    ]);
    expect(g).toHaveLength(2);
  });

  it("orders by count, then by the most recent report", () => {
    const g = groupReports([
      report({ id: "a", targetKey: "old", createdAt: new Date("2026-11-01") }),
      report({ id: "b", targetKey: "new", createdAt: new Date("2026-11-10") }),
      report({ id: "c", targetKey: "popular", createdAt: new Date("2026-10-01") }),
      report({ id: "d", targetKey: "popular", createdAt: new Date("2026-10-02") }),
    ]);
    expect(g.map((x) => x.targetKey)).toEqual(["popular", "new", "old"]);
  });

  it("keeps up to three non-empty details, newest first, and a report id to dismiss", () => {
    const g = groupReports([
      report({ id: "1", details: "first", createdAt: new Date("2026-11-01") }),
      report({ id: "2", details: "  ", createdAt: new Date("2026-11-02") }),
      report({ id: "3", details: "third", createdAt: new Date("2026-11-03") }),
      report({ id: "4", details: "fourth", createdAt: new Date("2026-11-04") }),
      report({ id: "5", details: "fifth", createdAt: new Date("2026-11-05") }),
    ])[0];
    expect(g.details).toEqual(["fifth", "fourth", "third"]);
    expect(g.latestAt).toEqual(new Date("2026-11-05"));
    expect(["1", "2", "3", "4", "5"]).toContain(g.dismissReportId);
  });

  it("handles reports without a date and an empty list", () => {
    expect(groupReports([])).toEqual([]);
    expect(groupReports([report({ id: "a", createdAt: null })])[0].latestAt).toBeNull();
  });
});
