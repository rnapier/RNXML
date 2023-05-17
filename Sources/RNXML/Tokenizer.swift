import Foundation

public enum RNXMLToken {
    case elementStart(name: String, attributes: [String: String])
    case text(String)
    case elementEnd(name: String)
}

class RNXMLTokenizer: NSObject {
    var tokens: [RNXMLToken] = []
    var text: String = ""

    func allTokens(from data: Data) throws -> [RNXMLToken] {
        defer { reset() }
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            return tokens
        } else if let error = parser.parserError {
            throw error
        } else {
            assertionFailure("XMLParser failed with no error")
        }
        return tokens
    }

    func reset() {
        tokens.removeAll()
        text.removeAll()
    }
}

extension RNXMLTokenizer: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tokens.append(.elementStart(name: elementName, attributes: attributeDict))
    }

    private func emitTextIfPresent() {
        if !text.isEmpty {
            tokens.append(.text(text))
            text.removeAll(keepingCapacity: true)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        emitTextIfPresent()
        tokens.append(.elementEnd(name: elementName))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        text += String(decoding: CDATABlock, as: UTF8.self)
    }
}
