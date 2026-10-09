import SwiftUI

@main
struct Mao365App: App {
    @StateObject private var album = AlbumStore()

    var body: some Scene {
        WindowGroup {
            AlbumView(album: album)
                .preferredColorScheme(.light)
        }
    }
}
