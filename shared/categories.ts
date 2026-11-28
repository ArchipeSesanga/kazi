/**
 * The category taxonomy and its seeding, shared by `scripts/seed-categories.ts`
 * (kazi-dev) and the functions tests. No imports from firebase-*: callers pass
 * their own Firestore instance, so each package keeps its own firebase-admin.
 *
 * The list itself lives in ONE file, `assets/data/categories.json`, which the
 * Flutter app also bundles as its offline fallback.
 *
 * Rules of the taxonomy (TDD §4.10):
 *  - the slug is the document id and is PERMANENT once data exists: never
 *    rename an id; rename only `names`, and retire with `active: false`;
 *  - `iconKey` maps to a Material icon in the app (unknown keys fall back);
 *  - `featured` categories (8) are the ones Home shows; `autres` is always last.
 */
import taxonomy from "../assets/data/categories.json";

export const LANGS = ["fr", "en", "ln", "sw"] as const;
export type Lang = (typeof LANGS)[number];

export interface CategorySeed {
  id: string;
  names: { fr: string; en: string };
  iconKey: string;
  order: number;
  featured: boolean;
  active: boolean;
  synonyms: Record<Lang, string[]>;
}

export const CATEGORIES: CategorySeed[] = taxonomy as CategorySeed[];
export const FEATURED_COUNT = 8;
export const LAST_CATEGORY_ID = "autres";
export const SYNONYMS_MIN = 4;
export const SYNONYMS_MAX = 8;
const SLUG = /^[a-z0-9]+(-[a-z0-9]+)*$/;

/** Placeholder ids of the early dev data → the real category that replaces them. */
export const LEGACY_CATEGORY_MAP: Record<string, string> = {
  coiffure_beaute: "coiffure",
  mecanique_auto: "mecanique-auto",
  reparation_telephones: "telephones",
  cours_particuliers: "cours",
  climatisation: "froid-clim",
  transport_demenagement: "transport",
  evenementiel: "evenements",
  cuisine_traiteur: "evenements",
  garde_enfants: "autres",
};

/** Every problem with a taxonomy; empty when it is valid. */
export function validateCategories(list: CategorySeed[] = CATEGORIES): string[] {
  const problems: string[] = [];
  const ids = new Set<string>();
  const orders = new Set<number>();
  for (const c of list) {
    if (!SLUG.test(c.id) || c.id.length < 2 || c.id.length > 40) problems.push(`${c.id}: bad slug`);
    if (ids.has(c.id)) problems.push(`${c.id}: duplicate id`);
    ids.add(c.id);
    if (orders.has(c.order)) problems.push(`${c.id}: duplicate order ${c.order}`);
    orders.add(c.order);
    if (!c.names.fr || !c.names.en) problems.push(`${c.id}: missing name`);
    if (!c.iconKey) problems.push(`${c.id}: missing iconKey`);
    for (const lang of ["fr", "en"] as const) {
      const n = c.synonyms[lang].length;
      if (n < SYNONYMS_MIN || n > SYNONYMS_MAX) problems.push(`${c.id}: ${n} ${lang} synonyms`);
    }
    if (c.synonyms.ln.length || c.synonyms.sw.length) problems.push(`${c.id}: ln/sw must stay empty for now`);
  }
  const featured = list.filter((c) => c.featured && c.active).length;
  if (featured !== FEATURED_COUNT) problems.push(`${featured} featured categories, expected ${FEATURED_COUNT}`);
  const last = [...list].sort((a, b) => b.order - a.order)[0];
  if (last?.id !== LAST_CATEGORY_ID) problems.push(`${LAST_CATEGORY_ID} must be last`);
  return problems;
}

/** Every searchable word of a category: names + synonyms in every language. */
export function categorySearchTerms(c: {
  names?: { fr?: string; en?: string };
  synonyms?: Partial<Record<Lang, string[]>>;
}): string[] {
  return [
    c.names?.fr,
    c.names?.en,
    ...LANGS.flatMap((l) => c.synonyms?.[l] ?? []),
  ].filter((s): s is string => typeof s === "string" && s !== "");
}

/* eslint-disable @typescript-eslint/no-explicit-any */
type AnyDb = { collection(name: string): any; batch(): any };

export interface SeedOptions {
  /** `FieldValue.delete()` of the caller's firebase-admin. */
  deleteField: unknown;
  /**
   * Dev only: delete categories that are not in the list (old placeholders)
   * and remap legacy ids on providers and listings. Otherwise a stale
   * category is only retired (`active: false`), never deleted.
   */
  wipeUnknown?: boolean;
  list?: CategorySeed[];
}

export interface SeedReport {
  upserted: number;
  retired: string[];
  deleted: string[];
  remapped: { providers: number; listings: number };
}

/**
 * Idempotent: running it twice leaves the same documents. Only the static
 * fields are written (merge); the server-managed `listingCount` is created at
 * 0 and never touched again; legacy `name` / `icon` fields are removed.
 */
export async function seedCategories(db: AnyDb, opts: SeedOptions): Promise<SeedReport> {
  const list = opts.list ?? CATEGORIES;
  const problems = validateCategories(list);
  if (problems.length) throw new Error(`Invalid taxonomy:\n${problems.join("\n")}`);

  const col = db.collection("categories");
  const existing = new Map<string, any>();
  (await col.get()).forEach((d: any) => existing.set(d.id, d.data()));

  const report: SeedReport = { upserted: 0, retired: [], deleted: [], remapped: { providers: 0, listings: 0 } };
  const batch = db.batch();
  for (const c of list) {
    const { id, ...fields } = c;
    batch.set(
      col.doc(id),
      {
        ...fields,
        name: opts.deleteField,
        icon: opts.deleteField,
        ...(existing.has(id) ? {} : { listingCount: 0 }),
      },
      { merge: true },
    );
    report.upserted++;
  }
  const known = new Set(list.map((c) => c.id));
  for (const [id, data] of existing) {
    if (known.has(id)) continue;
    if (opts.wipeUnknown) {
      batch.delete(col.doc(id));
      report.deleted.push(id);
    } else if (data?.active !== false) {
      batch.set(col.doc(id), { active: false }, { merge: true });
      report.retired.push(id);
    }
  }
  await batch.commit();

  if (opts.wipeUnknown) report.remapped = await remapLegacyCategories(db);
  return report;
}

/** Points providers and listings that still use a placeholder id at its replacement. */
export async function remapLegacyCategories(db: AnyDb): Promise<{ providers: number; listings: number }> {
  const out = { providers: 0, listings: 0 };
  const legacy = Object.keys(LEGACY_CATEGORY_MAP);
  for (let i = 0; i < legacy.length; i += 10) {
    const ids = legacy.slice(i, i + 10);
    const listings = await db.collection("listings").where("categoryId", "in", ids).get();
    for (const d of listings.docs) {
      await d.ref.update({ categoryId: LEGACY_CATEGORY_MAP[d.data().categoryId] });
      out.listings++;
    }
    const providers = await db.collection("providers").where("categoryIds", "array-contains-any", ids).get();
    for (const d of providers.docs) {
      const mapped = (d.data().categoryIds as string[]).map((c) => LEGACY_CATEGORY_MAP[c] ?? c);
      await d.ref.update({ categoryIds: [...new Set(mapped)].slice(0, 3) });
      out.providers++;
    }
  }
  return out;
}
