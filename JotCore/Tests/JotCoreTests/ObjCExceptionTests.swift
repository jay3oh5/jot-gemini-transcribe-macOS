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

import Foundation
import JotCoreObjC
import XCTest
@testable import JotCore

final class ObjCExceptionTests: XCTestCase {
    func testExecuteSucceedsOnNormalBlock() {
        var ran = false
        XCTAssertNoThrow(try ObjCException.execute {
            ran = true
        })
        XCTAssertTrue(ran)
    }

    func testExecuteCatchesNSException() {
        XCTAssertThrowsError(try ObjCException.execute {
            NSException(name: NSExceptionName("TestException"), reason: "Testing exception catch", userInfo: nil).raise()
        }) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "com.jay3oh5.sayo.ObjCException")
            XCTAssertEqual(nsError.localizedDescription, "Testing exception catch")
        }
    }
}
