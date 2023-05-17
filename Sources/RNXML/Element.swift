public struct RNXMLElement {
    public var tag: String
    public var attributes: [String: String]
    public var text: String = ""
    public var children: [RNXMLElement] = []
}

public enum RNXMLError: Swift.Error {
    case unexpectedToken(expected: [RNXMLToken], found: RNXMLToken)
    case dataTruncated
    case typeMismatch
    case dataCorrupted
    case missingValue
    case internalError
}

public extension Collection<RNXMLElement> {
    subscript (tag: String) -> RNXMLElement {
        get throws {
            if let result = first(where: { $0.tag == tag }) {
                return result
            } else {
                throw RNXMLError.missingValue
            }
        }
    }
}

public extension RNXMLElement {
    subscript (all tag: String) -> [RNXMLElement] {
        children.filter { $0.tag == tag }
    }
    subscript (tag: String) -> RNXMLElement {
        get throws { try children[tag] }
    }
}
