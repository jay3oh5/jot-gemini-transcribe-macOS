# Steward's Maintainability Journal

## 2026-03-08 - UserDefaults Key Namespace Encapsulation
**Learning:** Sprinkling raw string literals across getters, setters, notification dispatchers, and cache invalidation routines introduces subtle risks of key typos and makes tracing setting usages fragile. When keys are scattered across multiple methods, renames or deprecations can leave orphaned keys in persistent stores or desync UI observers from store writes.
**Action:** Encapsulate storage keys in a dedicated private `Key` enum within the store struct, ensuring compiler-verified references across all reads, writes, and cache clearing.
