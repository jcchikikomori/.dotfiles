---
name: angularjs
description: AngularJS (1.x) coding conventions, component patterns, security, and migration guidance to Angular 2+.
---

# AngularJS Skill

> **Note:** AngularJS (1.x) is in Long-Term Support (LTS). New projects should use Angular (2+). These guidelines cover maintaining legacy AngularJS code and migrating it incrementally to modern Angular.

## Code Style & Conventions

- Follow the **John Papa AngularJS Style Guide** as the canonical reference.
- One component / controller / service per file.
- Use **IIFE** wrappers to avoid polluting the global scope.
- Use the `controllerAs` syntax (`vm` alias) instead of `$scope` in controllers.
- Name files: `feature.type.js` (e.g., `user.controller.js`, `auth.service.js`).
- Prefix custom directives with a short app-specific namespace (e.g., `app-user-card`).
- Follow existing code style and conventions in the project — consistency over strict adherence.

## Components & Controllers

- Prefer the `.component()` API (AngularJS 1.5+) over `.directive()` for UI components.
- Keep controllers thin: delegate business logic to services.
- Avoid `$rootScope` — use services or `$broadcast`/`$on` sparingly.
- Use one-time binding (`::`) for static values to reduce watcher count.

## Services & Factories

- Use `.service()` for singleton classes; `.factory()` for objects with private state.
- Abstract all `$http` calls into dedicated service files — never call `$http` from controllers.
- Use `$q` for promise chaining.

## Routing

- Use `ui-router` (preferred) for routing.
- Define states in a dedicated `app.routes.js` file.
- Use `resolve` to pre-fetch data before a route activates.

## Dependency Injection

Always use array annotation or `$inject` for minification safety:

```js
MyController.$inject = ['$scope', 'UserService'];
function MyController($scope, UserService) { ... }
```

## Security (OWASP)

- Never trust user input — validate on both client and server sides.
- Avoid `$sce.trustAsHtml()` with user-controlled content — XSS risk.
- Use parameterized server-side queries — never interpolate user input into SQL.
- Never store sensitive data (tokens, PII) in `localStorage` — prefer `httpOnly` cookies.
- Apply OWASP principles: least privilege, fail securely, defence in depth.

## Performance

- Minimize watcher count — keep `$watch` instances low.
- Use `track by` in `ng-repeat` to avoid unnecessary DOM re-creation.
- Avoid deeply nested scopes.
- Use one-time bindings (`::`) for display-only values.

## Testing

- Unit test with **Karma** + **Jasmine** (or Mocha).
- Use `angular-mocks` (`ngMock`) to inject and mock AngularJS services.
- Expectations compare to **literal values**, not method calls.
- Target **≥95% coverage** on controllers and services.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Migration Path to Angular 2+

- Adopt `.component()` API first — components map directly to Angular components.
- Use **ngUpgrade** for incremental migration (run both frameworks side by side).
- Migrate leaf components first, then work upward toward the root.
- Replace `$http` with Angular's `HttpClient` during migration.
- Replace `ui-router` with Angular Router or keep it via `@uirouter/angular`.
