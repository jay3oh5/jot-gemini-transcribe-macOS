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

final class AppQuirksTests: XCTestCase {
    func testBrowsersAreForcedToPasteTier() {
        let expectedBrowsers = [
            "app.zen-browser.zen",
            "org.mozilla.firefox",
            "com.google.Chrome",
            "com.apple.Safari",
            "company.thebrowser.Browser",
            "com.brave.Browser",
            "com.microsoft.edgemac",
            "com.anthropic.claudefordesktop",
            "com.openai.chat",
        ]

        for bundleID in expectedBrowsers {
            XCTAssertTrue(
                AppQuirks.forcePaste.contains(bundleID),
                "\(bundleID) must be in forcePaste to avoid destructive contenteditable AX replacements"
            )
        }
    }

    func testTerminalsAreForcedToPasteTier() {
        XCTAssertTrue(AppQuirks.forcePaste.contains("com.apple.Terminal"))
        XCTAssertTrue(AppQuirks.forcePaste.contains("com.googlecode.iterm2"))
        XCTAssertTrue(AppQuirks.forcePaste.contains("com.mitchellh.ghostty"))
    }
}
