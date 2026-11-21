import type { Firestore } from "firebase-admin/firestore";
import { DEFAULT_MAX_LISTINGS_PER_PROVIDER } from "../config.js";

/** Single source: Firestore `config/limits.maxListingsPerProvider`. */
export async function getMaxListingsPerProvider(db: Firestore): Promise<number> {
  const snap = await db.collection("config").doc("limits").get();
  const v = snap.data()?.maxListingsPerProvider;
  return typeof v === "number" && Number.isInteger(v) && v > 0
    ? v
    : DEFAULT_MAX_LISTINGS_PER_PROVIDER;
}
