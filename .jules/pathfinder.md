# Pathfinder's DX Journal

## 2026-03-09 - Upstream Fork Renaming Consistency in Build and Release Scripts

**Learning:** When a repository is forked and rebranded (such as renaming from Jot to Sayo with `project.yml` targeting `Sayo.xcodeproj`), developer tooling and release automation scripts (`scripts/release.sh`) can retain upstream project and scheme names (`Jot.xcodeproj`, `scheme Jot`). Because `xcodegen generate` generates the project from `project.yml` (producing `Sayo.xcodeproj`), running release or packaging scripts fails immediately with missing project/scheme errors.

**Action:** Whenever renaming a project or updating `project.yml` target/name definitions, audit all scripts in `scripts/` and CI workflow definitions to ensure project file paths (`*.xcodeproj`), build schemes, archive names, and artifact filenames reflect the new project name consistently.
