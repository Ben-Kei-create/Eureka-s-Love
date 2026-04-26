import Foundation
import Combine

// MARK: - ScenarioManager
//
// Drives the dialogue loop and coordinates with EventScheduler on chapter transitions.
//
// State mutation pipeline:
//   selectChoice()
//     ↓ applyEffect()           — update HeroineState via HeroineManager
//     ↓ evaluateHogushi()       — HogushiEngine math → HogushiResult
//     ↓ eventScheduler.evaluate() — check all trigger conditions
//     ↓ loadScenario() if trigger fired

final class ScenarioManager: ObservableObject {

    // MARK: Published State

    @Published var currentHeroineId: String = ""
    @Published var currentScenario: Scenario?
    @Published var displayedMessages: [ChatMessage] = []
    @Published var pendingChoices: [DialogueChoice] = []
    @Published var hogushiResult: HogushiResult?
    @Published var isShowingHogushiFlash: Bool = false
    @Published var newEventReady: EventTrigger?   // non-nil → UI shows "New event unlocked" banner

    // MARK: Dependencies

    weak var playerStats: PlayerStatsManager?
    weak var heroineManager: HeroineManager?
    var eventScheduler: EventScheduler?

    // MARK: Private

    private let loader = ScenarioLoader()
    private let engine = HogushiEngine()

    // MARK: - Load

    func loadScenario(heroineId: String) {
        let state   = heroineManager?.state(for: heroineId)
        let chapter = state?.currentChapter ?? 1
        let scenarioId = "\(heroineId)_ch0\(chapter)"
        loadScenario(id: scenarioId, heroineId: heroineId)
    }

    func loadScenario(id: String, heroineId: String) {
        guard let scenario = loader.load(scenarioId: id) else { return }
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
              let node     = scenario.node(id: nodeId) else { return }

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
        applyEffect(choice)
    }

    func dismissHogushiFlash() {
        isShowingHogushiFlash = false
        hogushiResult = nil
    }

    func dismissNewEventBanner() {
        newEventReady = nil
    }

    // MARK: - Effect Routing

    private func applyEffect(_ choice: DialogueChoice) {
        switch choice.effect {

        case .hogushiAttempt:
            evaluateHogushi(choice: choice)

        case .sophAttack:
            playerStats?.drain(sophistryDamage: 5)
            heroineManager?.recordHogushiFailure(for: currentHeroineId)
            advanceTo(nodeId: choice.nextNodeId)
            checkForNewEvents()

        case .statGain:
            playerStats?.gain(conceptTranslation: 1)
            advanceTo(nodeId: choice.nextNodeId)
            checkForNewEvents()

        case .gaugeRaise:
            heroineManager?.raiseGaugeDirect(for: currentHeroineId, by: 10)
            advanceTo(nodeId: choice.nextNodeId)
            checkForNewEvents()

        case .trustRaise:
            heroineManager?.raiseTrust(for: currentHeroineId)
            advanceTo(nodeId: choice.nextNodeId)
            checkForNewEvents()

        case .respectRaise:
            heroineManager?.raisePhilosophyRespect(for: currentHeroineId)
            advanceTo(nodeId: choice.nextNodeId)
            checkForNewEvents()

        case .sceneEnd:
            markChapterCleared()
            advanceTo(nodeId: choice.nextNodeId)

        case .none:
            advanceTo(nodeId: choice.nextNodeId)
        }
    }

    // MARK: - Hogushi Evaluation
    //
    // The core equation:
    //   score = translationPower + playerConceptTranslation
    //   score >= difficulty      → SUCCESS  (gauge up, shield drained)
    //   score >= difficulty × 2  → PERFECT  (larger gains)
    //   score <  difficulty      → FAILED   (HP drain, failCount++)

    private func evaluateHogushi(choice: DialogueChoice) {
        guard let heroine = heroineManager?.heroine(id: currentHeroineId),
              let state   = heroineManager?.state(for: currentHeroineId),
              let ct      = playerStats?.stats.conceptTranslation else {
            advanceTo(nodeId: choice.nextNodeId)
            return
        }

        let result = engine.evaluate(
            translationPower:         choice.translationPower,
            playerConceptTranslation: ct,
            heroine:                  heroine,
            currentShieldIntegrity:   state.shieldIntegrity
        )

        hogushiResult = result

        if result.success {
            heroineManager?.applyHogushiResult(result, to: currentHeroineId)
            isShowingHogushiFlash = true
        } else {
            playerStats?.drain(sophistryDamage: 3)
            heroineManager?.recordHogushiFailure(for: currentHeroineId)
        }

        advanceTo(nodeId: choice.nextNodeId)
        checkForNewEvents()
    }

    // MARK: - Chapter Cleared

    private func markChapterCleared() {
        guard let scenario = currentScenario else { return }
        heroineManager?.markChapterCleared(scenario.chapter, for: currentHeroineId)
        checkForNewEvents()
    }

    // MARK: - Event Check
    //
    // Called after every state mutation.
    // If EventScheduler finds a ready trigger, surface it as newEventReady.

    private func checkForNewEvents() {
        guard let scheduler = eventScheduler,
              let trigger   = scheduler.evaluate(heroineId: currentHeroineId) else { return }
        scheduler.markFired(triggerId: trigger.id)
        newEventReady = trigger
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
