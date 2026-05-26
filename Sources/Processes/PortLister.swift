import Foundation

public struct ListeningPort: Sendable, Equatable {
    public let port: Int
    public let pid: Int32
    public let protocolName: String  // "TCP" / "UDP"
}

public enum PortLister {
    /// Enumerate all listening TCP ports via lsof. Returns empty array on failure.
    public static func snapshot() -> [ListeningPort] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        task.arguments = ["-iTCP", "-sTCP:LISTEN", "-P", "-n", "-F", "pPn"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        var ports: [ListeningPort] = []
        var currentPid: Int32 = 0
        for line in output.split(separator: "\n") {
            let s = String(line)
            if s.hasPrefix("p"), let p = Int32(s.dropFirst()) {
                currentPid = p
            } else if s.hasPrefix("n") {
                // Format: nADDRESS:PORT (e.g. n*:5173 or n127.0.0.1:8000 or n[::1]:8080)
                let rest = String(s.dropFirst())
                if let colonIdx = rest.lastIndex(of: ":") {
                    let portStr = String(rest[rest.index(after: colonIdx)...])
                    if let port = Int(portStr) {
                        ports.append(ListeningPort(port: port, pid: currentPid, protocolName: "TCP"))
                    }
                }
            }
        }
        return ports
    }
}
