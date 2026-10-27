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

/// Deterministic post-model replacement layer (§3.7): the dictionary's guarantee.
/// The cleanup prompt *suggests* spellings to the model; this layer *enforces* the
/// explicit wrong→right rules afterward. Longest-match-first, word-boundary,
/// case-preserving (ALL-CAPS / Title / lower propagation).
public enum ReplacementEngine {
    public struct Rule: Codable, Equatable, Sendable {
        public var wrong: String
        public var right: String
        public var isSnippet: Bool

        public init(wrong: String, right: String, isSnippet: Bool = false) {
            self.wrong = wrong
            self.right = right
            self.isSnippet = isSnippet
        }
    }

    public static func apply(_ rules: [Rule], to text: String) -> String {
        guard !rules.isEmpty else { return text }
        var result = text
        // Longest wrong-form first so "gemini api" wins over "gemini".
        for rule in rules.sorted(by: { $0.wrong.count > $1.wrong.count }) {
            guard !rule.wrong.isEmpty else { continue }
            
            // Build the pattern with resilience for phrase-level substitutions
            // 1. Literal spaces (single or consecutive) become \s+ to handle variable spacing
            // 2. Straight or smart single quotes become ['’‘] to handle dictation variants
            // 3. Straight or smart double quotes become ["“”] to handle dictation variants
            var basePattern = NSRegularExpression.escapedPattern(for: rule.wrong)
            basePattern = basePattern.replacingOccurrences(of: " +", with: "\\\\s+", options: .regularExpression)
            basePattern = basePattern.replacingOccurrences(of: "['’‘]", with: "['’‘]", options: .regularExpression)
            basePattern = basePattern.replacingOccurrences(of: "[\"“”]", with: "[\"“”]", options: .regularExpression)
            
            // Lookarounds instead of \b: word boundaries silently never match when
            // the wrong form starts/ends with punctuation ("e.g.", "c++") (audit L21).
            let pattern = "(?<![\\w])\(basePattern)(?![\\w])"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result)).reversed()
            for match in matches {
                guard let range = Range(match.range, in: result) else { continue }
                let original = String(result[range])
                
                let replacement = rule.isSnippet ? rule.right : propagateCase(from: original, to: rule.right, wrong: rule.wrong)
                result.replaceSubrange(range, with: replacement)
            }
        }
        return result
    }

    /// "KUBERNETES"→"GRPC" stays caps; "Kubernetes"→"GRPC"… follows the rule's
    /// canonical casing unless the match was ALL-CAPS or the rule carries
    /// EXPLICIT casing. A rule is explicitly cased when its right side contains
    /// uppercase (gRPC, iPhone) — or when its WRONG side does ("NPM"→"npm" is a
    /// deliberate lowercase rule; ALL-CAPS propagation would silently undo it).
    static func propagateCase(from original: String, to replacement: String, wrong: String = "") -> String {
        let hasExplicitCasing = replacement.dropFirst().contains(where: { $0.isUppercase })
            || replacement.first?.isUppercase == true
            || wrong.contains(where: { $0.isUppercase })
            || (!wrong.isEmpty && wrong.lowercased() == replacement.lowercased())
        if hasExplicitCasing {
            return replacement // dictionary term carries its own casing (gRPC, iPhone)
        }
        if original == original.uppercased(), original.count > 1 {
            return replacement.uppercased()
        }
        if original.first?.isUppercase == true {
            return replacement.prefix(1).uppercased() + replacement.dropFirst()
        }
        return replacement
    }
}
