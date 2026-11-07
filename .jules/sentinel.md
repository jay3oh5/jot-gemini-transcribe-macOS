# Sentinel's Security Journal

## 2026-03-08 - Endpoint Override Host and Length Validation
**Vulnerability:** `SettingsStore.usableEndpointURL` only verified that the parsed URL's scheme was `http` or `https`, omitting hostname existence/validation and length limits. URLs such as `https://` or `http:///path` parsed successfully in Foundation URL without a hostname, resulting in malformed requests, potential request routing ambiguities, or SSRF risks when constructing HTTP requests.
**Learning:** In Foundation `URL(string:)`, strings like `https://` or `http:///path` parse with `.scheme == "https"` or `"http"` while `.host` is `nil` or empty. When downstream network layers concatenate paths or send requests, hostless URLs cause runtime network issues or routing anomalies.
**Prevention:** Always validate that `url.host` exists and is non-empty after trimming, enforce input length limits to prevent DoS, and whitelist allowed schemes (`http`, `https`).
