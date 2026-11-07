# Inspector's Testing Journal

## 2026-03-08 - Sandboxed Directory Isolation for File Retention Testing
**Learning:** File lifecycle and retention systems like `RetentionPolicy` operate directly on the filesystem (`FileLayout.recordingsRoot`). Without passing an isolated, temporary test directory root, tests risk polluting the real user application support directory or experiencing race conditions across test runs. Furthermore, checking edge-case safety guarantees (such as transcript-less cancelled sessions retaining audio for recovery while silent sessions are purged) requires isolating individual folder trees.
**Action:** Always write retention and filesystem sweep tests against temporary directories using `FileManager.default.temporaryDirectory` and verify both positive deletion paths and critical safety immunity boundaries.
