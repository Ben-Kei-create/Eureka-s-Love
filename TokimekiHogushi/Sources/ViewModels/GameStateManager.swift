import Foundation
import Combine

final class GameStateManager: ObservableObject {
    @Published var currentHeroineId: String = "nietzsche"
    @Published var currentScenario: Scenario?
    @Published var currentNodeId: String = ""
    @Published var displayedMessages: [ChatMessage] = []
    @Published var pendingChoices: [DialogueChoice] = []
    @Published var hogushiResult: HogushiResult?
    @Published var isShowingHogushiFlash: Bool = false

    private let scenarioLoader = ScenarioLoader()
    private let hogushiEngine  = HogushiEngine()

    // Injected managers
    var playerStats: PlayerStatsManager?
    var heroineManager: HeroineManager?

    // MARK: - Load Scenario

    func loadScenario(id: String) {
        guard let scenario = scenarioLoader.load(scenarioId: id) else { return }
        currentScenario = scenario
        displayedMessages = []
        pendingChoices = []
        hogushiResult = nil
        advance(to: scenario.nodes.first?.id ?? "")
    }

    // MARK: - Node Advance

    func advance(to nodeId: String) {
        guard let scenario = currentScenario,
              let node = scenario.node(id: nodeId) else { return }
        currentNodeId = nodeId

        switch node.speaker {
        case .heroine, .narrator, .system:
            if let text = node.text {
                let chatRole: ChatMessage.Role = node.speaker == .heroine ? .heroine
                                              : node.speaker == .system   ? .system
                                              : .narrator
                let msg = ChatMessage(id: node.id, role: chatRole, text: text)
                displayedMessages.append(msg)
            }
            if let choices = node.choices, !choices.isEmpty {
                pendingChoices = choices
            } else if let next = node.nextNodeId {
                advance(to: next)
            }

        case .player:
            if let choices = node.choices, !choices.isEmpty {
                pendingChoices = choices
            }
        }
    }

    // MARK: - Choice Selection

    func selectChoice(_ choice: DialogueChoice) {
        pendingChoices = []

        let playerMsg = ChatMessage(id: choice.id, role: .player, text: choice.text)
        displayedMessages.append(playerMsg)

        switch choice.effect {
        case .hogushiAttempt:
            evaluateHogushi(choice: choice)
        case .sophAttack:
            playerStats?.drain(sophistryDamage: 5)
            advance(to: choice.nextNodeId)
        case .statGain:
            playerStats?.gain(conceptTranslation: 1)
            advance(to: choice.nextNodeId)
        default:
            advance(to: choice.nextNodeId)
        }
    }

    // MARK: - Hogushi Evaluation

    private func evaluateHogushi(choice: DialogueChoice) {
        guard let heroine = heroineManager?.heroine(id: currentHeroineId),
              let ct = playerStats?.stats.conceptTranslation else {
            advance(to: choice.nextNodeId)
            return
        }

        let result = hogushiEngine.evaluate(translationPower: choice.translationPower,
                                            playerConceptTranslation: ct,
                                            heroine: heroine)
        hogushiResult = result

        if result.success {
            heroineManager?.raiseGauge(heroineId: currentHeroineId, by: result.gaugeGain)
            isShowingHogushiFlash = true
        }

        advance(to: choice.nextNodeId)
    }

    func dismissHogushiFlash() {
        isShowingHogushiFlash = false
        hogushiResult = nil
    }
}

// MARK: - Chat Message

struct ChatMessage: Identifiable {
    enum Role { case heroine, player, narrator, system }
    let id: String
    let role: Role
    let text: String
}

// MARK: - Scenario Loader

final class ScenarioLoader {
    func load(scenarioId: String) -> Scenario? {
        guard let url = Bundle.main.url(forResource: scenarioId, withExtension: "json",
                                        subdirectory: "Scenarios"),
              let data = try? Data(contentsOf: url),
              let scenario = try? JSONDecoder().decode(Scenario.self, from: data)
        else { return nil }
        return scenario
    }
}

