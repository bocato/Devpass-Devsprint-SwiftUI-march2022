import Foundation

struct LaunchesPage: Decodable {
    let docs: [Launch]
    let limit: Int
    let totalPages: Int
    let nextPage: Int
}
