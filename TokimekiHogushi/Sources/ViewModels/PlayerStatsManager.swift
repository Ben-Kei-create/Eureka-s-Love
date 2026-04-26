import Foundation
import Combine

final class PlayerStatsManager: ObservableObject {
    @Published private(set) var stats: PlayerStats

    private let saveKey = "playerStats"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            stats = saved
        } else {
            stats = .initial
        }
    }

    func gain(logicConstruction delta: Int = 0, conceptTranslation: Int = 0, sophistryResistance: Int = 0) {
        stats.logicConstruction    = min(PlayerStats.max.logicConstruction,    stats.logicConstruction + delta)
        stats.conceptTranslation   = min(PlayerStats.max.conceptTranslation,   stats.conceptTranslation + conceptTranslation)
        stats.sophistryResistance  = min(PlayerStats.max.sophistryResistance,  stats.sophistryResistance + sophistryResistance)
        persist()
    }

    func drain(sophistryDamage: Int) {
        stats.sophistryResistance = max(0, stats.sophistryResistance - sophistryDamage)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}
