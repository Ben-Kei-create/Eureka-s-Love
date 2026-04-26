import Foundation

/// Evaluates whether a player's Concept Translation attempt successfully
/// "melts" the heroine's philosophical shield.
final class HogushiEngine {

    /// Base difficulty per heroine archetype (higher = harder to hogushi)
    private static let archetypeDifficulty: [String: Int] = [
        "tsundere":              3,
        "cool_aloof":            5,
        "questioner":            4,
        "rules_obsessed":        6,
        "fierce_feminist":       5,
        "tradition_strict":      4,
        "quiet_mathematician":   6,
        "skeptic_pessimist":     5,
        "existential_angsty":    4,
        "journalism_president":  5,
        "forced_optimist":       3,
        "doubts_everything":     7,
        "student_council":       4,
        "extreme_pessimist":     6,
        "rights_activist":       5,
        "garden_club":           2,
        "math_prodigy":          5,
        "daydreamer":            3,
        "math_tutor":            6,
        "taciturn":              8,
    ]

    /// Evaluate a hogushi attempt.
    /// - Parameters:
    ///   - translationPower: The dialogue choice's translation power value (1–10).
    ///   - playerConceptTranslation: Player's 概念翻訳力 stat.
    ///   - heroine: The heroine being addressed.
    /// - Returns: A `HogushiResult` with success flag, gauge gain, and flavour message.
    func evaluate(translationPower: Int, playerConceptTranslation: Int, heroine: Heroine) -> HogushiResult {
        let difficulty = Self.archetypeDifficulty[heroine.archetype] ?? 5
        let score = translationPower + playerConceptTranslation

        if score >= difficulty * 2 {
            // Perfect Hogushi
            return HogushiResult(success: true, gaugeGain: 25,
                                 message: "【解きメキほぐし 完了】\n"\(heroine.nameJP)の論理の鎧が、溶けていく…"")
        } else if score >= difficulty {
            // Standard Hogushi
            return HogushiResult(success: true, gaugeGain: 10,
                                 message: "【解きメキほぐし 完了】\n"\(heroine.nameJP)の言葉が、少し柔らかくなった。"")
        } else {
            // Failed attempt — heroine counter-attacks
            return HogushiResult(success: false, gaugeGain: 0,
                                 message: "【詭弁の壁】\n\(heroine.nameJP)の論理は、まだ解けていない。")
        }
    }
}
