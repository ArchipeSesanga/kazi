import { getApps, initializeApp } from "firebase-admin/app";

// Every function module imports this first so the admin app is
// initialized exactly once per process, regardless of import order.
if (getApps().length === 0) {
  initializeApp();
}
