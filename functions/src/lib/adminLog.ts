import { FieldValue, type Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";

export interface AdminLogEntry {
  /** Staff uid, or "system" for automatic actions. */
  actorUid: string;
  action: string;
  targetType: string;
  targetId: string;
  before?: Record<string, unknown>;
  after?: Record<string, unknown>;
  note?: string;
}

/** Appends to `adminLogs` (TDD §4.12). Ids and statuses only, no personal data. */
export async function writeAdminLog(db: Firestore, entry: AdminLogEntry): Promise<void> {
  // Firestore rejects `undefined`: drop optional fields that were not given.
  const clean = Object.fromEntries(Object.entries(entry).filter(([, v]) => v !== undefined));
  await db.collection("adminLogs").add({ ...clean, createdAt: FieldValue.serverTimestamp() });
}
