import Foundation
import SwiftUI

// MARK: - Design Tokens

enum TokimekiColors {
    static let background     = Color(red: 0.973, green: 0.957, blue: 0.937)
    static let heroineBubble  = Color(red: 0.710, green: 0.918, blue: 0.843)
    static let playerBubble   = Color(red: 1.000, green: 0.718, blue: 0.773)
    static let hogushiFlash   = Color(red: 1.000, green: 0.839, blue: 0.910)
    static let accent         = Color(red: 0.976, green: 0.608, blue: 0.698)
    static let textPrimary    = Color(red: 0.220, green: 0.200, blue: 0.220)
    static let textSecondary  = Color(red: 0.560, green: 0.540, blue: 0.560)
    static let cardBackground = Color.white.opacity(0.85)
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Player Stats

struct PlayerStats: Codable {
    var logicConstruction: Int    // 論理構築力
    var conceptTranslation: Int   // 概念翻訳力
    var sophistryResistance: Int  // 詭弁耐性

    static let initial = PlayerStats(logicConstruction: 1, conceptTranslation: 1, sophistryResistance: 30)
    static let max     = PlayerStats(logicConstruction: 10, conceptTranslation: 10, sophistryResistance: 100)
}

// MARK: - Heroine (static data — identity, visuals, archetype)

struct Heroine: Identifiable, Codable {
    let id: String
    let name: String
    let nameJP: String
    let archetype: String
    let shieldConcept: String
    let shieldConceptJP: String
    let spriteAsset: String
    let bubbleColorHex: String
    let introLine: String

    var bubbleColor: Color { Color(hex: bubbleColorHex) }
}

// MARK: - HeroineState (mutable runtime data — separate from identity)
//
// Each heroine has four independent parameters.
// They are stored separately from Heroine so the static roster
// never needs to be mutated for save/load purposes.
//
// ┌─────────────────┬───────┬──────────────────────────────────────────────────┐
// │ Parameter       │ Range │ What it means                                    │
// ├─────────────────┼───────┼──────────────────────────────────────────────────┤
// │ tokimekiGauge   │ 0–100 │ Overall romance progress. The primary visible    │
// │                 │       │ gauge. Rises with successful hogushi and events.  │
// ├─────────────────┼───────┼──────────────────────────────────────────────────┤
// │ shieldIntegrity │ 0–100 │ Strength of her philosophical armor.             │
// │                 │       │ Starts at 100. Each failed hogushi = no change.  │
// │                 │       │ Each successful hogushi drains it by 10–20.      │
// │                 │       │ At 0, she can no longer hide behind jargon:      │
// │                 │       │ unlocks the "dere" route and confession chapters.│
// ├─────────────────┼───────┼──────────────────────────────────────────────────┤
// │ trustLevel      │ 0–5   │ How many genuine "ordinary moments" you've       │
// │                 │       │ shared. Increments slowly (≈1 per chapter).      │
// │                 │       │ Gate for chapters that require real intimacy.    │
// ├─────────────────┼───────┼──────────────────────────────────────────────────┤
// │ philosophyRespect│ 0–10 │ Does she think you're intellectually serious?   │
// │                 │       │ Rises when player has high logicConstruction     │
// │                 │       │ or selects "deep reading" dialogue options.      │
// │                 │       │ Required by strict heroines (Kant, Wittgenstein).│
// └─────────────────┴───────┴──────────────────────────────────────────────────┘

struct HeroineState: Codable {
    var tokimekiGauge:      Int = 0    // 0–100
    var shieldIntegrity:    Int = 100  // 100–0  (lower = more vulnerable/open)
    var trustLevel:         Int = 0    // 0–5
    var philosophyRespect:  Int = 0    // 0–10

    var currentChapter:     Int = 1
    var hogushiSuccessCount: Int = 0   // lifetime successful hogushis
    var hogushiFailCount:    Int = 0   // lifetime failures (used by Sartre's conditions)

    var tokimekiProgress: Double { Double(tokimekiGauge) / 100.0 }
    var isShieldBroken:   Bool   { shieldIntegrity <= 0 }
}

// MARK: - Scenario Node

enum SpeakerRole: String, Codable {
    case heroine, player, narrator, system
}

// NodeEffect: what happens mechanically when this choice is taken.
//
// hogushiAttempt   — run HogushiEngine; on success: drain shieldIntegrity, raise tokimekiGauge
// sophAttack       — heroine attacks; drain player sophistryResistance
// statGain         — reward a player stat point (conceptTranslation++)
// gaugeRaise       — directly raise tokimekiGauge (no engine; used for scripted "dere" moments)
// trustRaise       — increment trustLevel (quiet, intimate moments, not hogushi)
// respectRaise     — increment philosophyRespect (player shows intellectual depth)
// sceneEnd         — mark chapter as cleared; EventScheduler checks for new events
enum NodeEffect: String, Codable {
    case none
    case hogushiAttempt
    case sophAttack
    case statGain
    case gaugeRaise
    case trustRaise
    case respectRaise
    case sceneEnd
}

struct DialogueChoice: Identifiable, Codable {
    let id: String
    let text: String
    let effect: NodeEffect
    let translationPower: Int   // hogushiAttempt only; 0 otherwise
    let nextNodeId: String
}

struct ScenarioNode: Identifiable, Codable {
    let id: String
    let speaker: SpeakerRole
    let text: String?
    let choices: [DialogueChoice]?
    let nextNodeId: String?
    let isHogushiNode: Bool
}

struct Scenario: Codable {
    let scenarioId: String
    let heroineId: String
    let chapter: Int
    let title: String
    let titleJP: String
    let nodes: [ScenarioNode]

    func node(id: String) -> ScenarioNode? {
        nodes.first { $0.id == id }
    }
}

// MARK: - Hogushi Result

struct HogushiResult {
    let success: Bool
    let gaugeGain: Int
    let shieldDrain: Int   // how much shieldIntegrity decreases on success
    let message: String
}

// MARK: - Event Trigger
//
// An EventTrigger describes ONE unlock-able event (scenario chapter, special CG, etc.)
// and the set of conditions that must ALL be true for it to fire.
//
// Conditions are AND-ed together. To OR, use separate EventTriggers with the same scenarioId.
//
// Example — Nietzsche ch02 fires when:
//   tokimekiGauge >= 30  AND  shieldIntegrity <= 70  AND  trustLevel >= 1
//
// Example — Plato ch03 fires when:
//   gaugeMin >= 60  AND  chapterCleared("socrates_ch01") is true
//   (cross-heroine: Plato won't open up until you've had a real conversation with Socrates)

struct EventTrigger: Codable, Identifiable {
    let id: String
    let heroineId: String
    let scenarioId: String         // the JSON file to load when this fires
    let chapter: Int               // display chapter number
    let priority: Int              // if multiple triggers are ready, higher fires first
    let conditions: [TriggerCondition]
    var hasFired: Bool = false
}

struct TriggerCondition: Codable {
    enum Kind: String, Codable {
        // Intra-heroine conditions
        case gaugeMin              // tokimekiGauge >= threshold
        case gaugeMax              // tokimekiGauge <= threshold  (some events need early timing)
        case shieldMax             // shieldIntegrity <= threshold (shield weakened enough)
        case trustMin              // trustLevel >= threshold
        case philosophyRespectMin  // philosophyRespect >= threshold
        case hogushiSuccessMin     // cumulative successful hogushis >= threshold
        case hogushiFailMin        // cumulative failures >= threshold (Sartre: respects struggle)
        // Player stat conditions
        case playerConceptMin      // player.conceptTranslation >= threshold
        case playerLogicMin        // player.logicConstruction >= threshold
        // Cross-heroine conditions
        case otherGaugeMin         // another heroine's gauge >= threshold
        case otherChapterCleared   // another heroine's chapter number cleared
    }

    let kind: Kind
    let threshold: Int
    let targetHeroineId: String?   // for cross-heroine kinds; nil for self-referencing
}

// MARK: - Chat Message

struct ChatMessage: Identifiable {
    enum Role { case heroine, player, narrator, system }
    let id: String
    let role: Role
    let text: String
    let speakerName: String?
    let bubbleColor: Color

    static func narrator(id: String, text: String) -> ChatMessage {
        ChatMessage(id: id, role: .narrator, text: text, speakerName: nil,
                    bubbleColor: TokimekiColors.heroineBubble)
    }
    static func system(id: String, text: String) -> ChatMessage {
        ChatMessage(id: id, role: .system, text: text, speakerName: nil,
                    bubbleColor: TokimekiColors.heroineBubble)
    }
}
