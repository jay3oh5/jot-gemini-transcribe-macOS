# Sentinel's Security Journal

## 2026-03-08 - Custom URL Scheme Validation in AppDelegate
**Vulnerability:** In `AppDelegate.handleGetURL`, incoming URLs received via Apple Events (`kInternetEventClass` / `kAEGetURL`) were parsed directly with `URL(string:)` and dispatched without validating that the scheme matched registered application schemes (`sayo`, `jot`) or checking bounds on URL length.
**Learning:** External applications or web browsers can invoke custom URL handlers with malformed or oversized URL strings. Without strict scheme checks and length bounds, unvalidated events can lead to unexpected dispatching or resource exhaustion.
**Prevention:** In event-based URL dispatchers, always enforce length caps (e.g. 1024 characters), trim inputs, and whitelist allowed schemes (`["sayo", "jot"].contains(url.scheme?.lowercased())`) before routing commands.

## 2026-03-08 - Endpoint Override Host and Length Validation
**Vulnerability:** `SettingsStore.usableEndpointURL` only verified that the parsed URL's scheme was `http` or `https`, omitting hostname existence/validation and length limits. URLs such as `https://` or `http:///path` parsed successfully in Foundation URL without a hostname, resulting in malformed requests, potential request routing ambiguities, or SSRF risks when constructing HTTP requests.
**Learning:** In Foundation `URL(string:)`, strings like `https://` or `http:///path` parse with `.scheme == "https"` or `"http"` while `.host` is `nil` or empty. When downstream network layers concatenate paths or send requests, hostless URLs cause runtime network issues or routing anomalies.
**Prevention:** Always validate that `url.host` exists and is non-empty after trimming, enforce input length limits to prevent DoS, and whitelist allowed schemes (`http`, `https`).
