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

final class AudioInputDevicesTests: XCTestCase {
    private let settings = SettingsStore()

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "preferredInputDeviceUID")
        UserDefaults.standard.removeObject(forKey: "restoreMicAfterDictation")
    }

    func testListReturnsDevicesWithUID() {
        let devices = AudioInputDevices.list()
        for device in devices {
            XCTAssertFalse(device.name.isEmpty, "Device name should not be empty")
            XCTAssertFalse(device.uid.isEmpty, "Device UID should not be empty")
            XCTAssertGreaterThan(device.id, 0, "Device ID should be positive")
        }
    }

    func testLookupDeviceByUID() {
        let devices = AudioInputDevices.list()
        guard let first = devices.first else { return }
        let lookedUp = AudioInputDevices.device(forUID: first.uid)
        XCTAssertEqual(lookedUp?.id, first.id)
        XCTAssertEqual(lookedUp?.name, first.name)
        XCTAssertEqual(lookedUp?.uid, first.uid)
    }

    func testCurrentDefaultQueries() {
        if let id = AudioInputDevices.currentDefaultID() {
            let uid = AudioInputDevices.currentDefaultUID()
            let name = AudioInputDevices.currentDefaultName()
            XCTAssertNotNil(uid)
            XCTAssertNotNil(name)
            XCTAssertEqual(AudioInputDevices.uid(of: id), uid)
        }
    }

    func testPreferredInputSettings() {
        XCTAssertNil(settings.preferredInputDeviceUID)
        XCTAssertTrue(settings.restoreMicAfterDictation)

        settings.setPreferredInputDeviceUID("test-device-uid")
        XCTAssertEqual(settings.preferredInputDeviceUID, "test-device-uid")

        settings.setRestoreMicAfterDictation(false)
        XCTAssertFalse(settings.restoreMicAfterDictation)

        settings.setPreferredInputDeviceUID(nil)
        XCTAssertNil(settings.preferredInputDeviceUID)
    }
}
