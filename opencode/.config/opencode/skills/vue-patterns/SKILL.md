---
name: vue-patterns
description: Use when building Vue 3 applications with Composition API, composables, Pinia, Vue Router, or SFC best practices.
---

# Vue.js Patterns

## When to Use This Skill
- Building components with the Composition API
- Creating composables for reusable logic
- Managing state with Pinia stores
- Routing with Vue Router and navigation guards
- Following single-file component best practices

## Workflow
1. Create a project: `npm create vue@latest`
2. Build components: `<script setup>` with `defineProps` and `defineEmits`
3. Add reactive state: `ref()`, `reactive()`, `computed()`
4. Create composables: `useAuth()`, `useFetch()` for shared logic
5. Set up Pinia: `defineStore('counter', () => { ... })`
6. Configure routes: `createRouter()` with `meta` and `beforeEach` guards
7. Test: `vitest` for unit tests, `@vue/test-utils` for component tests
8. Build: `npm run build`

## Rules
- Use `<script setup>` for all new components — less boilerplate
- Extract reusable logic into composables, not mixins
- Keep template logic minimal — use computed properties instead
- Use `v-once` and `v-memo` for static or rarely-changing content
- Don't modify props directly — emit events instead
- Use TypeScript for prop and emit type safety
