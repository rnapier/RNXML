import XCTest
import RNXML

struct Entry: Hashable {
    var title: String
    var date: Date
    var link: String
}

final class RNXMLTests: XCTestCase {
    func testDaringFireball() throws {
        let url = Bundle.module.url(forResource: "daringfireball", withExtension: "xml")!
        let xml = try! Data(contentsOf: url)

        let document = try RNXMLParser().parse(data: xml)

        let feed = try document["feed"]
        let entries = try feed[all: "entry"].compactMap { entry in
            let title = try entry["title"].text
            let published = try entry["published"].text

            let links = entry[all: "link"].compactMap { entry in
                if let relation = entry.attributes["rel"], relation == "related" || relation == "alternate",
                   let href = entry.attributes["href"] {
                    return (relation: relation, href: href)
                } else {
                    return nil
                }
            }

            let link = links.first(where: { $0.relation == "related"} )?.href ?? links.first(where: { $0.relation == "alternate"} )?.href ?? "https://daringfireball.net"

            if let date = ISO8601DateFormatter().date(from: published) {
                return Entry(title: title, date: date, link: link)
            }

            return nil
        }

        print(entries)
    }
}
