import Foundation

/// Parses a user-entered bridge address into scheme / host / optional port.
///
/// Accepts, in order of flexibility:
///   - `192.168.1.5`                  → http, scan default ports
///   - `192.168.1.5:7860`             → http on 7860
///   - `100.x.y.z:7860`               → Tailscale IP on a fixed port
///   - `mac.tailnet.ts.net`           → hostname (MagicDNS), http unless https:// given
///   - `host:8080`                    → host on a custom port
///   - `https://host` / `http://1.2.3.4:443` / `https://host:8443/path`
///
/// This unlocks reaching a bridge that is NOT on the same LAN (public IP,
/// port-forward, Tailscale Serve/Funnel) where the old code — hardcoded to
/// `http://` and ports 7860-7869 only — could never connect.
struct BridgeEndpoint {
    let scheme: String        // "http" or "https"
    let host: String
    let port: UInt16?         // nil → caller scans the default port range

    /// Ports to try, in order, given the parsed endpoint.
    /// - explicit port → just that one
    /// - https without port → 443
    /// - http without port → the legacy 7860-7869 scan
    var candidatePorts: [UInt16] {
        if let port { return [port] }
        return scheme == "https" ? [443] : Array(UInt16(7860)...UInt16(7869))
    }

    /// Builds a base URL (no trailing path) for a given port.
    func baseURL(port: UInt16) -> URL? {
        URL(string: "\(scheme)://\(host):\(port)")
    }

    static func parse(_ raw: String) -> BridgeEndpoint? {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }

        // Optional scheme.
        var scheme = "http"
        if let r = s.range(of: "://") {
            scheme = String(s[s.startIndex..<r.lowerBound]).lowercased()
            s = String(s[r.upperBound...])
        }
        guard scheme == "http" || scheme == "https" else { return nil }

        // Drop any trailing path / query.
        if let slash = s.firstIndex(where: { $0 == "/" || $0 == "?" }) {
            s = String(s[s.startIndex..<slash])
        }
        guard !s.isEmpty else { return nil }

        // host[:port]  (IPv6 in brackets not supported.)
        var host = s
        var port: UInt16? = nil
        if let colon = s.lastIndex(of: ":") {
            let hostPart = String(s[s.startIndex..<colon])
            let portPart = String(s[s.index(after: colon)...])
            if !hostPart.isEmpty, let p = UInt16(portPart) {
                host = hostPart
                port = p
            }
        }

        guard !host.isEmpty else { return nil }
        return BridgeEndpoint(scheme: scheme, host: host, port: port)
    }
}
