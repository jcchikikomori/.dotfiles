---
name: reactjs
description: React.js best practices, hooks, state management, component patterns, performance, and team coding conventions.
---

# React.js Skill

## Component Design

- Write **functional components** exclusively — no class components in new code.
- Keep components small and single-purpose (≤ ~150 lines is a good signal to split).
- Separate presentational (dumb) from container (smart) components.
- Export named components; avoid default exports for components.
- Use `React.memo` for expensive pure components — profile before applying.
- Follow existing code style and conventions in the project — consistency over strict adherence.
- Apply KISS & DRY, but prioritize consistency with existing code.

## Hooks

- Follow the Rules of Hooks: only call at the top level, only in React functions.
- `useState` for local UI state; `useReducer` for complex state logic.
- `useEffect` for side effects only; always specify a dependency array; return cleanup functions.
- Avoid stale closures: include all reactive values in the dependency array.
- Extract reusable logic into **custom hooks** (`use` prefix).
- Use `useCallback` and `useMemo` after profiling — don't prematurely optimize.

## State Management

- Prefer co-located state; lift only as needed.
- Use **React Context** for low-frequency shared state (theme, auth).
- Use **Zustand** (preferred) or Redux Toolkit for complex client state.
- Use **TanStack Query** (React Query) for server state — avoid duplicating server data in Redux.
- Never mutate state directly — always return new references.

## TypeScript

- Type all props with interfaces or `type` aliases — avoid `any`.
- Type event handlers explicitly: `React.ChangeEvent<HTMLInputElement>`.
- Use `React.ReactNode` for children prop typing.

## Forms

- Use **React Hook Form** for form management.
- Validate with **Zod** via `@hookform/resolvers/zod`.
- Show validation errors inline next to fields.

## Security

- Never use `dangerouslySetInnerHTML` with user-controlled content — XSS risk.
- Validate all user input on both client and server sides.
- Never store sensitive data (tokens, PII) in `localStorage` — prefer `httpOnly` cookies.

## Performance

- Use `React.lazy` + `Suspense` for route-level code splitting.
- Virtualize long lists with `@tanstack/react-virtual`.
- Use the React DevTools Profiler before optimizing.

## Accessibility (a11y)

- Use semantic HTML elements; avoid unnecessary `div`/`span` wrappers.
- Ensure keyboard navigability for all interactive elements.
- Use `aria-*` attributes only when semantic HTML is insufficient.
- Test with `eslint-plugin-jsx-a11y`.

## Testing

- Use **Vitest** + **React Testing Library** (RTL).
- Test behavior, not implementation — query by role/label/text, not by class or test ID.
- Use `userEvent` over `fireEvent`.
- Mock API calls with **MSW** (Mock Service Worker).
- Expectations compare to **literal values**, not method calls.
- Target **≥95% coverage** on business logic and component behavior.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Tooling

- Scaffold with **Vite** — avoid CRA for new projects.
- Lint with ESLint + `eslint-plugin-react`, `eslint-plugin-react-hooks`, `eslint-plugin-jsx-a11y`.
- Format with Prettier.
