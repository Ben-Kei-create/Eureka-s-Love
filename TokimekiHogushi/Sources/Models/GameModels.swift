import Foundation
import SwiftUI

// MARK: - Design Tokens

enum TokimekiColors {
    static let background     = Color(red: 0.973, green: 0.957, blue: 0.937) // #F8F4EF warm off-white
    static let heroineBubble  = Color(red: 0.710, green: 0.918, blue: 0.843) // #B5EAD7 pastel mint
    static let playerBubble   = Color(red: 1.000, green: 0.718, blue: 0.773) // #FFB7C5 pastel pink
    static let hogushiFlash   = Color(red: 1.000, green: 0.839, blue: 0.910) // #FFD6E8 cherry-blossom
    static let accent         = Color(red: 0.976, green: 0.608, blue: 0.698) // #F99BB2 deeper pink
    static let textPrimary    = Color(red: 0.220, green: 0.200, blue: 0.220)
    static let textSecondary  = Color(red: 0.560, green: 0.540, blue: 0.560)
    static let cardBackground = Color.white.opacity(0.85)
}

// MARK: - Color Hex Extension

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
    var logicConstruction: Int    // 論理構築力 — unlocks deeper argument branches
    var conceptTranslation: Int   // 概念翻訳力 — core hogushi success modifier
    var sophistryResistance: Int  // 詭弁耐性 — mental HP pool

    static let initial = PlayerStats(logicConstruction: 1, conceptTranslation: 1, sophistryResistance: 30)
    static let max     = PlayerStats(logicConstruction: 10, conceptTranslation: 10, sophistryResistance: 100)
}

// MARK: - Heroine

struct Heroine: Identifiable, Codable {
    let id: String
    let name: String
    let nameJP: String
    let archetype: String
    let shieldConcept: String
    let shieldConceptJP: String
    var tokimekiGauge: Int         // 0–100
    let spriteAsset: String
    let bubbleColorHex: String     // e.g. "#B5EAD7"
    let introLine: String

    var tokimekiProgress: Double { Double(tokimekiGauge) / 100.0 }

    // Converts the stored hex string to a SwiftUI Color for use in ChatMessageRow
    var bubbleColor: Color { Color(hex: bubbleColorHex) }
}

// MARK: - Scenario Node

enum SpeakerRole: String, Codable {
    case heroine, player, narrator, system
}

enum NodeEffect: String, Codable {
    case none
    case hogushiAttempt   // triggers ScenarioManager.evaluateHogushi()
    case statGain         // increases a player stat
    case gaugeRaise       // directly raises tokimekiGauge (no engine evaluation)
    case sophAttack       // heroine attacks: drains sophistryResistance
    case sceneEnd
}

struct DialogueChoice: Identifiable, Codable {
    let id: String
    let text: String
    let effect: NodeEffect
    // The player's translation strength for this choice.
    // Engine equation: score = translationPower + Player.conceptTranslation
    //   success if score >= archetype.difficulty
    //   perfect if score >= archetype.difficulty * 2
    let translationPower: Int
    let nextNodeId: String
}

struct ScenarioNode: Identifiable, Codable {
    let id: String
    let speaker: SpeakerRole
    let text: String?
    let choices: [DialogueChoice]?
    let nextNodeId: String?        // nil = wait for choice or chapter end
    let isHogushiNode: Bool        // hint: is this a potential hogushi moment?
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
    let message: String
}

// MARK: - Chat Message
//
// A UI-layer struct (not persisted). Carries the bubble color so ChatMessageRow
// does not need to look up the Heroine separately.

struct ChatMessage: Identifiable {
    enum Role { case heroine, player, narrator, system }
    let id: String
    let role: Role
    let text: String
    let speakerName: String?   // displayed above the bubble for heroine messages
    let bubbleColor: Color     // per-heroine tint; player messages use TokimekiColors.playerBubble

    // Convenience constructors
    static func narrator(id: String, text: String) -> ChatMessage {
        ChatMessage(id: id, role: .narrator, text: text,
                    speakerName: nil, bubbleColor: TokimekiColors.heroineBubble)
    }

    static func system(id: String, text: String) -> ChatMessage {
        ChatMessage(id: id, role: .system, text: text,
                    speakerName: nil, bubbleColor: TokimekiColors.heroineBubble)
    }
}
