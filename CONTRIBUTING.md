# Contributing to FreshCart Web

This is the Angular 20 storefront for the [FreshCart](https://github.com/amasen02/FreshCart)
platform. Pull requests are welcome where they fix a bug, sharpen a pattern, improve
accessibility, or improve documentation — provided they keep the senior-engineer tone of the
codebase.

> Backend issues (services, gateway, infrastructure) belong in the
> [FreshCart](https://github.com/amasen02/FreshCart) repository, not here.

## Ground rules

1. **One concern per pull request.** No drive-by refactors mixed with feature work.
2. **Branch from `master`**, keep the branch short, and squash-merge back.
3. **Conventional commits** (`feat(scope): …`, `fix(scope): …`, `chore(scope): …`,
   `docs(scope): …`, `refactor(scope): …`, `test(scope): …`, `perf(scope): …`).
4. **Green CI is non-negotiable.** `npm run lint`, `npm test`, and `npm run build` must all pass
   before review.
5. **No skipped hooks**, no `--no-verify`, no `[skip ci]` outside docs-only commits.
6. **The PR template must be filled.** Empty checkboxes block review.

## Coding standards

- **Angular 20, standalone components only** — no NgModules.
- **Signals for synchronous state** (`signal`, `computed`, `effect`); RxJS only for genuinely
  asynchronous streams (HTTP, SignalR), terminated at the component boundary.
- **Strict TypeScript.** No `any`, no untyped `Function`, no `as unknown as X` without a justified
  comment. `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` stay on.
- **`@if` / `@for` / `@switch`** control flow — never the legacy `*ngIf` / `*ngFor`.
- **`inject()`** over constructor injection in standalone components; functional guards and HTTP
  interceptors.
- **Full, descriptive identifiers.** `customerShoppingBasket`, not `cart`; `c`, `x`, `tmp` are
  rejected at review.
- **No filler comments.** Comments explain *why*, never *what*.
- **Accessibility is a requirement, not a nice-to-have.** ng-bootstrap widgets, keyboard
  reachability, and meaningful labels on interactive elements.

## Local development

The storefront needs the backend gateway running. Start the
[FreshCart](https://github.com/amasen02/FreshCart) platform first (Aspire AppHost or Docker
Compose), which exposes the gateway on `https://localhost:7100` and seeds the demo accounts.

```bash
npm ci
npm start          # ng serve with proxy.conf.json -> http://localhost:4200
npm run lint       # eslint + angular template rules
npm test           # Karma + Jasmine unit tests (ChromeHeadless)
npm run build      # production bundle
```

## Tests

A pull request that ships behaviour without a test is sent back unless it is purely documentation.
Add or update unit specs next to the code they cover (`*.spec.ts`).

## Reporting bugs and proposing features

Use the issue templates. For security vulnerabilities, **do not open a public issue** — follow
[`SECURITY.md`](SECURITY.md).
