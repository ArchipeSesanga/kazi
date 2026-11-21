import { FieldValue, type DocumentReference } from "firebase-admin/firestore";
import "./firebaseAdmin.js";

/**
 * Auto-approves a provider. Uses `update()`, never `set()`, so a provider
 * that was deleted in the meantime (for example by `deleteAccount`) is not
 * recreated. Returns false when the document no longer exists.
 */
export async function approveProviderIfExists(ref: DocumentReference): Promise<boolean> {
  try {
    await ref.update({ status: "approved", approvedAt: FieldValue.serverTimestamp() });
    return true;
  } catch (e) {
    if ((e as { code?: number }).code === 5) return false; // NOT_FOUND
    throw e;
  }
}
