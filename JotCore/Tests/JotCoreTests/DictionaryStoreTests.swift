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

final class DictionaryStoreTests: XCTestCase {
    private var store: DictionaryStore!
    private var backup: [DictionaryEntry] = []

    override func setUp() {
        super.setUp()
        store = DictionaryStore()
        backup = store.entries()
        store.save([])
    }

    override func tearDown() {
        store.save(backup)
        super.tearDown()
    }

    func testAddWordAndPreventDuplicates() {
        XCTAssertTrue(store.add(term: "Kubernetes", misspelling: "cooper netties"))
        // Duplicate term case-insensitive should be rejected
        XCTAssertFalse(store.add(term: "kubernetes"))
        // Overly long terms (>60 chars) rejected for words
        XCTAssertFalse(store.add(term: String(repeating: "a", count: 61)))
    }

    func testAddSnippetAndPreventDuplicateTriggers() {
        XCTAssertTrue(store.add(term: "https://example.com/long-url", misspelling: "my link", isSnippet: true))
        // Same trigger should be rejected
        XCTAssertFalse(store.add(term: "https://different.com", misspelling: "my link", isSnippet: true))
        // Same trigger with extra whitespace should be rejected
        XCTAssertFalse(store.add(term: "https://different.com", misspelling: "  my link  ", isSnippet: true))
        // Snippet term can be > 60 chars
        XCTAssertTrue(store.add(term: String(repeating: "Long snippet text ", count: 10), misspelling: "long snippet", isSnippet: true))
    }

    func testCSVImportDoesNotDropWordsMatchingSnippetExpansions() {
        // Given an existing snippet whose expansion is "Test Term"
        XCTAssertTrue(store.add(term: "Test Term", misspelling: "tt", isSnippet: true))

        // When importing a CSV that contains a word whose term is "Test Term"
        let csv = """
        term,misspelling,isSnippet
        "Test Term","test term typo","false"
        """
        let imported = store.importCSV(csv)

        // Then it should be imported successfully rather than dropped by seen
        XCTAssertEqual(imported, 1)
        let entries = store.entries()
        XCTAssertEqual(entries.count, 2)
        XCTAssertTrue(entries.contains(where: { $0.term == "Test Term" && $0.isSnippet != true }))
        XCTAssertTrue(entries.contains(where: { $0.term == "Test Term" && $0.isSnippet == true }))
    }

    func testCSVImportDropsDuplicateSnippetTriggers() {
        let csv = """
        term,misspelling,isSnippet
        "First Expansion","trigger one","true"
        "Second Expansion","trigger one","true"
        """
        let imported = store.importCSV(csv)
        XCTAssertEqual(imported, 1)

        let entries = store.entries()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.term, "First Expansion")
    }

    func testCSVExportAndImportRoundTrip() {
        XCTAssertTrue(store.add(term: "Ammaar", misspelling: "amar"))
        XCTAssertTrue(store.add(term: "https://github.com", misspelling: "my github", isSnippet: true))

        let csv = store.exportCSV()
        store.save([])
        XCTAssertEqual(store.entries().count, 0)

        let imported = store.importCSV(csv)
        XCTAssertEqual(imported, 2)

        let entries = store.entries()
        XCTAssertTrue(entries.contains(where: { $0.term == "Ammaar" && $0.misspelling == "amar" && $0.isSnippet != true }))
        XCTAssertTrue(entries.contains(where: { $0.term == "https://github.com" && $0.misspelling == "my github" && $0.isSnippet == true }))
    }
}
