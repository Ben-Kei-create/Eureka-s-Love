import SwiftUI

@main
struct TokimekiHogushiApp: App {
    @StateObject private var scenario       = ScenarioManager()
    @StateObject private var heroineManager = HeroineManager()
    @StateObject private var playerStats    = PlayerStatsManager()

    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(scenario)
                .environmentObject(heroineManager)
                .environmentObject(playerStats)
                .onAppear { lockToPortrait() }
        }
    }

    private func lockToPortrait() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
}
