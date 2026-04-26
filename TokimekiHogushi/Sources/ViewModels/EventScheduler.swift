import Foundation
import Combine

// MARK: - EventScheduler
//
// Evaluates all EventTriggers whenever heroine state changes.
// Returns the highest-priority trigger that is newly ready to fire.
//
// Flow:
//   ScenarioManager.selectChoice() mutates HeroineState
//       ↓
//   EventScheduler.evaluate(heroineId:) is called
//       ↓
//   Checks each unfired trigger for that heroine (sorted by priority desc)
//       ↓
//   Returns first trigger where ALL conditions pass
//       ↓
//   ScenarioManager loads the new scenario chapter
//
// Trigger conditions are AND-ed within one EventTrigger.
// To express OR logic, define two separate EventTrigger entries with the same scenarioId.

final class EventScheduler: ObservableObject {
    // Injected — EventScheduler reads but does not own these
    var heroineManager: HeroineManager?
    var playerStats: PlayerStatsManager?

    // All known triggers; loaded from JSON at app start
    private(set) var triggers: [EventTrigger] = []

    init() {
        triggers = Self.loadDefaultTriggers()
    }

    // MARK: - Evaluate
    //
    // Call this after any state mutation (hogushi result, trust raise, chapter end).
    // Returns the EventTrigger that should fire next, or nil if nothing is ready.

    func evaluate(heroineId: String) -> EventTrigger? {
        let pending = triggers
            .filter { $0.heroineId == heroineId && !$0.hasFired }
            .sorted { $0.priority > $1.priority }

        return pending.first { allConditionsMet($0) }
    }

    // MARK: - Mark Fired

    func markFired(triggerId: String) {
        guard let idx = triggers.firstIndex(where: { $0.id == triggerId }) else { return }
        triggers[idx].hasFired = true
    }

    // MARK: - Condition Evaluation
    //
    // Each condition is independent; all must pass for the trigger to fire.
    // Cross-heroine conditions look up another heroine's state by targetHeroineId.

    private func allConditionsMet(_ trigger: EventTrigger) -> Bool {
        guard let hm = heroineManager, let ps = playerStats else { return false }

        let selfState  = hm.state(for: trigger.heroineId)

        return trigger.conditions.allSatisfy { cond in
            switch cond.kind {

            // ── Intra-heroine ──────────────────────────────────────────────
            case .gaugeMin:
                return selfState.tokimekiGauge >= cond.threshold

            case .gaugeMax:
                return selfState.tokimekiGauge <= cond.threshold

            case .shieldMax:
                // "shield has weakened to at most X"
                return selfState.shieldIntegrity <= cond.threshold

            case .trustMin:
                return selfState.trustLevel >= cond.threshold

            case .philosophyRespectMin:
                return selfState.philosophyRespect >= cond.threshold

            case .hogushiSuccessMin:
                return selfState.hogushiSuccessCount >= cond.threshold

            case .hogushiFailMin:
                // Sartre's route: he opens up if you've genuinely struggled
                return selfState.hogushiFailCount >= cond.threshold

            // ── Player stats ───────────────────────────────────────────────
            case .playerConceptMin:
                return ps.stats.conceptTranslation >= cond.threshold

            case .playerLogicMin:
                return ps.stats.logicConstruction >= cond.threshold

            // ── Cross-heroine ──────────────────────────────────────────────
            case .otherGaugeMin:
                guard let otherId = cond.targetHeroineId else { return false }
                return hm.state(for: otherId).tokimekiGauge >= cond.threshold

            case .otherChapterCleared:
                guard let otherId = cond.targetHeroineId else { return false }
                // "other heroine's chapter N has been cleared" = currentChapter > threshold
                return hm.state(for: otherId).currentChapter > cond.threshold
            }
        }
    }

    // MARK: - Default Trigger Table
    //
    // This is the master event schedule for the game.
    // Designers edit these values to tune the pacing per heroine.
    //
    // Reading guide for conditions:
    //   gaugeMin 30       = wait until tokimekiGauge reaches 30
    //   shieldMax 80      = wait until shield has dropped to 80 or below
    //   trustMin 1        = at least one genuine moment shared
    //   hogushiFailMin 3  = player must have failed at least 3 times (Sartre's special rule)

    static func loadDefaultTriggers() -> [EventTrigger] {
        [
            // ── Nietzsche ──────────────────────────────────────────────────
            // ch02: needs the first crack in her armor (shield < 80) and basic trust
            EventTrigger(id: "n_ch02", heroineId: "nietzsche", scenarioId: "nietzsche_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,      threshold: 30, targetHeroineId: nil),
                             TriggerCondition(kind: .shieldMax,     threshold: 80, targetHeroineId: nil),
                             TriggerCondition(kind: .trustMin,      threshold: 1,  targetHeroineId: nil),
                         ]),

            // ch03 ("真のデレ"): shield must be mostly gone, gauge high
            EventTrigger(id: "n_ch03", heroineId: "nietzsche", scenarioId: "nietzsche_ch03",
                         chapter: 3, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,      threshold: 65, targetHeroineId: nil),
                             TriggerCondition(kind: .shieldMax,     threshold: 30, targetHeroineId: nil),
                             TriggerCondition(kind: .trustMin,      threshold: 3,  targetHeroineId: nil),
                         ]),

            // ── Plato ──────────────────────────────────────────────────────
            // ch02: Plato won't advance until Socrates ch01 is cleared
            // (they are philosophically linked; Plato was Socrates' student)
            EventTrigger(id: "pl_ch02", heroineId: "plato", scenarioId: "plato_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,           threshold: 25, targetHeroineId: nil),
                             TriggerCondition(kind: .otherChapterCleared, threshold: 1,  targetHeroineId: "socrates"),
                         ]),

            // ch03: Plato demands player has serious philosophical grounding
            EventTrigger(id: "pl_ch03", heroineId: "plato", scenarioId: "plato_ch03",
                         chapter: 3, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,            threshold: 60, targetHeroineId: nil),
                             TriggerCondition(kind: .philosophyRespectMin, threshold: 5,  targetHeroineId: nil),
                             TriggerCondition(kind: .playerLogicMin,       threshold: 4,  targetHeroineId: nil),
                         ]),

            // ── Sartre ─────────────────────────────────────────────────────
            // ch02 (special rule): Sartre only respects the player who has genuinely struggled.
            // He does NOT unlock by gauge alone — you must fail hogushi attempts.
            EventTrigger(id: "sa_ch02", heroineId: "sartre", scenarioId: "sartre_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,        threshold: 20, targetHeroineId: nil),
                             TriggerCondition(kind: .hogushiFailMin,  threshold: 3,  targetHeroineId: nil),
                         ]),

            // ── Kant ───────────────────────────────────────────────────────
            // ch02: Kant needs philosophyRespect before she lowers her guard even slightly
            EventTrigger(id: "ka_ch02", heroineId: "kant", scenarioId: "kant_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,            threshold: 25, targetHeroineId: nil),
                             TriggerCondition(kind: .philosophyRespectMin, threshold: 3,  targetHeroineId: nil),
                             TriggerCondition(kind: .playerLogicMin,       threshold: 3,  targetHeroineId: nil),
                         ]),

            // ── Wittgenstein ───────────────────────────────────────────────
            // Hardest unlock: gauge, shield, trust, AND high player logic.
            // She literally cannot be reached without earning her respect first.
            EventTrigger(id: "wi_ch02", heroineId: "wittgenstein", scenarioId: "wittgenstein_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,            threshold: 30, targetHeroineId: nil),
                             TriggerCondition(kind: .shieldMax,           threshold: 60, targetHeroineId: nil),
                             TriggerCondition(kind: .trustMin,            threshold: 2,  targetHeroineId: nil),
                             TriggerCondition(kind: .philosophyRespectMin, threshold: 7,  targetHeroineId: nil),
                             TriggerCondition(kind: .playerLogicMin,       threshold: 6,  targetHeroineId: nil),
                         ]),

            // ── Epicurus ───────────────────────────────────────────────────
            // Easiest unlock: just spend time with her (gauge + trust, no respect needed)
            EventTrigger(id: "ep_ch02", heroineId: "epicurus", scenarioId: "epicurus_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,   threshold: 20, targetHeroineId: nil),
                             TriggerCondition(kind: .trustMin,   threshold: 1,  targetHeroineId: nil),
                         ]),

            // ── Schopenhauer ───────────────────────────────────────────────
            // ch02: needs gauge but also the player to have a good Sophistry Resistance score.
            // She won't trust someone who folds under philosophical pressure.
            EventTrigger(id: "sc_ch02", heroineId: "schopenhauer", scenarioId: "schopenhauer_ch02",
                         chapter: 2, priority: 10,
                         conditions: [
                             TriggerCondition(kind: .gaugeMin,          threshold: 25, targetHeroineId: nil),
                             TriggerCondition(kind: .hogushiSuccessMin, threshold: 2,  targetHeroineId: nil),
                         ]),
        ]
    }
}
