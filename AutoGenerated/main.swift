//
//  main.swift
//  AutoGenerated
//
//  Created by Tbxark on 2018/12/20.
//  Copyright © 2018 Tbxark. All rights reserved.
//

import Foundation

class ParsingController {

    class DocumentTable {
        class Row {
            var field: String?
            var type: String?

            var note: String?
            var isOptionalByRow: Bool?
            var isOptional: Bool {
                return isOptionalByRow ?? note?.starts(with: "Optional") ?? true
            }
            var camelCaseField: String? {
                return field?.split(separator: "_")
                    .map { String($0) }
                    .enumerated()
                    .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
                    .joined()
            }
        }
        var title: String?
        var note: String?
        var list = [Row]()
        var unions: [String]?
    }

    private let aTagRegex = try! NSRegularExpression(pattern: "<a href=\"[^>]*\">[^>^<]*</a>", options: .caseInsensitive)
    private let hrefRegex =  try! NSRegularExpression(pattern: "href=\"http[^>]*\"", options: .caseInsensitive)
    private let uppercaseLetters: Set<Character> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    private var typeMap = ["Integer": "Int", "Float number": "Float", "Boolean": "Bool", "True": "Bool",
                           "InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply": "ReplyMarkup",
                           "Integer or String": "ChatId", "InputFile or String": "FileOrPath"]
    private var superClass = [String: String]()

    func parse(url: URL) throws -> (type: String, method: String) {

        let text = try String(contentsOf: url)
        let tables =  parseDocument(text)
        var telegramModel = ""
        var telegramRequest = ""
        let customEnum = [("ReplyMarkup", ["InlineKeyboardMarkup", "ReplyKeyboardMarkup", "ReplyKeyboardRemove", "ForceReply"]),
                          ("ChatId", ["Int", "String"]),
                          ("FileOrPath", ["InputFile", "String"])]
        for (name, cases) in customEnum {
            var code = "\n"
            code += "/// \(name): \(cases.joined(separator: " or "))\n"
            code += unionBuilder(name: "\(name)", cases: cases)
            code += "\n"
            telegramModel += code.components(separatedBy: .newlines).map({ $0.isEmpty ? $0 : "\t" + $0 }).joined(separator: "\n")
        }

        for item in tables {
            if let title = item.title, let char = title.first {
                if let unions = item.unions {
                    var code = ""
                    code += "\n/// \(item.note ?? "")\n"
                    code += unionBuilder(name: title, cases: unions)
                    telegramModel += code.components(separatedBy: .newlines).map({ $0.isEmpty ? $0 : "\t" + $0 }).joined(separator: "\n")
                } else if uppercaseLetters.contains(char) {
                    let code = classBuilder(item)
                    telegramModel += code.components(separatedBy: .newlines).map({ $0.isEmpty ? $0 : "\t" + $0 }).joined(separator: "\n")
                } else {
                    let code = methodBuilder(item)
                    telegramRequest += code.components(separatedBy: .newlines).map({ $0.isEmpty ? $0 : "\t" + $0 }).joined(separator: "\n")
                }
            }
        }
        return (type: typeFileBuilder(content: telegramModel),
                method: methodFileBuilder(content: telegramRequest))
    }

}

extension ParsingController {

    private func eitherBuilder(_ raw: [String]) -> String {
        var className = ""
        var temp = raw
        guard raw.count >= 2 else {
            return raw.first ?? "Void"
        }
        let last = temp.removeLast()
        for i in temp {
            className += "Either<\(i), "
        }
        className += "\(last)\(Array(repeating: ">", count: raw.count - 1).joined())"
        return className
    }

    private func unionBuilder(name: String, cases: [String], fastInitialization: Bool = true) -> String {
        var code = "public enum \(name): Codable {\n\n"
        var prefix = ""
        var suffix = ""
        var findPrefix = true
        var findSuffix = true
        guard let firstCase = cases.first else { return "" }
        while findPrefix {
            let prefixTemp = firstCase.prefix(prefix.count + 1)
            for caseValue in cases {
                if caseValue.hasPrefix(prefixTemp) {
                    continue
                }
                findPrefix = false
            }
            if findPrefix {
                prefix = String(prefixTemp)
            } else {
                break
            }
        }
        while findSuffix {
            let suffixTemp = firstCase.suffix(suffix.count + 1)
            for caseValue in cases {
                if caseValue.hasSuffix(suffixTemp) {
                    continue
                }
                findSuffix = false
            }
            if findSuffix {
                suffix = String(suffixTemp)
            } else {
                break
            }
        }
        var fastInit = ""
        var decoder = "\n\tpublic init(from decoder: Decoder) throws {\n\t\tlet container = try decoder.singleValueContainer()"
        var encode = "\n\tpublic func encode(to encoder: Encoder) throws {\n\t\tvar container = encoder.singleValueContainer()\n\t\tswitch self {"

        for (i, caseValue) in cases.enumerated() {
            var name = caseValue.dropFirst(prefix.count).dropLast(suffix.count)
            name = name.prefix(1).lowercased() + name.dropFirst()
            code += "\tcase \(name)(\(caseValue))\n"
            decoder += "\n\t\t\(i > 0 ? "} else " : "")if let \(name) = try? container.decode(\(caseValue).self) {\n"
            decoder += "\t\t\tself = .\(name)(\(name))"
            encode  += "\n\t\tcase .\(name)(let \(name)):\n"
            encode  += "\t\t\ttry container.encode(\(name))"
            if fastInitialization {
                fastInit += "\n\tpublic init(_ \(name): \(caseValue)) {\n\t\tself = .\(name)(\(name))\n\t}\n"
            }
        }

        decoder += "\n\t\t} else {\n\t\t\tthrow NSError(domain: \"org.telegram.api\", code: -1, userInfo: [\"name\": \"\(name)\"])\n\t\t}\n\t}\n"
        encode += "\n\t\t}\n\t}\n}"
        code += decoder
        if fastInitialization {
            code += fastInit
        }
        code += encode
//        code += "\n"s
        return code
    }

    private func classBuilder(_ table: DocumentTable) -> String {
        var code = ""
        guard let title = table.title else { return code }
        code += "\n/// \(table.note ?? "")\n"
        if table.list.isEmpty {
            code += "public struct \(title): \(superClass[title] ?? "Codable") {\n\n}\n"
            return code
        } else {
            code += "public class \(title): \(superClass[title] ?? "Codable") {\n\n"
        }

        var propertyList = ""
        var initMethod   = "\tpublic init("
        var initBody     = ""
        var codingKeys   = "\tprivate enum CodingKeys: String, CodingKey {\n"
        var comment = "\t/// \(title) initialization\n\(table.list.isEmpty ? "" : "\t///\n")"
        for pro in table.list {
            if let f = pro.camelCaseField, let t =  pro.type, let realField = pro.field {
                let note = pro.note ?? ""
                propertyList += "\t/// \(note)\n"
                propertyList += "\tpublic var \(f): \(t)\(pro.isOptional ? "?" : "")\n\n"
                initMethod += "\(f): \(t)\(pro.isOptional ? "? = nil" : ""), "
                initBody += "\t\tself.\(f) = \(f)\n"
                comment += "\t/// - parameter \(f):  \(pro.note ?? "")\n"
                codingKeys += "\t\tcase \(f) = \"\(realField)\"\n"
            }
        }
        comment += "\t///\n\t/// - returns: The new `\(title)` instance.\n"
        comment += "\t///\n"
        if table.list.count > 0 {
            initMethod.removeLast(2)
        }
        initMethod += ") {\n"
        initMethod += initBody
        initMethod += "\t}\n"
        codingKeys += "\t}\n"

        code += propertyList
        code += comment
        code += initMethod + "\n"
        code += codingKeys + "\n"
        code += "}\n"
        return code
    }

    private func methodBuilder(_ table: DocumentTable) -> String {
        var code = ""
        guard let title = table.title else { return code }
        var comment = "/// \(table.note ?? "")\n\(table.list.isEmpty ? "" : "///\n")"
        var method = "static public func \(title)("
        var body = ""
        for pro in table.list {
            if let f = pro.camelCaseField, let t =  pro.type, let realField = pro.field {
                comment += "/// - parameter \(f):  \(pro.note ?? "")\n"
                method += "\(f): \(t)\(pro.isOptional ? "? = nil" : ""), "
                body += "\tparameters[\"\(realField)\"] = \(f)\n"
            }
        }
        comment += "///\n"
        comment += "/// - returns: The new `TelegramAPI.Request` instance.\n"
        comment += "///\n"
        if table.list.count > 0 {
            method.removeLast(2)
        }
        method += ") -> Request {\n\(table.list.isEmpty ? "" : "\tvar parameters = [String: Any]()\n")"
        method += body
        method += "\treturn Request(method: \"\(title)\", body: \(table.list.isEmpty ? "[:]" : "parameters"))\n"
        method += "}\n\n"

        code += comment
        code += method
        return code
    }
}

extension ParsingController {

    private func parseDocument(_ text: String) -> [DocumentTable] {
        var tables = [DocumentTable]()
        var currentTable: DocumentTable?
        var currentRow: DocumentTable.Row?
        for line in text.split(separator: "\n") {
            if line.starts(with: "<h4>") {
                currentTable = nil
                currentRow = nil
                let title = parseHTML(String(line), keepLink: false)
                if title.contains(".") || title.contains(" ") {
                    continue
                }
                currentTable = DocumentTable()
                tables.append(currentTable!)
                currentTable?.title = title
            } else if line.starts(with: "<p>") {
                currentTable?.note = parseHTML(String(line))
            } else if line == "<tr>" {
                currentRow = DocumentTable.Row()
                currentTable?.list.append(currentRow!)
            } else if line == "</tr>" {
                currentRow = nil
            } else if line.starts(with: "<ul>") {
                currentTable?.unions = []
            } else if line.starts(with: "<li>") {
                currentTable?.unions?.append(parseHTML(String(line)))
            } else if line.starts(with: "<td>") {
                if currentRow?.field == nil {
                    currentRow?.field = parseHTML(String(line), keepLink: false)
                } else if currentRow?.type == nil {
                    currentRow?.type = fixType(parseHTML(String(line), keepLink: false))
                } else if currentRow?.note == nil {
                    if line == "<td>Yes</td>" {
                        currentRow?.isOptionalByRow = false
                    } else if line == "<td>Optional</td>" {
                        currentRow?.isOptionalByRow = true
                    } else {
                        currentRow?.note = parseHTML(String(line))
                    }
                }
            } else if line.starts(with: "</table>") {
                currentTable = nil
            }
        }
        return tables
    }

    private func parseHTML(_ raw: String, keepLink: Bool = true) -> String {
        func removeTag(_ raw: String) -> String {
            return raw.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
        var result = raw as NSString
        if keepLink {
            while let aTagMache = aTagRegex.firstMatch(in: (result as String), options: [], range: NSRange(location: 0, length: result.length)) {
                let aTag = result.substring(with: aTagMache.range)
                let aTagNS = aTag as NSString
                if let hrefMach = hrefRegex.firstMatch(in: aTag, options: [], range: NSRange(location: 0, length: aTagNS.length)) {
                    let range = NSRange(location: hrefMach.range.location + 6, length: hrefMach.range.length - 7)
                    let newATag = "[\(removeTag(aTag))](\(aTagNS.substring(with: range)))"
                    result = result.replacingCharacters(in: aTagMache.range, with: newATag) as NSString
                } else {
                    result = result.replacingCharacters(in: aTagMache.range, with: removeTag(aTag)) as NSString
                }
            }
        }
        return removeTag((result as String))
    }

    private func fixType(_ raw: String) -> String {
        if let mapType = typeMap[raw] {
            return mapType
        } else if raw.starts(with: "Array of ") {
            let itemType = fixType(raw.replacingOccurrences(of: "Array of ", with: ""))
            return "[\(itemType)]"
        } else if raw.contains(" or ") {
            var maybe = [String]()
            for str in (raw as NSString).components(separatedBy: " or ") {
                maybe.append(fixType(str))
            }
            return eitherBuilder(maybe)
        } else if raw.contains(" and ") {
            var maybe = [String]()
            for str in (raw as NSString).components(separatedBy: " and ") {
                maybe.append(fixType(str))
            }
            return eitherBuilder(maybe)
        } else {
            return  raw
        }
    }
}

extension ParsingController {
    private func methodFileBuilder(content: String) -> String {
        return ("""
        import Foundation

        public struct TelegramAPI {

        \(content)}
        """).replacingOccurrences(of: "\t", with: "    ")
    }

    private func typeFileBuilder(content: String) -> String {
        return ("""
        import Foundation

        extension TelegramAPI {

            /// Telegram Request wrapper
            public struct Request {
                public let method: String
                public let body: [String: Any]
            }

            /// AnyEncodable
            public struct AnyEncodable: Encodable {
                private let encodable: Encodable

                public init(_ encodable: Encodable) {
                    self.encodable = encodable
                }

                public func encode(to encoder: Encoder) throws {
                    try encodable.encode(to: encoder)
                }

                public static func encode(_ dict: [String: Any]) throws -> Data {
                    var map = [String: AnyEncodable]()
                    for (k, v) in dict {
                        if let e = v as? Encodable {
                            map[k] = AnyEncodable(e)
                        }
                    }
                    let data = try JSONEncoder().encode(map)
                    return data
                }
            }

            /// May contain two different types
            public enum Either<A: Codable, B: Codable>: Codable {
                case left(A)
                case right(B)

                public var value: Any {
                    switch self {
                    case .left(let a):
                        return a
                    case .right(let b):
                        return b
                    }
                }

                public var left: A? {
                    switch self {
                    case .left(let a):
                        return a
                    case .right:
                        return nil
                    }
                }

                public var right: B? {
                    switch self {
                    case .left:
                        return nil
                    case .right(let b):
                        return b
                    }
                }

                public init(_ a: A) {
                    self = .left(a)
                }

                public init(_ b: B) {
                    self = .right(b)
                }

                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let a = try? container.decode(A.self) {
                        self = .left(a)
                    } else {
                        let b = try container.decode(B.self)
                        self = .right(b)
                    }
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                        case .left(let a):
                            try container.encode(a)
                        case .right(let b):
                            try container.encode(b)
                    }
                }
            }
            \(content)
        }
        """).replacingOccurrences(of: "\t", with: "    ")
    }
}

let controller = ParsingController()

do {
    let value = try controller.parse(url: URL(string: "https://core.telegram.org/bots/api")!)
    let filePath = #file
    let path = filePath == "main.swift" ? ".." : filePath.replacingOccurrences(of: "AutoGenerated/main.swift", with: "")
    let modelPath = "\(path)/Sources/TelegramModel.swift"
    let apiPath = "\(path)/Sources/TelegramBotAPI.swift"
    if FileManager.default.fileExists(atPath: modelPath) {
        try FileManager.default.removeItem(atPath: modelPath)
    }
    if FileManager.default.fileExists(atPath: apiPath) {
        try FileManager.default.removeItem(atPath: apiPath)
    }
    try value.type.write(toFile: modelPath, atomically: true, encoding: .utf8)
    try value.method.write(toFile: apiPath, atomically: true, encoding: .utf8)
    print("Success!")
} catch {
    print(error)
}
