# FreshCart Web — customer storefront

[![CI](https://github.com/amasen02/freshcart-web/actions/workflows/ci.yml/badge.svg)](https://github.com/amasen02/freshcart-web/actions/workflows/ci.yml)
[![Angular](https://img.shields.io/badge/Angular-20-red)](https://angular.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178c6)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING.md)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-blue)](CODE_OF_CONDUCT.md)

The Angular 20 storefront for **[FreshCart](https://github.com/amasen02/freshcart-backend)**, a
production-grade microservices reference platform. This repository holds the frontend only; the
backend (12 .NET services, the YARP gateway, infrastructure and deployment) lives in the
companion repo:

> **Backend / platform:** https://github.com/amasen02/freshcart-backend

It is a zoneless, signal-based single-page application that talks only to the YARP gateway. The
browser holds an **HttpOnly** session cookie issued by the Identity service; no access tokens
ever reach JavaScript. State-changing requests carry the XSRF double-submit header.

---

## Run it

The storefront needs the gateway (and the services behind it) running. Start the backend first —
clone [`amasen02/freshcart-backend`](https://github.com/amasen02/freshcart-backend) and boot the platform with the
Aspire AppHost or Docker Compose (see that repo's README), which exposes the gateway on
`https://localhost:7100` and seeds the demo accounts.

Then run the SPA:

```bash
npm ci
npm start          # ng serve with proxy.conf.json -> http://localhost:4200
```

`npm start` proxies `/api` and `/hubs` to the gateway on `https://localhost:7100`
(see [`proxy.conf.json`](proxy.conf.json)). Open <http://localhost:4200>.

```bash
npm run build      # production bundle -> dist/freshcart-customer/browser
npm test           # Karma + Jasmine unit tests (ChromeHeadless)
npm run lint       # eslint + angular template rules
```

### Container

A hardened, non-root nginx image serves the static bundle:

```bash
docker build -t freshcart-web .
docker run --rm -p 8080:80 freshcart-web   # http://localhost:8080
```

In Kubernetes the ingress routes `/api` and `/hubs` to the gateway; nginx here serves only the
static application shell and the SPA fallback.

---

## Sign in with a seeded account

The backend's `IdentityDataSeeder` creates these on first boot in `Development` only (it refuses
to run elsewhere, and the sign-up validator rejects any `*.test` email — they cannot exist in
Staging or Production):

| Role | Email | Password | What this account can do |
|---|---|---|---|
| **Customer** | `demo@freshcart.test` | `Demo-P@ssw0rd-2026` | Browse catalog, add to basket, check out, view orders, chat to support |
| **SupportAgent** | `support@freshcart.test` | `Support-P@ssw0rd-2026` | Answer support chats from `/support/console` |
| **Administrator** | `admin@freshcart.test` | `Admin-P@ssw0rd-2026` | Reporting dashboards (consumed via the Reporting API) |

---

## Architecture

```
src/app/
  core/        cross-cutting singletons: auth store, HTTP interceptors, error handler,
               toast service, basket store, realtime (SignalR) connection + notifications store,
               api-routes registry, injectable clock and timing tokens, title strategy
  shared/      reusable presentational pieces: pipes, directives, dialog service,
               loading/empty/not-found/rating components
  layout/      app shell, header, footer, toast host, notification bell
  features/    lazy-loaded routes: home, catalog, basket, checkout, orders, account,
               dashboard, auth, support
```

State lives in one store per concern. `AuthStore`, `BasketStore`, `NotificationsStore` and
`SupportChatStore` are root `@ngrx/signals` stores; feature-local state such as the product list
uses a feature-scoped signal store. Synchronous state is held in signals; RxJS is used only for
genuinely asynchronous streams (HTTP, SignalR) and is terminated at the component boundary.

### Realtime

`SignalrConnectionFactory` builds a `HubConnection` per hub path with cookie credentials,
automatic reconnect, and warning-level logging. `RealtimeConnection` wraps it, exposing the
connection state as a signal and serialising start/stop.

`NotificationsStore` opens `/hubs/notifications` when `AuthStore` reports an authenticated
session and stops, deregisters every handler, and clears its state on sign-out. Incoming
notifications prepend to the list and raise a toast for order-status types; the
`salesDashboardUpdated` broadcast increments a tick that the dashboard observes for a coalesced
refresh. The notification bell renders the unread count and a reconnecting indicator.

`SupportChatStore` opens `/hubs/support` lazily on the first widget open. It resumes an active
session on reopen, appends messages only on the server echo (no optimistic insert), and reports
typing as an immediate `true` followed by a debounced trailing `false`. The agent console
(`/support/console`, role SupportAgent) reuses the same `ChatThreadComponent` over a multi-session
store. The order-confirmation page consumes notifications for live status updates and keeps a
bounded polling fallback for the unauthenticated-hub case.

All hub method and event names are pinned in dedicated constant files so they match the server
contract exactly.

---

## Security model

- **No tokens in JavaScript.** Authentication is an HttpOnly, Secure, SameSite session cookie set
  by Identity through the gateway's cookie-to-JWT BFF exchange.
- **XSRF double-submit.** A readable `XSRF-TOKEN` cookie is echoed in the `X-XSRF-TOKEN` header on
  every state-changing request (`credentials.interceptor`).
- **Strict CSP.** `default-src 'self'` with no inline and no third-party scripts, and
  `connect-src 'self'` so XHR and the SignalR WebSocket may only reach this origin. It is sent as
  an nginx response header ([`nginx.conf`](nginx.conf)) and mirrored in the app shell
  ([`src/index.html`](src/index.html)) so it also applies under `ng serve` and on a static host.
  The one third-party origin is `picsum.photos` in `img-src`, the fallback product photography.
  User content is rendered through Angular's sanitiser, never `innerHTML`.

---

## Contributing

Contributions are welcome — bug fixes, accessibility improvements, sharper patterns, better docs.
Read [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow and coding bar, and please be mindful of
the [Code of Conduct](CODE_OF_CONDUCT.md). Use the issue templates; green CI (`lint` + `test` +
`build`) is required on every pull request. Report security issues privately per
[`SECURITY.md`](SECURITY.md) — never as a public issue.

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — branch/commit/PR workflow and coding standards.
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — Contributor Covenant 2.1.
- [`SECURITY.md`](SECURITY.md) — coordinated vulnerability disclosure.

## Open source commitments

This project is, and will remain, free and open source. As maintainer I commit to:

- **A permissive licence, kept stable.** [MIT](LICENSE) — use it commercially, fork it, build on
  it. No relicensing of accepted contributions.
- **No CLA.** Contributions are accepted under the MIT licence; you keep the copyright to your work.
- **An honest history.** Real, walkable commits — no fabricated activity, no rewritten releases.
- **Best-effort, transparent triage.** Issues and pull requests are read and answered; security
  reports are acknowledged within 72 hours.
- **A welcoming community** governed by the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Reproducible builds.** Green CI — lint, unit tests, production build, and a scanned container
  image — on every change.

---

## License

MIT — see [`LICENSE`](LICENSE). You are free to use, modify, and distribute this software,
including for commercial purposes, provided the copyright notice is retained.

## Author

**Ama Senevirathne** — Senior Software Engineer & Tech Lead.

- [GitHub](https://github.com/amasen02)
- Backend / platform: [amasen02/freshcart-backend](https://github.com/amasen02/freshcart-backend)
