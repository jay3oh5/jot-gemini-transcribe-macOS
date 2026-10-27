# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-10-27

### Added
- **Voice Snippets & Text Expander in Dictionary:**
  - Create and manage custom voice-activated text snippets in the Dictionary pane with dedicated segmented switching between Words and Snippets.
  - Spoken trigger phrases automatically expand into full multi-line snippets, templates, or URLs upon insertion.
  - Full CSV import and export support for snippets with deduplication and validation.
- **History Export to Markdown:**
  - One-click "Export History" button to copy all session records directly to the system clipboard formatted as clean Markdown.
- **Audio Scrubber & Variable Playback Speed:**
  - In-window audio playback controls in the History detail sheet featuring variable speeds (1x, 1.25x, 1.5x, 2x) and a timestamp scrubber.
- **Microphone Selector in Settings:**
  - Added dedicated microphone input dropdown in Settings > Dictation with empty state handling.

### Fixed & Improved
- **High-Frequency Buffer Allocation Optimization:**
  - Introduced `BufferPool` in `AudioCaptureEngine` to eliminate dynamic heap allocations during audio stream ingestion.
  - Dynamically scaled pool capacity for high sample rate audio devices (96kHz / 192kHz) and added bounds checking to prevent buffer overflows and CoreAudio exceptions.
- **Smart Punctuation & Smart Quote Normalization:**
  - Enhanced `ReplacementEngine` to support bidirectional matching for opening curly single quotes (`‘`), closing curly single quotes (`’`), straight single quotes (`'`), and smart double quotes (`“` and `”`).
  - Added smart quote artifact stripping in `ValidationGate`.
- **Dictionary CSV Import Fixes:**
  - Fixed an issue where snippet expansions with matching terms blocked vocabulary word imports.
  - Added $O(1)$ duplicate trigger rejection for CSV batch processing.
- **Accessibility & Micro-Animations:**
  - Added accessible VoiceOver labels, hints, and traits to icon-only controls, idle dot indicators, and HUD elements.
  - Silenced duplicate chime earcon upon successful text insertion while preserving the visual checkmark.
- **Test Suite & CI Pipeline:**
  - Added unit and regression test suites for `DictionaryStore`, `ReplacementEngine`, and `ValidationGate`.
  - Fixed internal database access level in `HistoryStore` for unit test execution under CI.

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
