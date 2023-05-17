import Foundation

public class RNXMLParser {
    public init() {}
    
    public func parse(data: Data) throws -> [RNXMLElement] {
        var tokens = try RNXMLTokenizer().allTokens(from: data)[...]
        let value = try parseElements(for: &tokens)
        guard tokens.isEmpty else { throw RNXMLError.unexpectedToken(expected: [], found: tokens.first!) }
        return value
    }

    private func parseElements<Tokens>(for tokens: inout Tokens) throws -> [RNXMLElement]
    where Tokens: Collection<RNXMLToken>, Tokens.SubSequence == Tokens {
        var elements: [RNXMLElement] = []

        while !tokens.isEmpty {
            let token = try tokens.requireToken()
            if case let .elementStart(name: name, attributes: attributes) = token {
                elements.append(try parseElement(for: &tokens, name: name, attributes: attributes))
            } else {
                throw RNXMLError.unexpectedToken(expected: [.elementStart(name: "", attributes: [:])], found: token) // FIXME: Better error
            }
        }
        return elements
    }

    private func parseElement<Tokens>(for tokens: inout Tokens, name: String, attributes: [String: String]) throws -> RNXMLElement
    where Tokens: Collection<RNXMLToken>, Tokens.SubSequence == Tokens {

        var children: [RNXMLElement] = []
        var text = ""

        while !tokens.isEmpty {
            let token = try tokens.requireToken()
            switch token {
            case let .elementStart(name: name, attributes: attributes):
                children.append(try parseElement(for: &tokens, name: name, attributes: attributes))
            case let .text(string):
                text = string   // FIXME: Not handling error cases well
            case let .elementEnd(name: endName) where name == endName:
                return RNXMLElement(tag: name, attributes: attributes, text: text, children: children)
            default:
                throw RNXMLError.unexpectedToken(expected: [.elementEnd(name: name), .elementStart(name: "", attributes: [:]), .text("")], found: token)    // FIXME: Better error
            }
        }
        throw RNXMLError.dataTruncated
    }
}

private extension Collection<RNXMLToken> where SubSequence == Self {
    mutating func requireToken() throws -> RNXMLToken {
        return try popFirst() ?? { throw RNXMLError.dataTruncated }()
    }
}
