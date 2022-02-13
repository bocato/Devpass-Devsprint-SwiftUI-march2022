import Foundation

struct LaunchesResponse: Decodable {
    let docs: [Launch]
    let limit: Int
    let totalPages: Int
    let nextPage: Int
}

struct Launch: Decodable, Equatable {
    let id: String
    let name: String
    let links: Links
    let success: Bool
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
            let small: String
            let large: String
        }
    }
}
