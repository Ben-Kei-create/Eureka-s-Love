import Foundation

// MARK: - Hogushi Engine
//
// ┌──────────────────────────────────────────────────────────────────┐
// │  THE HOGUSHI EQUATION                                            │
// │                                                                  │
// │  score  = translationPower + playerConceptTranslation            │
// │                                                                  │
// │  score >= difficulty × 2  → PERFECT  (gaugeGain:25, shield:-20) │
// │  score >= difficulty      → SUCCESS  (gaugeGain:10, shield:-10)  │
// │  score <  difficulty      → FAILED   (gaugeGain: 0, shield:  0) │
// └──────────────────────────────────────────────────────────────────┘
//
// shieldIntegrity also modifies difficulty at runtime:
//   shield 100–61: normal difficulty
//   shield 60–31:  difficulty - 1  (she's showing cracks; easier to reach)
//   shield 30–0:   difficulty - 2  (nearly broken; very open)
//
// This makes later chapters feel satisfying — the player's earlier hogushi
// successes compound into an easier emotional path forward.
//
// Difficulty table:
//   Epicurus (garden_club):       2  — tutorial
//   Nietzsche (tsundere):         3
//   Leibniz (forced_optimist):    3
//   Zhuangzi (daydreamer):        3
//   Socrates (questioner):        4
//   Confucius (tradition_strict): 4
//   Sartre (existential_angsty):  4
//   Mill (student_council):       4
//   Hume (skeptic_pessimist):     5
//   Beauvoir (fierce_feminist):   5
//   Arendt (journalism_president):5
//   Pascal (math_prodigy):        5
//   Wollstonecraft (rights_activist): 5
//   Schopenhauer (extreme_pessimist): 6
//   Spinoza (quiet_mathematician):    6
//   Kant (rules_obsessed):        6
//   Hypatia (math_tutor):         6
//   Plato (cool_aloof):           6  (but cross-heroine requirements gate chapters)
//   Descartes (doubts_everything): 7
//   Wittgenstein (taciturn):      8  — hardest

final class HogushiEngine {

    private static let baseDifficulty: [String: Int] = [
        "garden_club":           2,
        "tsundere":              3,
        "forced_optimist":       3,
        "daydreamer":            3,
        "questioner":            4,
        "tradition_strict":      4,
        "existential_angsty":    4,
        "student_council":       4,
        "skeptic_pessimist":     5,
        "fierce_feminist":       5,
        "journalism_president":  5,
        "math_prodigy":          5,
        "rights_activist":       5,
        "extreme_pessimist":     6,
        "quiet_mathematician":   6,
        "rules_obsessed":        6,
        "math_tutor":            6,
        "cool_aloof":            6,
        "doubts_everything":     7,
        "taciturn":              8,
    ]

    func evaluate(
        translationPower: Int,
        playerConceptTranslation: Int,
        heroine: Heroine,
        currentShieldIntegrity: Int
    ) -> HogushiResult {
        let base  = Self.baseDifficulty[heroine.archetype] ?? 5
        // Reduce difficulty as shield weakens — earlier hogushi success compounds
        let bonus = currentShieldIntegrity > 60 ? 0
                  : currentShieldIntegrity > 30 ? 1
                  :                               2
        let d     = max(1, base - bonus)
        let score = translationPower + playerConceptTranslation

        if score >= d * 2 {
            return HogushiResult(
                success:    true,
                gaugeGain:  25,
                shieldDrain: 20,
                message:    "「\(heroine.nameJP)」の論理の鎧が、完全に溶けていく……"
            )
        } else if score >= d {
            return HogushiResult(
                success:    true,
                gaugeGain:  10,
                shieldDrain: 10,
                message:    "「\(heroine.nameJP)」の言葉が、少し柔らかくなった。"
            )
        } else {
            return HogushiResult(
                success:    false,
                gaugeGain:  0,
                shieldDrain: 0,
                message:    "【詭弁の壁】翻訳が届かなかった。詭弁耐性が削られる。"
            )
        }
    }
}
