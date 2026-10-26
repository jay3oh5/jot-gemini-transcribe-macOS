# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2026-10-26

### Fixed
- **Audio Device Route Change SIGSEGV Crash:** Eliminated use-after-free crash in `AVAudioIOUnit::IOUnitPropertyListener`:
  - Retain discarded `AVAudioEngine` instances in an `AudioEngineRetirement` grace-period pool for 5 seconds during teardown, allowing in-flight CoreAudio / AVFAudio property listener dispatch blocks to drain safely on background queues without referencing deallocated memory.
  - Debounced warm capture graph rebuilds in `WarmEnginePool` by 500ms and added task cancellation for in-flight prewarm operations, preventing race conditions and route-switch thrashing during USB/Bluetooth connect/disconnect events.
- **Package Dependency Clean-Up:** Removed unused `KeyboardShortcuts` dependency from `JotCore/Package.swift`, resolving CLI build errors under Swift 6.
- **History Word Count Stats:** Fixed `HistoryStore.stats()` to include dictations where only `rawTranscript` exists.
- **Language Preservation in Dictation:** Updated Gemini system prompt in `PromptV1` to preserve the exact spoken language and prevent accidental translations.
- **Terminal & Editor Insertion Quirks:** Added `dev.zed.Zed`, `com.sublimetext.4`, `com.jetbrains.intellij`, and `org.vim.MacVim` to paste-mode insertion apps.
- **Audio Sample Ingestion Performance:** Optimized `NoiseFloorEstimator` to use an $O(1)$ ring buffer instead of $O(N)$ `removeFirst()` array shifting.

## [0.4.1] - 2026-10-26

### Added
- **Universal Binary Support:** App builds now produce Mach-O Universal 2 binaries with both `x86_64` (Intel) and `arm64` (Apple Silicon) native slices, restoring full compatibility for Intel Macs.
- **Automated Cloud Release Pipeline:** GitHub Actions workflow (`build-app.yml`) automatically compiles Universal builds and publishes release packages with downloadable artifacts.

### Fixed
- **CoreAudio / AVAudioEngine Teardown Race Condition:** Fixed a fatal `EXC_BAD_ACCESS (SIGSEGV)` crash that occurred when default audio routes changed, headphones were plugged/unplugged, or during system sleep/wake cycles:
  - Implemented `deinit` on `AudioCaptureEngine` to ensure `tearDownEngine()` is always called prior to ARC reference release.
  - Added explicit `cancel()` invocations on discarded background engines in `WarmEnginePool.refresh()` and `deinit`.
  - Added active tap tracking (`hasTap`) so `inputNode.removeTap(onBus: 0)`, `engine.stop()`, and `engine.reset()` execute safely in sequence before engine deallocation.
  - Cleanly removed `configObserver` from `NotificationCenter` during teardown to avoid dispatching property change callbacks into deallocated instances.
- **Swift 6 SPM Resolution:** Pinned `Sauce` dependency to `2.4.1` in `Package.swift` to resolve a manifest syntax error under the Swift 6 compiler package manager.

## [0.4.0] - Upstream Google Base
- Initial release of Jot Gemini Transcribe for macOS.
