import Foundation
import SwiftUI

// MARK: - Design Tokens

enum TokimekiColors {
    static let background     = Color(red: 0.973, green: 0.957, blue: 0.937) // #F8F4EF warm off-white
    static let heroineBubble  = Color(red: 0.710, green: 0.918, blue: 0.843) // #B5EAD7 pastel mint
    static let playerBubble   = Color(red: 1.000, green: 0.718, blue: 0.773) // #FFB7C5 pastel pink
    static let hogushiFlash   = Color(red: 1.000, green: 0.839, blue: 0.910) // #FFD6E8 cherry-blossom
    static let accent         = Color(red: 0.976, green: 0.608, blue: 0.698) // #F99BB2 deeper pink
    static let textPrimary    = Color(red: 0.220, green: 0.200, blue: 0.220) // near-black
    static let textSecondary  = Color(red: 0.560, green: 0.540, blue: 0.560)
    static let cardBackground = Color.white.opacity(0.85)
}

// MARK: - Player Stats

struct PlayerStats: Codable {
    var logicConstruction: Int    // 論理構築力 — unlocks deeper argument branches
    var conceptTranslation: Int   // 概念翻訳力 — core hogushi success modifier
    var sophistryResistance: Int  // 詭弁耐性 — mental HP pool

    static let initial = PlayerStats(logicConstruction: 1, conceptTranslation: 1, sophistryResistance: 30)
    static let max = PlayerStats(logicConstruction: 10, conceptTranslation: 10, sophistryResistance: 100)
}

// MARK: - Heroine

struct Heroine: Identifiable, Codable {
    let id: String
    let name: String            // English/romaji
    let nameJP: String          // Japanese display name
    let archetype: String       // tsundere, cool, etc.
    let shieldConcept: String   // primary philosophy concept used as shield
    let shieldConceptJP: String
    var tokimekiGauge: Int      // 0–100
    let spriteAsset: String     // asset catalog key
    let bubbleColorHex: String  // per-heroine bubble tint variant
    let introLine: String       // First line of dialogue when tapped

    var tokimekiProgress: Double { Double(tokimekiGauge) / 100.0 }
}

// MARK: - Scenario Node

enum SpeakerRole: String, Codable {
    case heroine, player, narrator, system
}

enum NodeEffect: String, Codable {
    case none
    case hogushiAttempt   // triggers HogushiEngine evaluation
    case statGain         // adds to a player stat
    case gaugeRaise       // directly raises tokimekiGauge
    case sophAttack       // heroine attacks, drains sophistryResistance
    case sceneEnd
}

struct DialogueChoice: Identifiable, Codable {
    let id: String
    let text: String
    let effect: NodeEffect
    let translationPower: Int   // used by HogushiEngine; 0 = not a hogushi choice
    let nextNodeId: String
}

struct ScenarioNode: Identifiable, Codable {
    let id: String
    let speaker: SpeakerRole
    let text: String?
    let choices: [DialogueChoice]?
    let nextNodeId: String?     // nil = wait for choice or end
    let isHogushiNode: Bool     // whether this node can trigger the flash animation
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
    let message: String  // flavour text shown in the flash overlay
}
