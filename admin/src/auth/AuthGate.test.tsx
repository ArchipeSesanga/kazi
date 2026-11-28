import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { I18nProvider } from "../i18n/I18nProvider";
import { en } from "../i18n/strings";
import { FakeAuth } from "../test/fakes";
import { AuthGate } from "./AuthGate";
import { loginErrorKey } from "./LoginPage";
import { roleOf } from "./claims";

const renderGate = (auth: FakeAuth) =>
  render(
    <I18nProvider initial="en">
      <AuthGate auth={auth}>{(s) => <div>APP as {s.role}</div>}</AuthGate>
    </I18nProvider>,
  );

describe("roleOf", () => {
  it("only admin and moderator are staff", () => {
    expect(roleOf({ admin: true })).toBe("admin");
    expect(roleOf({ moderator: true })).toBe("moderator");
    expect(roleOf({ admin: true, moderator: true })).toBe("admin");
    expect(roleOf({})).toBeNull();
    expect(roleOf({ admin: "true", moderator: 1 })).toBeNull();
    expect(roleOf(null)).toBeNull();
  });
});

describe("AuthGate", () => {
  it("shows the login form when nobody is signed in", async () => {
    renderGate(new FakeAuth());
    expect(await screen.findByRole("button", { name: en.login.submit })).toBeInTheDocument();
  });

  it.each([
    ["admin", { admin: true }],
    ["moderator", { moderator: true }],
  ])("lets a %s in after sign-in", async (role, claims) => {
    const auth = new FakeAuth();
    auth.claimsValue = claims;
    renderGate(auth);
    await userEvent.type(await screen.findByLabelText(en.login.email), "staff@kazi.test");
    await userEvent.type(screen.getByLabelText(en.login.password), "secret");
    await userEvent.click(screen.getByRole("button", { name: en.login.submit }));
    expect(await screen.findByText(`APP as ${role}`)).toBeInTheDocument();
    expect(auth.signOutCalls).toBe(0);
  });

  it("signs out anyone who is not staff and says why", async () => {
    const auth = new FakeAuth();
    auth.claimsValue = { phone_number: "+243810000001" };
    renderGate(auth);
    await userEvent.type(await screen.findByLabelText(en.login.email), "user@example.com");
    await userEvent.type(screen.getByLabelText(en.login.password), "secret");
    await userEvent.click(screen.getByRole("button", { name: en.login.submit }));
    expect(await screen.findByText(en.login.denied)).toBeInTheDocument();
    expect(screen.queryByText(/APP as/)).not.toBeInTheDocument();
    expect(auth.signOutCalls).toBe(1);
    expect(auth.user).toBeNull();
  });

  it("re-checks claims for a session restored on page load", async () => {
    const auth = new FakeAuth();
    auth.user = { uid: "u1", email: "x@y.z" };
    auth.claimsValue = {};
    renderGate(auth);
    expect(await screen.findByText(en.login.denied)).toBeInTheDocument();
    expect(auth.signOutCalls).toBe(1);
  });

  it("fails closed when the claims cannot be read", async () => {
    const auth = new FakeAuth();
    auth.user = { uid: "u1", email: "x@y.z" };
    auth.claimsError = true;
    renderGate(auth);
    expect(await screen.findByText(en.login.denied)).toBeInTheDocument();
    expect(screen.queryByText(/APP as/)).not.toBeInTheDocument();
  });

  it("shows a message for wrong credentials and stays on the form", async () => {
    renderGate(new FakeAuth());
    await userEvent.type(await screen.findByLabelText(en.login.email), "a@b.cd");
    await userEvent.type(screen.getByLabelText(en.login.password), "wrong");
    await userEvent.click(screen.getByRole("button", { name: en.login.submit }));
    expect(await screen.findByText(en.login.errors.credentials)).toBeInTheDocument();
    await waitFor(() => expect(screen.getByRole("button", { name: en.login.submit })).toBeEnabled());
  });
});

describe("loginErrorKey", () => {
  it("maps Firebase Auth codes", () => {
    expect(loginErrorKey({ code: "auth/invalid-credential" })).toBe("credentials");
    expect(loginErrorKey({ code: "auth/too-many-requests" })).toBe("tooMany");
    expect(loginErrorKey({ code: "auth/network-request-failed" })).toBe("network");
    expect(loginErrorKey(new Error("x"))).toBe("generic");
  });
});
