import SwiftUI

@main
struct TokimekiHogushiApp: App {
    @StateObject private var scenario        = ScenarioManager()
    @StateObject private var heroineManager  = HeroineManager()
    @StateObject private var playerStats     = PlayerStatsManager()
    @StateObject private var eventScheduler  = EventScheduler()

    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(scenario)
                .environmentObject(heroineManager)
                .environmentObject(playerStats)
                .environmentObject(eventScheduler)
                .onAppear { wireUp() }
        }
    }

    // Cross-inject the weak references that managers need to read each other
    private func wireUp() {
        scenario.playerStats    = playerStats
        scenario.heroineManager = heroineManager
        scenario.eventScheduler = eventScheduler
        eventScheduler.heroineManager = heroineManager
        eventScheduler.playerStats    = playerStats
        lockToPortrait()
    }

    private func lockToPortrait() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
}
