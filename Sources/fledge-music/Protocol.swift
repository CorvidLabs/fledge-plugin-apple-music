import Foundation

struct InitMessage: Decodable {
    let type: String
    let args: [String]?
    let capabilities: Capabilities?
    let version: String?

    struct Capabilities: Decodable {
        let exec: Bool?
        let store: Bool?
        let metadata: Bool?
    }
}

struct ProtocolResponse: Decodable {
    let type: String
    let id: String
    let value: ResponseValue?
}

enum ResponseValue: Decodable {
    case string(String)
    case int(Int)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else {
            self = .null
        }
    }

    var stringValue: String? {
        if case .string(let s) = self { return s }
        if case .int(let i) = self { return String(i) }
        return nil
    }

    var intValue: Int? {
        if case .int(let i) = self { return i }
        if case .string(let s) = self { return Int(s) }
        return nil
    }
}

enum FledgeProtocol {
    private static let decoder = JSONDecoder()

    static func readInit() -> InitMessage? {
        guard let line = readLine() else { return nil }
        guard let data = line.data(using: .utf8) else { return nil }
        return try? decoder.decode(InitMessage.self, from: data)
    }

    static func sendSelect(id: String, message: String, options: [String]) {
        let optionsJson = options.map { "\"\(escapeJson($0))\"" }.joined(separator: ",")
        let json = """
        {"type":"select","id":"\(escapeJson(id))","message":"\(escapeJson(message))","options":[\(optionsJson)]}
        """
        print(json)
        fflush(stdout)
    }

    static func sendLog(_ message: String, level: String = "info") {
        let json = """
        {"type":"log","level":"\(escapeJson(level))","message":"\(escapeJson(message))"}
        """
        print(json)
        fflush(stdout)
    }

    static func sendOutput(_ text: String) {
        let json = """
        {"type":"output","text":"\(escapeJson(text))\\n"}
        """
        print(json)
        fflush(stdout)
    }

    static func readResponse() -> ProtocolResponse? {
        guard let line = readLine() else { return nil }
        guard let data = line.data(using: .utf8) else { return nil }
        return try? decoder.decode(ProtocolResponse.self, from: data)
    }

    private static func escapeJson(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
         .replacingOccurrences(of: "\"", with: "\\\"")
         .replacingOccurrences(of: "\n", with: "\\n")
         .replacingOccurrences(of: "\r", with: "\\r")
         .replacingOccurrences(of: "\t", with: "\\t")
    }
}
