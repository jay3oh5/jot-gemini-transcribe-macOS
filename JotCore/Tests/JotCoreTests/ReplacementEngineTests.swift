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

final class ReplacementEngineTests: XCTestCase {
    private func rule(_ wrong: String, _ right: String) -> ReplacementEngine.Rule {
        .init(wrong: wrong, right: right)
    }

    func testBasicReplacement() {
        let out = ReplacementEngine.apply([rule("cooper netties", "Kubernetes")], to: "deploy the cooper netties cluster")
        XCTAssertEqual(out, "deploy the Kubernetes cluster")
    }

    func testWordBoundaryRespected() {
        let out = ReplacementEngine.apply([rule("cat", "dog")], to: "the category has a cat")
        XCTAssertEqual(out, "the category has a dog")
    }

    func testLongestMatchWins() {
        let out = ReplacementEngine.apply(
            [rule("gemini", "Gemini"), rule("gemini api", "Gemini API")],
            to: "open gemini api now"
        )
        XCTAssertEqual(out, "open Gemini API now")
    }

    func testExplicitCasingCarries() {
        let out = ReplacementEngine.apply([rule("g r p c", "gRPC")], to: "The G R P C endpoint")
        XCTAssertEqual(out, "The gRPC endpoint")
    }

    func testCaseInsensitiveMatching() {
        let out = ReplacementEngine.apply([rule("genny", "Gemini")], to: "Genny is fast. genny wins.")
        XCTAssertEqual(out, "Gemini is fast. Gemini wins.")
    }

    func testLowercaseRulePropagatesSentenceCase() {
        let out = ReplacementEngine.apply([rule("standup", "stand-up")], to: "Standup at nine. The standup ran long.")
        XCTAssertEqual(out, "Stand-up at nine. The stand-up ran long.")
    }

    func testNoRulesIsIdentity() {
        XCTAssertEqual(ReplacementEngine.apply([], to: "unchanged"), "unchanged")
    }

    func testMultipleOccurrences() {
        let out = ReplacementEngine.apply([rule("amar", "Ammaar")], to: "amar told amar's team")
        XCTAssertEqual(out, "Ammaar told Ammaar's team")
    }
    
    private func snippet(_ wrong: String, _ right: String) -> ReplacementEngine.Rule {
        .init(wrong: wrong, right: right, isSnippet: true)
    }
    
    func testSnippetExpansion() {
        let out = ReplacementEngine.apply([snippet("my calendly", "https://calendly.com/test")], to: "Here is my calendly link")
        XCTAssertEqual(out, "Here is https://calendly.com/test link")
    }
    
    func testSnippetVariableSpacing() {
        // "my calendly" should handle multiple spaces in text or rule
        let out = ReplacementEngine.apply([snippet("my calendly", "URL")], to: "Here is my  calendly link")
        XCTAssertEqual(out, "Here is URL link")
        
        let out2 = ReplacementEngine.apply([snippet("my  calendly", "URL")], to: "Here is my calendly link")
        XCTAssertEqual(out2, "Here is URL link")
    }
    
    func testSnippetSmartQuotes() {
        // Straight quote in rule matches smart quote in text
        let out = ReplacementEngine.apply([snippet("my 'quote'", "URL")], to: "Here is my ’quote’ link")
        XCTAssertEqual(out, "Here is URL link")
        
        // Smart quote in rule matches straight quote in text
        let out2 = ReplacementEngine.apply([snippet("let’s go", "URL")], to: "Here is let's go link")
        XCTAssertEqual(out2, "Here is URL link")
    }

    func testSnippetSpecialRegexCharacters() {
        let out = ReplacementEngine.apply([snippet("c++ project", "Swift")], to: "Working on a c++ project today")
        XCTAssertEqual(out, "Working on a Swift today")

        let out2 = ReplacementEngine.apply([snippet("$100 discount", "deal")], to: "Get the $100 discount now")
        XCTAssertEqual(out2, "Get the deal now")
    }
    
    func testSnippetDoesNotPropagateCase() {
        // Snippets should strictly keep their own casing, even if trigger was capitalized
        let out = ReplacementEngine.apply([snippet("my email", "test@Example.com")], to: "My email is...")
        XCTAssertEqual(out, "test@Example.com is...")
    }
}
