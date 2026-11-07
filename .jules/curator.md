# Curator's Dependency Journal

## 2026-11-07 - Synchronizing Third-Party Package Notices with Swift Package Manifests
**Learning:** When Swift package dependencies are removed from `Package.swift` (e.g. `KeyboardShortcuts` removed in v0.4.2 to avoid Swift 6 CLI build issues) or deferred during architectural evolution (e.g. `Sparkle` planned for auto-updates but never integrated), repository-level attribution documents like `THIRD_PARTY_NOTICES.md` easily fall out of sync. This leaves stale package references and inaccurate license claims.
**Action:** Always audit `THIRD_PARTY_NOTICES.md` alongside `Package.swift` and `project.yml` during dependency cleanups to verify that every listed package is actively consumed.
