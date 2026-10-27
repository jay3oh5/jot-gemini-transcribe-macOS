// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AVFoundation
import Foundation
import JotCore

/// Keeps one capture graph built and prepared while the app is idle, so a key
/// press pays only `engine.start()`.
///
/// Measured on this machine (Bluetooth route): building the graph costs 75–135ms
/// — `engine.inputNode` alone is 42–68ms of HAL work — and that window is exactly
/// where a user's first words are lost. Preparing is not recording: no audio
/// flows and no microphone indicator appears until start().
///
/// Concurrency: a spare is built on a utility queue and only published once fully
/// prepared, so nothing ever touches a graph that is still being built.
@MainActor
final class WarmEnginePool {
    private var spare: AudioCaptureEngine?
    private var prewarmTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    /// The engine for a session that is starting right now. Immediately begins
    /// building the next spare so back-to-back dictations stay warm.
    func take() -> AudioCaptureEngine {
        refreshTask?.cancel()
        refreshTask = nil
        defer { prewarmNext() }
        if let spare {
            self.spare = nil
            return spare
        }
        // Cold path (first launch, mic just authorized, device changed): correct,
        // just slower — the session builds its own graph.
        return AudioCaptureEngine()
    }

    func prewarmNext() {
        guard spare == nil, prewarmTask == nil else { return }
        // Never touch the mic stack before the user has granted access: doing so
        // would trigger the permission prompt out of nowhere.
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else { return }
        prewarmTask = Task.detached(priority: .utility) { [weak self] in
            let engine = AudioCaptureEngine()
            engine.prewarm()
            if Task.isCancelled {
                engine.cancel()
                await MainActor.run { [weak self] in
                    self?.prewarmTask = nil
                }
                return
            }
            await MainActor.run { [weak self] in
                guard let self else {
                    engine.cancel()
                    return
                }
                self.prewarmTask = nil
                if self.spare == nil {
                    self.spare = engine
                } else {
                    engine.cancel()
                }
            }
        }
    }

    /// Drop the spare (e.g. the input device changed under it) and build a fresh
    /// one for the new route.
    func refresh() {
        refreshTask?.cancel()
        prewarmTask?.cancel()
        prewarmTask = nil

        let oldSpare = spare
        spare = nil
        oldSpare?.cancel()

        // Debounce: hardware route changes often fire multiple notifications in
        // rapid succession. Delay 500ms so CoreAudio has settled before building
        // the new warm engine.
        refreshTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            self.refreshTask = nil
            self.prewarmNext()
        }
    }

    deinit {
        refreshTask?.cancel()
        prewarmTask?.cancel()
        spare?.cancel()
    }
}
