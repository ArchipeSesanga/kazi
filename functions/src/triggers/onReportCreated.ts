import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { applyAutoHide } from "../lib/autoHide.js";

/** TDD §6.1: hide a target once it has 3 open reports from distinct users. */
export const onReportCreated = onDocumentCreated(
  { document: "reports/{reportId}", region: REGION },
  async (event) => {
    const report = event.data?.data();
    if (!report) return;
    const result = await applyAutoHide(getFirestore(), {
      targetType: String(report.targetType),
      targetKey: String(report.targetKey),
    });
    logger.info("onReportCreated", { targetType: report.targetType, ...result });
  },
);
