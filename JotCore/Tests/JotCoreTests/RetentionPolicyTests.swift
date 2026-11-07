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

import XCTest
@testable import JotCore

final class RetentionPolicyTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("RetentionPolicyTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let root {
            try? FileManager.default.removeItem(at: root)
        }
    }

    @discardableResult
    private func createSession(
        startedAt: Date,
        status: SessionMeta.Status = .inserted,
        transcript: String? = "hello world",
        hasCAF: Bool = true,
        hasFLAC: Bool = true
    ) throws -> (folder: URL, caf: URL, flac: URL, meta: URL) {
        let folder = root.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        var meta = SessionMeta(id: UUID(), startedAt: startedAt, status: status)
        meta.rawTranscript = transcript
        meta.write(to: folder)

        let cafURL = FileLayout.audioCAF(in: folder)
        let flacURL = FileLayout.audioFLAC(in: folder)
        let metaURL = FileLayout.metaJSON(in: folder)

        if hasCAF {
            try Data([0x01, 0x02]).write(to: cafURL)
        }
        if hasFLAC {
            try Data([0x03, 0x04]).write(to: flacURL)
        }

        return (folder, cafURL, flacURL, metaURL)
    }

    func testKeepForeverDoesNotPurge() throws {
        let oldDate = Date().addingTimeInterval(-30 * 86_400)
        let session = try createSession(startedAt: oldDate)

        let policy = RetentionPolicy(audioRetentionDays: 0)
        policy.purgeExpiredAudio(recordingsRoot: root)

        XCTAssertTrue(FileManager.default.fileExists(atPath: session.caf.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.meta.path))
    }

    func testNeverKeepAudioPurgesAudioImmediatelyWhenTranscriptExists() throws {
        let recentDate = Date()
        let session = try createSession(startedAt: recentDate, transcript: "real speech")

        let policy = RetentionPolicy(audioRetentionDays: -1)
        policy.purgeExpiredAudio(recordingsRoot: root)

        XCTAssertFalse(FileManager.default.fileExists(atPath: session.caf.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: session.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.meta.path), "meta.json must be preserved")
    }

    func testPurgesExpiredAudioFilesAndKeepsUnexpired() throws {
        let now = Date()
        let oldDate = now.addingTimeInterval(-10 * 86_400)
        let freshDate = now.addingTimeInterval(-2 * 86_400)

        let expired = try createSession(startedAt: oldDate, transcript: "old text")
        let fresh = try createSession(startedAt: freshDate, transcript: "fresh text")

        let policy = RetentionPolicy(audioRetentionDays: 7)
        policy.purgeExpiredAudio(recordingsRoot: root, now: now)

        // Expired session audio is purged, metadata preserved
        XCTAssertFalse(FileManager.default.fileExists(atPath: expired.caf.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: expired.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: expired.meta.path))

        // Fresh session remains untouched
        XCTAssertTrue(FileManager.default.fileExists(atPath: fresh.caf.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fresh.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fresh.meta.path))
    }

    func testTranscriptlessCancelledSessionsAreRetentionImmune() throws {
        // Cancelled sessions without a transcript must keep their audio so Retry works
        let oldDate = Date().addingTimeInterval(-30 * 86_400)
        let session = try createSession(startedAt: oldDate, status: .cancelled, transcript: nil)

        let policy = RetentionPolicy(audioRetentionDays: 7)
        policy.purgeExpiredAudio(recordingsRoot: root)

        XCTAssertTrue(FileManager.default.fileExists(atPath: session.caf.path), "audio must be preserved for Retry")
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.meta.path))
    }

    func testSilentSessionsWithoutTranscriptArePurgedWhenExpired() throws {
        // Silent sessions have no transcript, but their audio can safely be purged
        let oldDate = Date().addingTimeInterval(-14 * 86_400)
        let session = try createSession(startedAt: oldDate, status: .silent, transcript: nil)

        let policy = RetentionPolicy(audioRetentionDays: 7)
        policy.purgeExpiredAudio(recordingsRoot: root)

        XCTAssertFalse(FileManager.default.fileExists(atPath: session.caf.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: session.flac.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: session.meta.path))
    }
}
