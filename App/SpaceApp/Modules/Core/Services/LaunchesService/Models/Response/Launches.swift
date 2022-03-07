import Foundation

struct Launch: Decodable, Equatable {
    let id: String
    let name: String
    let links: Links
    let success: Bool?
    let details: String?
    let flightNumber: Int
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case links
        case success
        case details
        case flightNumber = "flight_number"
        case date = "date_utc"
    }
    
    struct Links: Decodable, Equatable {
        let patch: Patch
        
        struct Patch: Decodable, Equatable {
            let small: String?
            let large: String?
        }
    }
}

#if DEBUG
extension Launch {
    static func fixture(
        id: String = "id",
        name: String = "Name",
        links: Launch.Links = .fixture(),
        success: Bool = true,
        details: String? = nil,
        flightNumber: Int = 123,
        date: Date = .init(timeIntervalSince1970: 1)
    ) -> Self {
        .init(
            id: id,
            name: name,
            links: links,
            success: success,
            details: details,
            flightNumber: flightNumber,
            date: date
        )
    }
}

extension Launch.Links {
    static func fixture(patch: Patch = .fixture()) -> Self {
        .init(patch: patch)
    }
}

extension Launch.Links.Patch {
    static func fixture(
        small: String = "http://www.mock.com/small-image.jpg",
        large: String = "http://www.mock.com/large-image.jpg"
    ) -> Self {
        .init(small: small, large: large)
    }
}

#endif
