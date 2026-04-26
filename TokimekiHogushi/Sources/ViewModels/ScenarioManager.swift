import Foundation
import Combine

// MARK: - ScenarioManager
//
// Single source of truth for scenario state.
// Owns the ScenarioLoader (JSON → Scenario) and HogushiEngine (math evaluation).
//
// Published properties drive the Chat UI:
//   displayedMessages → ChatMessageRow list
//   pendingChoices    → ChoiceCardView list
//   hogushiResult     → HogushiFlashView trigger

final class ScenarioManager: ObservableObject {

    // MARK: Published State

    @Published var currentHeroineId: String = ""
    @Published var currentScenario: Scenario?
    @Published var displayedMessages: [ChatMessage] = []
    @Published var pendingChoices: [DialogueChoice] = []
    @Published var hogushiResult: HogushiResult?
    @Published var isShowingHogushiFlash: Bool = false

    // MARK: Dependencies (injected via TokimekiHogushiView.onAppear)

    weak var playerStats: PlayerStatsManager?
    weak var heroineManager: HeroineManager?

    // MARK: Private

    private let loader = ScenarioLoader()
    private let engine = HogushiEngine()

    // MARK: - Load

    func loadScenario(heroineId: String) {
        guard let scenario = loader.load(scenarioId: "\(heroineId)_ch01") else { return }
        currentHeroineId  = heroineId
        currentScenario   = scenario
        displayedMessages = []
        pendingChoices    = []
        hogushiResult     = nil
        advanceTo(nodeId: scenario.nodes.first?.id ?? "")
    }

    // MARK: - Node Traversal

    func advanceTo(nodeId: String) {
        guard let scenario = currentScenario,
              let node = scenario.node(id: nodeId) else { return }

        switch node.speaker {

        case .heroine:
            appendHeroineMessage(nodeId: node.id, text: node.text)
            routeChoicesOrAdvance(node: node)

        case .narrator, .system:
            appendNarratorMessage(nodeId: node.id, role: node.speaker, text: node.text)
            routeChoicesOrAdvance(node: node)

        case .player:
            if let choices = node.choices, !choices.isEmpty {
                pendingChoices = choices
            }
        }
    }

    // MARK: - Choice Selection

    func selectChoice(_ choice: DialogueChoice) {
        pendingChoices = []
        appendPlayerMessage(choiceId: choice.id, text: choice.text)

        switch choice.effect {
        case .hogushiAttempt: evaluateHogushi(choice: choice)
        case .sophAttack:
            playerStats?.drain(sophistryDamage: 5)
            advanceTo(nodeId: choice.nextNodeId)
        case .statGain:
            playerStats?.gain(conceptTranslation: 1)
            advanceTo(nodeId: choice.nextNodeId)
        default:
            advanceTo(nodeId: choice.nextNodeId)
        }
    }

    func dismissHogushiFlash() {
        isShowingHogushiFlash = false
        hogushiResult         = nil
    }

    // MARK: - Hogushi Evaluation
    //
    // The core equation:
    //   score   = choice.translationPower + player.conceptTranslation
    //   success = score >= archetype.difficulty
    //   perfect = score >= archetype.difficulty * 2
    //
    // Example — Epicurus (difficulty 2), translationPower 10, playerStat 1:
    //   score = 11 ≥ 2*2 = 4  →  Perfect Hogushi (gaugeGain 25)
    //
    // Example — Wittgenstein (difficulty 8), translationPower 5, playerStat 1:
    //   score = 6 < 8  →  Failed attempt (HP drain)

    private func evaluateHogushi(choice: DialogueChoice) {
        guard let heroine = heroineManager?.heroine(id: currentHeroineId),
              let ct = playerStats?.stats.conceptTranslation else {
            advanceTo(nodeId: choice.nextNodeId)
            return
        }

        let result = engine.evaluate(translationPower: choice.translationPower,
                                     playerConceptTranslation: ct,
                                     heroine: heroine)
        hogushiResult = result

        if result.success {
            heroineManager?.raiseGauge(heroineId: currentHeroineId, by: result.gaugeGain)
            isShowingHogushiFlash = true
        } else {
            playerStats?.drain(sophistryDamage: 3)
        }

        advanceTo(nodeId: choice.nextNodeId)
    }

    // MARK: - Message Factories

    private func appendHeroineMessage(nodeId: String, text: String?) {
        guard let text else { return }
        let color = heroineManager?.heroine(id: currentHeroineId)?.bubbleColor
                    ?? TokimekiColors.heroineBubble
        let name  = heroineManager?.heroine(id: currentHeroineId)?.nameJP
        displayedMessages.append(
            ChatMessage(id: nodeId, role: .heroine, text: text, speakerName: name, bubbleColor: color)
        )
    }

    private func appendNarratorMessage(nodeId: String, role: SpeakerRole, text: String?) {
        guard let text else { return }
        let chatRole: ChatMessage.Role = role == .system ? .system : .narrator
        displayedMessages.append(
            ChatMessage(id: nodeId, role: chatRole, text: text, speakerName: nil,
                        bubbleColor: TokimekiColors.heroineBubble)
        )
    }

    private func appendPlayerMessage(choiceId: String, text: String) {
        displayedMessages.append(
            ChatMessage(id: choiceId, role: .player, text: text, speakerName: nil,
                        bubbleColor: TokimekiColors.playerBubble)
        )
    }

    // MARK: - Routing Helper

    private func routeChoicesOrAdvance(node: ScenarioNode) {
        if let choices = node.choices, !choices.isEmpty {
            pendingChoices = choices
        } else if let next = node.nextNodeId {
            advanceTo(nodeId: next)
        }
    }
}

// MARK: - Scenario Loader

final class ScenarioLoader {
    func load(scenarioId: String) -> Scenario? {
        guard let url  = Bundle.main.url(forResource: scenarioId, withExtension: "json",
                                         subdirectory: "Scenarios"),
              let data = try? Data(contentsOf: url),
              let obj  = try? JSONDecoder().decode(Scenario.self, from: data)
        else { return nil }
        return obj
    }
}
