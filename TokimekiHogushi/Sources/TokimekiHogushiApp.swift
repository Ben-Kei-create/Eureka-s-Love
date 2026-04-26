import SwiftUI

@main
struct TokimekiHogushiApp: App {
    @StateObject private var gameState    = GameStateManager()
    @StateObject private var heroineManager = HeroineManager()
    @StateObject private var playerStats  = PlayerStatsManager()

    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(gameState)
                .environmentObject(heroineManager)
                .environmentObject(playerStats)
                // Lock to portrait
                .onAppear {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                    }
                }
        }
    }
}
