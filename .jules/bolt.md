# Bolt's Performance Journal

## 2026-03-06 - High-Frequency Audio Stream Buffer Management
**Learning:** `NoiseFloorEstimator.ingest` runs continuously on audio level frame taps (~10-100 Hz). Using `Array.removeFirst()` on bounded buffers inside high-frequency audio loops causes $O(N)$ memory copy/shifting on every single incoming sample once capacity is reached.
**Action:** Always prefer ring buffer index overwriting (`samples[writeIndex] = val; writeIndex = (writeIndex + 1) % capacity`) over `removeFirst()` for real-time audio sampling.
