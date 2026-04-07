---
name: vuejs
description: Vue.js 3 best practices, Composition API, Pinia, security, and team coding conventions.
---

# Vue.js Skill

## Version & Setup

- Target **Vue 3** for all new code — Vue 2 is EOL.
- Use **Vite** as the build tool; scaffold with `npm create vue@latest`.
- Use **TypeScript** (`<script setup lang="ts">`); enable strict mode.
- Use **Vue Router 4** for routing and **Pinia** for state management.

## Component Style

- Use **`<script setup>`** (Composition API) for all new components.
- Keep `<template>`, `<script setup>`, and `<style>` in that order in SFCs.
- Use `defineProps`, `defineEmits`, `defineExpose` macros with TypeScript types.
- Name components in **PascalCase** in `<script>` and in templates.
- Co-locate component styles with `<style scoped>`.
- Follow existing code style and conventions in the project — consistency over strict adherence.
- Apply KISS & DRY, but prioritize consistency with existing code.

## Reactivity

- Use `ref()` for primitives; `reactive()` or `ref()` for objects.
- Use `computed()` for derived state — never recalculate in templates.
- Use `watch()` for side effects; `watchEffect()` to track dependencies automatically.
- Avoid mutating props directly — emit events to the parent.

## Composition API Patterns

- Extract reusable logic into **composables** (`use` prefix, e.g., `useAuth.ts`).
- Composables return reactive state and actions.
- Use `provide` / `inject` for deep prop drilling; prefer Pinia for app-wide state.

## State Management (Pinia)

- One store per feature domain: `useUserStore`, `useCartStore`.
- State, getters, actions only — keep stores lean.
- Use `storeToRefs()` to destructure reactive state without losing reactivity.
- Do not mutate state outside of store actions.

## Routing (Vue Router 4)

- Use `<RouterView>` and `<RouterLink>` (PascalCase) in templates.
- Define routes in `router/index.ts`; use lazy loading for route components.
- Use `beforeEach` guards for authentication checks.
- Use named routes — never hardcode path strings.

## Security (OWASP)

- Never use `v-html` with user-controlled content — XSS risk.
- Validate all user input on both client and server sides.
- Never store sensitive data (tokens, PII) in `localStorage` — prefer `httpOnly` cookies.
- Apply OWASP principles: least privilege, fail securely, defence in depth.

## Database / API

- Avoid **N+1 patterns** in API calls — batch requests where possible.
- Never expose sensitive fields in API responses.

## Accessibility (a11y)

- Use semantic HTML; augment with ARIA only where necessary.
- Ensure keyboard navigability for all interactive elements.

## Testing

- Use **Vitest** + **Vue Test Utils** (or `@testing-library/vue`).
- Mock Pinia stores in tests with `createTestingPinia`.
- E2E test with **Playwright** or **Cypress**.
- Expectations compare to **literal values**, not method calls.
- Target **≥95% coverage** on composables and component logic.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Tooling

- Lint with **ESLint** + `eslint-plugin-vue` (recommended rule set).
- Format with **Prettier** + `prettier-plugin-vue`.
- Use **Volar** (Vue Language Features) as the IDE extension — disable Vetur.
