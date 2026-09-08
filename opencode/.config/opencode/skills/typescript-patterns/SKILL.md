---
title: "TypeScript Patterns"
catalogNumber: "No. 153"
tagline: "Type-safe code that scales"
description: "Advanced TypeScript patterns for large codebases — discriminated unions, branded types, template literals, type guards, and runtime validation."
category: code-quality
version: "1.0.0"
license: "MIT"
triggers:
  - "TypeScript type patterns"
  - "advanced TypeScript"
  - "type-safe code"
  - "discriminated unions"
  - "runtime type validation"
downloadFile: "typescript-patterns.zip"
contents:
  - "SKILL.md"
  - "references/type-patterns.md"
---

TypeScript's type system is Turing-complete. Use it to make
invalid states unrepresentable and catch errors at compile time,
not in production.

## Discriminated unions

```typescript
// Model state machines with types
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function renderState<T>(state: RequestState<T>) {
  switch (state.status) {
    case 'idle': return <Placeholder />;
    case 'loading': return <Spinner />;
    case 'success': return <Data data={state.data} />;
    case 'error': return <ErrorMessage error={state.error} />;
    // TypeScript knows all cases are handled — no default needed
  }
}
```

## Branded types

```typescript
// Prevent mixing incompatible values
type UserId = string & { readonly __brand: 'UserId' };
type PostId = string & { readonly __brand: 'PostId' };

function UserId(id: string): UserId { return id as UserId; }
function PostId(id: string): PostId { return id as PostId; }

function getUser(id: UserId) { /* ... */ }
function getPost(id: PostId) { /* ... */ }

const userId = UserId('user-123');
const postId = PostId('post-456');

getUser(userId);  // ✅ Works
getUser(postId);  // ❌ Type error — PostId is not UserId
```

## Template literal types

```typescript
// Type-safe route parameters
type Route = `/${string}`;
type ApiRoute = `/api/${string}`;
type IdRoute = `/${string}/${string}`;

function route<T extends Route>(path: T): T { return path; }

route('/users');           // ✅
route('/api/users');       // ✅
route('users');            // ❌ Missing leading slash

// Type-safe event names
type EventName = `${'click' | 'hover' | 'focus'}-${'start' | 'end'}`;
const event: EventName = 'click-start'; // ✅
const bad: EventName = 'click';         // ❌
```

## Type guards

```typescript
// Narrow types with type predicates
function isDefined<T>(value: T | null | undefined): value is T {
  return value !== null && value !== undefined;
}

function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Custom type guard for API responses
interface ApiResponse {
  data: unknown;
  status: number;
}

function isSuccessResponse(response: ApiResponse): response is ApiResponse & { data: Record<string, unknown> } {
  return response.status >= 200 && response.status < 300;
}

// Usage
const response = await fetch('/api/data');
const json: ApiResponse = await response.json();

if (isSuccessResponse(json)) {
  // json.data is now Record<string, unknown>
  console.log(json.data.users);
}
```

## Runtime validation with Zod

```typescript
import { z } from 'zod';

// Define schemas that match your types
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin']),
  createdAt: z.coerce.date(),
});

type User = z.infer<typeof UserSchema>;

// Validate at boundaries
function parseUser(data: unknown): User {
  return UserSchema.parse(data);
}

// Safe parsing that doesn't throw
function safeParseUser(data: unknown) {
  const result = UserSchema.safeParse(data);
  if (!result.success) {
    console.error('Validation errors:', result.error.flatten());
    return null;
  }
  return result.data;
}
```

## Mapped types

```typescript
// Make all properties optional and nullable
type Nullable<T> = { [K in keyof T]: T[K] | null };

// Make specific properties required
type RequireFields<T, K extends keyof T> = T & { [P in K]-?: T[P] };

// Deep readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

// Extract function parameter types
type ParamsOf<T> = T extends (...args: infer P) => any ? P : never;
```

## Conditional types

```typescript
// Extract return type of async functions
type AsyncReturnType<T extends (...args: any) => Promise<any>> =
  T extends (...args: any) => Promise<infer R> ? R : never;

// Check if type has a specific property
type HasId<T> = T extends { id: any } ? true : false;

// Distribute conditional types over unions
type NonNullableArray<T> = T extends Array<infer E> ? NonNullable<E>[] : T;
```

## Anti-patterns

- Don't use `any` — use `unknown` and narrow with type guards
- Don't use type assertions (`as`) to silence the compiler — fix the types
- Don't ignore `strictNullChecks` — it catches 15% of bugs
- Don't use `enum` — use `const` objects with `as const`
- Don't skip input validation — TypeScript types are erased at runtime
