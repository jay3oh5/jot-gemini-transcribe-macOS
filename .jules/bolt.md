# Bolt's Performance Journal

## 2026-03-06 - WindowServer IPC Avoidance on Display Detection
**Learning:** `CGWindowListCopyWindowInfo` executes a synchronous WindowServer IPC round-trip that scales with total window count across the system (0.30–0.66 ms median, up to 8.9 ms max). When positioning HUD elements relative to the focused window, checking `NSScreen.screens.count <= 1` allows returning `NSScreen.screens.first` immediately, bypassing WindowServer IPC entirely on single-display systems.
**Action:** Always short-circuit multi-display window detection with `if NSScreen.screens.count <= 1` before invoking `CGWindowListCopyWindowInfo` or accessibility APIs on critical rendering paths.

## 2026-03-06 - High-Frequency Audio Stream Buffer Management
**Learning:** `NoiseFloorEstimator.ingest` runs continuously on audio level frame taps (~10-100 Hz). Using `Array.removeFirst()` on bounded buffers inside high-frequency audio loops causes $O(N)$ memory copy/shifting on every single incoming sample once capacity is reached.
**Action:** Always prefer ring buffer index overwriting (`samples[writeIndex] = val; writeIndex = (writeIndex + 1) % capacity`) over `removeFirst()` for real-time audio sampling.
