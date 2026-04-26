import Foundation

// MARK: - Hogushi Engine
//
// Determines whether a Concept Translation attempt successfully melts a heroine's
// philosophical shield.
//
// ┌──────────────────────────────────────────────────────────┐
// │  THE HOGUSHI EQUATION                                    │
// │                                                          │
// │  score  = translationPower + playerConceptTranslation    │
// │                                                          │
// │  score >= difficulty      → SUCCESS  (gaugeGain: 10)     │
// │  score >= difficulty × 2  → PERFECT  (gaugeGain: 25)     │
// │  score <  difficulty      → FAILED   (gaugeGain:  0)     │
// └──────────────────────────────────────────────────────────┘
//
// Difficulty reference:
//   Epicurus (garden_club):      2  — tutorial, difficulty 2 means even score 3 succeeds
//   Nietzsche (tsundere):        3
//   Socrates (questioner):       4
//   Hume (skeptic_pessimist):    5
//   Kant (rules_obsessed):       6
//   Descartes (doubts_everything): 7
//   Wittgenstein (taciturn):     8  — hardest; even score 15 barely hits perfect (2×8=16)

final class HogushiEngine {

    // Per-archetype difficulty values
    private static let difficulty: [String: Int] = [
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
        "garden_club":           2,   // ← Epicurus, tutorial friendly
        "math_prodigy":          5,
        "daydreamer":            3,
        "math_tutor":            6,
        "taciturn":              8,   // ← Wittgenstein, end-game
    ]

    // MARK: - Evaluate

    func evaluate(
        translationPower: Int,
        playerConceptTranslation: Int,
        heroine: Heroine
    ) -> HogushiResult {
        let d     = Self.difficulty[heroine.archetype] ?? 5
        let score = translationPower + playerConceptTranslation

        if score >= d * 2 {
            return HogushiResult(
                success:   true,
                gaugeGain: 25,
                message:   "「\(heroine.nameJP)」の論理の鎧が、完全に溶けていく……"
            )
        } else if score >= d {
            return HogushiResult(
                success:   true,
                gaugeGain: 10,
                message:   "「\(heroine.nameJP)」の言葉が、少し柔らかくなった。"
            )
        } else {
            return HogushiResult(
                success:   false,
                gaugeGain: 0,
                message:   "【詭弁の壁】翻訳が届かなかった。詭弁耐性が削られる。"
            )
        }
    }
}
