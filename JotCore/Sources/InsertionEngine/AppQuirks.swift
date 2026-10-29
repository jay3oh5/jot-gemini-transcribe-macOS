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

/// Per-app insertion behavior. Seeded from research; grows via the Insertion Lab.
public enum AppQuirks {
    /// Terminals, browsers, and web-heavy apps: no editable AX text element or
    /// unreliable AX text replacement (web rich-text editors like ProseMirror,
    /// Slate, Monaco, Google Docs often misbehave or replace entire content on
    /// AX set) — go straight to paste (universal ⌘V).
    public static let forcePaste: Set<String> = [
        // Terminals and terminal-like apps
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "dev.warp.Warp-Stable",
        "com.github.wez.wezterm",
        "com.mitchellh.ghostty",
        "net.kovidgoyal.kitty",
        "io.alacritty",
        "dev.zed.Zed",
        "com.sublimetext.4",
        "com.jetbrains.intellij",
        "org.vim.MacVim",

        // Web browsers: contenteditable/rich-text inputs (Claude.ai, ChatGPT, Google Docs)
        // do not handle direct AX text replacement reliably. Specifically, Gecko
        // (Firefox/Zen) wipes out the entire container upon kAXSelectedTextAttribute set.
        "app.zen-browser.zen",
        "org.mozilla.firefox",
        "org.mozilla.firefoxdeveloperedition",
        "org.mozilla.nightly",
        "io.gitlab.librewolf-community.librewolf",
        "net.waterfox.waterfox",
        "jp.co.ablaze.floorp",
        "org.torproject.torbrowser",
        "com.google.Chrome",
        "com.google.Chrome.canary",
        "com.google.Chrome.beta",
        "com.google.Chrome.dev",
        "com.apple.Safari",
        "com.apple.SafariTechnologyPreview",
        "company.thebrowser.Browser", // Arc
        "com.brave.Browser",
        "com.brave.Browser.nightly",
        "com.brave.Browser.beta",
        "com.microsoft.edgemac",
        "com.microsoft.edgemac.Canary",
        "com.microsoft.edgemac.Dev",
        "com.microsoft.edgemac.Beta",
        "com.vivaldi.Vivaldi",
        "com.operasoftware.Opera",
        "com.operasoftware.OperaGX",
        "com.kagi.kagimacOS", // Orion

        // Web wrapper desktop apps with rich web editors
        "com.anthropic.claudefordesktop",
        "com.openai.chat",
    ]

    /// Chromium/Electron apps: the accessibility tree must be woken with
    /// AXManualAccessibility before AX insertion has any chance
    /// (AXEnhancedUserInterface is VoiceOver-reserved and causes window moves).
    public static let needsManualAccessibility: Set<String> = [
        "com.tinyspeck.slackmacgap",
        "com.microsoft.VSCode",
        "com.todesktop.230313mzl4w4u92", // Cursor
        "com.exafunction.windsurf",
        "com.hnc.Discord",
        "com.anthropic.claudefordesktop",
        "com.google.Chrome",
        "com.microsoft.edgemac",
        "com.brave.Browser",
        "com.vivaldi.Vivaldi",
        "company.thebrowser.Browser", // Arc
        "com.microsoft.teams2",
        "org.whispersystems.signal-desktop",
        "com.spotify.client",
        "notion.id",
        "md.obsidian",
        "com.linear",
        "com.figma.Desktop",
    ]
}
