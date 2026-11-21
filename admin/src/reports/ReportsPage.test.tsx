import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { I18nProvider } from "../i18n/I18nProvider";
import { en, fr } from "../i18n/strings";
import { fakeApi, report } from "../test/fakes";
import type { ListingTarget, ProviderTarget } from "../services/types";
import { availableActions } from "./ReportGroupCard";
import { ReportsPage } from "./ReportsPage";

const listing = (over: Partial<ListingTarget> = {}): ListingTarget => ({
  kind: "listing", id: "l1", title: "Réparation de fuite", photoUrl: "https://x/p.jpg",
  status: "active", moderation: "ok", moderationReason: null, providerId: "p1", ...over,
});
const provider = (over: Partial<ProviderTarget> = {}): ProviderTarget => ({
  kind: "provider", id: "p1", displayName: "Jean Plomberie", photoUrl: null, status: "approved", ...over,
});

const renderPage = (api: ReturnType<typeof fakeApi>["api"], lang: "en" | "fr" = "en") =>
  render(
    <I18nProvider initial={lang}>
      <ReportsPage api={api} />
    </I18nProvider>,
  );

const seed = () =>
  fakeApi({
    reports: [
      report({ id: "a", targetKey: "l1", reason: "scam", details: "Demande un acompte" }),
      report({ id: "b", targetKey: "l1", reason: "scam" }),
      report({ id: "c", targetKey: "l1", reason: "fake" }),
      report({ id: "d", targetType: "provider", targetKey: "p1", reason: "other" }),
    ],
    targets: { "listing:l1": listing(), "provider:p1": provider() },
  });

describe("ReportsPage", () => {
  it("shows a loading state, then the groups with count, target and photo", async () => {
    const { api } = seed();
    renderPage(api);
    expect(screen.getByText(en.reports.loading)).toBeInTheDocument();
    const card = await screen.findByRole("article", { name: "Réparation de fuite" });
    expect(within(card).getByText(en.reports.count(3))).toBeInTheDocument();
    expect(within(card).getByText(`${en.reports.reasons.scam} · 2`)).toBeInTheDocument();
    expect(within(card).getByText("“Demande un acompte”")).toBeInTheDocument();
    expect(card.querySelector("img")).toHaveAttribute("src", "https://x/p.jpg");
    const pcard = screen.getByRole("article", { name: "Jean Plomberie" });
    expect(within(pcard).getByText(en.reports.count(1))).toBeInTheDocument();
    // most reported first
    const titles = screen.getAllByRole("heading", { level: 3 }).map((h) => h.textContent);
    expect(titles).toEqual(["Réparation de fuite", "Jean Plomberie"]);
  });

  it("renders in French", async () => {
    const { api } = seed();
    renderPage(api, "fr");
    expect(await screen.findByText(fr.reports.title)).toBeInTheDocument();
    expect(screen.getAllByRole("button", { name: fr.reports.actions.dismiss }).length).toBeGreaterThan(0);
  });

  it("shows the empty state", async () => {
    renderPage(fakeApi().api);
    expect(await screen.findByText(en.reports.empty)).toBeInTheDocument();
  });

  it("shows a load error with a retry", async () => {
    const { api } = fakeApi();
    api.listOpenReports.mockRejectedValueOnce(new Error("offline"));
    renderPage(api);
    expect(await screen.findByText(en.reports.loadFailed)).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: en.reports.retry }));
    expect(await screen.findByText(en.reports.empty)).toBeInTheDocument();
  });

  describe("actions", () => {
    it("hide: confirm dialog, loading, success toast and a refreshed list", async () => {
      const { api } = seed();
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.hide }));

      const dialog = screen.getByRole("dialog");
      expect(within(dialog).getByText(en.dialog.hideTitle)).toBeInTheDocument();
      expect(api.hideListing).not.toHaveBeenCalled(); // nothing before confirming

      await userEvent.type(within(dialog).getByRole("textbox"), "  arnaque avérée ");
      await userEvent.click(within(dialog).getByRole("button", { name: en.reports.actions.hide }));

      await waitFor(() => expect(api.hideListing).toHaveBeenCalledWith("l1", "arnaque avérée"));
      expect(await screen.findByText(en.reports.toasts.hidden)).toBeInTheDocument();
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
      expect(api.listOpenReports).toHaveBeenCalledTimes(2); // refreshed
    });

    it("cancel closes the dialog without calling anything", async () => {
      const { api } = seed();
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.hide }));
      await userEvent.click(screen.getByRole("button", { name: en.dialog.cancel }));
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
      expect(api.hideListing).not.toHaveBeenCalled();
    });

    it("a hidden listing offers Restore, which calls the restore callable", async () => {
      const { api } = fakeApi({
        reports: [report({ id: "a" })],
        targets: { "listing:l1": listing({ moderation: "hidden", moderationReason: "auto_reports" }) },
      });
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      expect(within(card).queryByRole("button", { name: en.reports.actions.hide })).not.toBeInTheDocument();
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.restore }));
      await userEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: en.reports.actions.restore }));
      await waitFor(() => expect(api.restoreListing).toHaveBeenCalledWith("l1", undefined));
      expect(await screen.findByText(en.reports.toasts.restored)).toBeInTheDocument();
    });

    it("restore is disabled for an over_limit hide", async () => {
      const { api } = fakeApi({
        reports: [report({ id: "a" })],
        targets: { "listing:l1": listing({ moderation: "hidden", moderationReason: "over_limit" }) },
      });
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      expect(within(card).getByRole("button", { name: en.reports.actions.restore })).toBeDisabled();
      expect(within(card).getByText(en.reports.restoreBlocked)).toBeInTheDocument();
    });

    it("suspend needs a reason of at least three characters", async () => {
      const { api } = seed();
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Jean Plomberie" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.suspend }));
      const dialog = screen.getByRole("dialog");
      const confirm = within(dialog).getByRole("button", { name: en.reports.actions.suspend });
      expect(confirm).toBeDisabled();
      await userEvent.type(within(dialog).getByRole("textbox"), "ab");
      expect(confirm).toBeDisabled();
      await userEvent.type(within(dialog).getByRole("textbox"), "c");
      expect(confirm).toBeEnabled();
      await userEvent.click(confirm);
      await waitFor(() => expect(api.suspendProvider).toHaveBeenCalledWith("p1", "abc"));
      expect(await screen.findByText(en.reports.toasts.suspended)).toBeInTheDocument();
    });

    it("an already suspended provider can only be dismissed", async () => {
      const { api } = fakeApi({
        reports: [report({ id: "a", targetType: "provider", targetKey: "p1" })],
        targets: { "provider:p1": provider({ status: "suspended" }) },
      });
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Jean Plomberie" });
      expect(within(card).queryByRole("button", { name: en.reports.actions.suspend })).not.toBeInTheDocument();
      expect(within(card).getByRole("button", { name: en.reports.actions.dismiss })).toBeInTheDocument();
    });

    it("dismiss closes every report on the target and says how many", async () => {
      const { api } = seed();
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.dismiss }));
      expect(within(screen.getByRole("dialog")).getByText(en.dialog.dismissBody(3))).toBeInTheDocument();
      await userEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: en.reports.actions.dismiss }));
      await waitFor(() => expect(api.dismissReport).toHaveBeenCalledTimes(1));
      expect(["a", "b", "c"]).toContain(api.dismissReport.mock.calls[0][0]);
      expect(await screen.findByText(en.reports.toasts.dismissed(2))).toBeInTheDocument();
    });

    it("a deleted target can only be dismissed", async () => {
      const { api } = fakeApi({ reports: [report({ id: "a", targetKey: "gone" })] });
      renderPage(api);
      const card = await screen.findByRole("article", { name: en.reports.deletedTarget });
      expect(within(card).getAllByRole("button")).toHaveLength(1);
      expect(within(card).getByRole("button", { name: en.reports.actions.dismiss })).toBeInTheDocument();
    });

    it("an error keeps the dialog open with a localised message, and can be retried", async () => {
      const { api } = seed();
      api.hideListing.mockRejectedValueOnce({ code: "functions/permission-denied", message: "x" });
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.hide }));
      const dialog = screen.getByRole("dialog");
      await userEvent.click(within(dialog).getByRole("button", { name: en.reports.actions.hide }));
      expect(await within(dialog).findByRole("alert")).toHaveTextContent(en.errors.permission);
      expect(screen.getByRole("dialog")).toBeInTheDocument();
      expect(screen.queryByText(en.reports.toasts.hidden)).not.toBeInTheDocument();

      await userEvent.click(within(dialog).getByRole("button", { name: en.reports.actions.hide }));
      expect(await screen.findByText(en.reports.toasts.hidden)).toBeInTheDocument();
    });

    it("disables the dialog buttons while the call is running", async () => {
      const { api } = seed();
      let release: () => void = () => {};
      api.hideListing.mockImplementationOnce(() => new Promise((r) => { release = () => r({ resolvedReports: 1 }); }));
      renderPage(api);
      const card = await screen.findByRole("article", { name: "Réparation de fuite" });
      await userEvent.click(within(card).getByRole("button", { name: en.reports.actions.hide }));
      const dialog = screen.getByRole("dialog");
      await userEvent.click(within(dialog).getByRole("button", { name: en.reports.actions.hide }));
      expect(await within(dialog).findByRole("button", { name: en.dialog.working })).toBeDisabled();
      expect(within(dialog).getByRole("button", { name: en.dialog.cancel })).toBeDisabled();
      release();
      expect(await screen.findByText(en.reports.toasts.hidden)).toBeInTheDocument();
    });
  });
});

describe("availableActions", () => {
  it("depends on the target kind and state", () => {
    expect(availableActions(null)).toEqual(["dismiss"]);
    expect(availableActions(listing())).toEqual(["hide", "dismiss"]);
    expect(availableActions(listing({ moderation: "hidden" }))).toEqual(["restore", "dismiss"]);
    expect(availableActions(provider())).toEqual(["suspend", "dismiss"]);
    expect(availableActions(provider({ status: "suspended" }))).toEqual(["dismiss"]);
  });
});
