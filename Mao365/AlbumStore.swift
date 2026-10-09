import Combine
import Foundation

struct DayDesign: Decodable, Identifiable {
    let id: String
    let day: Int
    let date: String
    let province: String
    let region: String
    let scene: String
    let coverageRegions: [String]
    let solarTermEvent: String

    var regionDisplay: String {
        "\(province) · \(coverageRegions.joined(separator: " / "))"
    }

    func matches(_ search: String) -> Bool {
        guard !search.isEmpty else { return true }
        return [id, "Day \(day)", date, province, region, scene,
                coverageRegions.joined(separator: " "), solarTermEvent]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(search)
    }
}

private struct AlbumDocument: Decodable {
    let designs: [DayDesign]
}

@MainActor
final class AlbumStore: ObservableObject {
    @Published private(set) var designs: [DayDesign] = []
    @Published private(set) var errorMessage: String?

    init(bundle: Bundle = .main) {
        do {
            guard let url = bundle.url(forResource: "album-2027", withExtension: "json") else {
                throw AlbumError.missingResource
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let document = try decoder.decode(AlbumDocument.self, from: Data(contentsOf: url))
            let sorted = document.designs.sorted { $0.day < $1.day }
            guard sorted.map(\.day) == Array(1...365),
                  Set(sorted.map(\.id)).count == 365 else {
                throw AlbumError.invalidCalendar
            }
            designs = sorted
        } catch {
            errorMessage = "画册暂时无法打开，请重新启动。"
            NSLog("Mao365 album loading failed: %@", String(describing: error))
        }
    }

    private enum AlbumError: Error {
        case missingResource
        case invalidCalendar
    }
}
