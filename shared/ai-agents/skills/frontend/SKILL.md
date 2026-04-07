---
name: frontend
description: Frontend development with React, Vue, modern CSS, accessibility, TypeScript, state management, and web performance optimization.
---

# Frontend Developer Skill

**Roadmap Alignment:** [roadmap.sh/frontend](https://roadmap.sh/frontend) | [roadmap.sh/react](https://roadmap.sh/react) | [roadmap.sh/vue](https://roadmap.sh/vue)

## Core Standards (Effective Software Developer)
When executing frontend tasks, ensure your work adheres to the latest industry standards and roadmap milestones:

### 1. Internet & HTML/CSS Basics
- **Semantic HTML:** Avoid `<div>` soup. Use `<article>`, `<section>`, `<nav>`, `<header>`, `<footer>`, `<main>` where appropriate.
- **Accessibility (a11y):** Strictly follow WCAG standards. Include ARIA roles, `aria-label`, ensure high color contrast, and test for keyboard navigation.
- **Modern CSS:** Utilize CSS Modules, Tailwind CSS, or Styled Components. Always design **mobile-first** and ensure responsive layouts across all device sizes.

### 2. JavaScript / TypeScript (ES6+)
- **Strict Typing:** If using TypeScript, avoid `any`. Use strict interfaces, types, and generics.
- **Modern Syntax:** Use destructuring, spread operators, optional chaining, and nullish coalescing.
- **Functional Programming:** Prefer pure functions, `map`, `filter`, `reduce` over imperative loops when possible.

### 3. Frameworks (React / Vue)
- **Component Architecture:** Build small, reusable, and testable components with single responsibilities.
- **React Standards:** 
  - Exclusively use Functional Components and Hooks (no class components).
  - Strictly manage `useEffect` dependency arrays to prevent infinite loops and stale closures.
  - Extract reusable logic into custom hooks.
- **Vue Standards:**
  - Prefer the Composition API (`<script setup>`) over the Options API for new components.
  - Utilize composables for shared logic.

### 4. State Management
- Avoid heavy boilerplate (like Redux) unless strictly necessary. 
- Use local component state for UI logic.
- Prefer Context API, Zustand, or Pinia for global state. Use React Query / SWR / Vue Query for server state and data fetching.

### 5. Web Vitals & Performance
- **Code Splitting:** Lazy load non-critical routes and components (e.g., `React.lazy()`, `defineAsyncComponent`).
- **Optimization:** Optimize images (WebP/AVIF), minimize bundle size, and prevent Cumulative Layout Shift (CLS) by reserving space for async content.
- **Memoization:** Use `useMemo` and `useCallback` (or Vue's `computed`) strategically, avoiding premature optimization.