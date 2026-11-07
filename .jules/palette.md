# Palette's UX Journal

## 2026-03-07 - Custom Search Field UX & Empty States in macOS SwiftUI Panes
**Learning:** Custom SwiftUI search text fields (using `.textFieldStyle(.plain)`) lack standard macOS search field affordances: they do not provide an automatic clear button, an explicit accessibility label for VoiceOver, or differentiated empty state handling. When a search returns no items, displaying an onboarding empty state ("Nothing here yet - Hold fn and say hello") confuses users by masking whether the filter was applied or the database is truly empty.
**Action:** Always provide an explicit accessible `clear` button (`Image(systemName: "xmark.circle.fill")`) inside custom search bars when `!query.isEmpty`, attach `.accessibilityLabel` to the field, and differentiate empty list states between empty database vs. empty search results with a one-click "Clear Search" call-to-action.
