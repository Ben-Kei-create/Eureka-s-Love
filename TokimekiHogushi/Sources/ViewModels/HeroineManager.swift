import Foundation
import Combine

// MARK: - HeroineManager
//
// Owns two separate collections:
//   heroines      — static identity data (name, archetype, sprite, etc.)
//   heroineStates — mutable runtime state (gauges, trust, shield, chapter)
//
// The split allows the static roster to be compiled in without UserDefaults,
// while only HeroineState is persisted per save slot.

final class HeroineManager: ObservableObject {
    @Published private(set) var heroines: [Heroine]
    @Published private(set) var states: [String: HeroineState]   // keyed by heroine.id

    private let saveKey = "heroineStates_v2"

    init() {
        heroines = Self.defaultRoster()
        states   = Dictionary(uniqueKeysWithValues: heroines.map { ($0.id, HeroineState()) })
        loadPersistedStates()
    }

    // MARK: - Accessors

    func heroine(id: String) -> Heroine? {
        heroines.first { $0.id == id }
    }

    func state(for id: String) -> HeroineState {
        states[id] ?? HeroineState()
    }

    // MARK: - Mutators
    // All mutations go through here so @Published fires and EventScheduler can observe.

    func applyHogushiResult(_ result: HogushiResult, to id: String) {
        guard result.success else { return }
        mutate(id: id) { s in
            s.tokimekiGauge      = min(100, s.tokimekiGauge + result.gaugeGain)
            s.shieldIntegrity    = max(0,   s.shieldIntegrity - result.shieldDrain)
            s.hogushiSuccessCount += 1
        }
    }

    func recordHogushiFailure(for id: String) {
        mutate(id: id) { $0.hogushiFailCount += 1 }
    }

    func raiseTrust(for id: String, by amount: Int = 1) {
        mutate(id: id) { s in s.trustLevel = min(5, s.trustLevel + amount) }
    }

    func raisePhilosophyRespect(for id: String, by amount: Int = 1) {
        mutate(id: id) { s in s.philosophyRespect = min(10, s.philosophyRespect + amount) }
    }

    func raiseGaugeDirect(for id: String, by amount: Int) {
        mutate(id: id) { s in s.tokimekiGauge = min(100, s.tokimekiGauge + amount) }
    }

    func markChapterCleared(_ chapter: Int, for id: String) {
        mutate(id: id) { s in
            s.currentChapter       = chapter + 1
            s.hogushiSuccessCount += 0  // no change, just advance
        }
    }

    // MARK: - Persistence

    func persist() {
        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func loadPersistedStates() {
        guard let data   = UserDefaults.standard.data(forKey: saveKey),
              let loaded = try? JSONDecoder().decode([String: HeroineState].self, from: data)
        else { return }
        for (id, s) in loaded where states[id] != nil {
            states[id] = s
        }
    }

    private func mutate(id: String, _ transform: (inout HeroineState) -> Void) {
        guard var s = states[id] else { return }
        transform(&s)
        states[id] = s
        persist()
    }

    // MARK: - Default Roster

    static func defaultRoster() -> [Heroine] {
        [
            Heroine(id: "nietzsche",
                    name: "Friedrich Nietzsche", nameJP: "ニーチェ",
                    archetype: "tsundere",
                    shieldConcept: "Ressentiment", shieldConceptJP: "ルサンチマン",
                    spriteAsset: "sprite_nietzsche", bubbleColorHex: "#B5EAD7",
                    introLine: "…別に、あなたに何かを期待しているわけじゃない。"),
            Heroine(id: "plato",
                    name: "Plato", nameJP: "プラトン",
                    archetype: "cool_aloof",
                    shieldConcept: "Theory of Forms", shieldConceptJP: "イデア論",
                    spriteAsset: "sprite_plato", bubbleColorHex: "#C7CEEA",
                    introLine: "現実は影に過ぎない。あなたはまだイデアを見たことがないでしょう。"),
            Heroine(id: "socrates",
                    name: "Socrates", nameJP: "ソクラテス",
                    archetype: "questioner",
                    shieldConcept: "Aporia", shieldConceptJP: "アポリア",
                    spriteAsset: "sprite_socrates", bubbleColorHex: "#FFDAC1",
                    introLine: "あなたは『幸福』とは何か、本当に知っているのですか?"),
            Heroine(id: "kant",
                    name: "Immanuel Kant", nameJP: "カント",
                    archetype: "rules_obsessed",
                    shieldConcept: "Categorical Imperative", shieldConceptJP: "定言命法",
                    spriteAsset: "sprite_kant", bubbleColorHex: "#E2F0CB",
                    introLine: "規則に従うことが義務です。例外を求めるなら、それは義務ではない。"),
            Heroine(id: "beauvoir",
                    name: "Simone de Beauvoir", nameJP: "ボーヴォワール",
                    archetype: "fierce_feminist",
                    shieldConcept: "Radical Freedom", shieldConceptJP: "根源的自由",
                    spriteAsset: "sprite_beauvoir", bubbleColorHex: "#FFB7C5",
                    introLine: "私は自分で選ぶ。あなたの定義に収まるつもりはない。"),
            Heroine(id: "confucius_c",
                    name: "Confucius", nameJP: "孔子（同級生）",
                    archetype: "tradition_strict",
                    shieldConcept: "Ritual Propriety", shieldConceptJP: "礼",
                    spriteAsset: "sprite_confucius_c", bubbleColorHex: "#F9E4B7",
                    introLine: "礼なき行いは、学びとは呼べません。"),
            Heroine(id: "spinoza",
                    name: "Baruch Spinoza", nameJP: "スピノザ",
                    archetype: "quiet_mathematician",
                    shieldConcept: "Substance Monism", shieldConceptJP: "実体一元論",
                    spriteAsset: "sprite_spinoza", bubbleColorHex: "#DCD3FF",
                    introLine: "神即ち自然。この教室も、あなたも、みな一つの実体の様態に過ぎない。"),
            Heroine(id: "hume",
                    name: "David Hume", nameJP: "ヒューム",
                    archetype: "skeptic_pessimist",
                    shieldConcept: "Causation Skepticism", shieldConceptJP: "因果懐疑論",
                    spriteAsset: "sprite_hume", bubbleColorHex: "#B5D5EA",
                    introLine: "原因があるから結果がある、なんて誰が証明したの。"),
            Heroine(id: "sartre",
                    name: "Jean-Paul Sartre", nameJP: "サルトル",
                    archetype: "existential_angsty",
                    shieldConcept: "Bad Faith", shieldConceptJP: "自欺",
                    spriteAsset: "sprite_sartre", bubbleColorHex: "#D4A5A5",
                    introLine: "実存は本質に先立つ。だから今日も、何者にもなれていない自分が苦しい。"),
            Heroine(id: "arendt",
                    name: "Hannah Arendt", nameJP: "アーレント",
                    archetype: "journalism_president",
                    shieldConcept: "Banality of Evil", shieldConceptJP: "悪の凡庸さ",
                    spriteAsset: "sprite_arendt", bubbleColorHex: "#A8D8EA",
                    introLine: "思考を停止した人間ほど、危険なものはない。"),
            Heroine(id: "leibniz",
                    name: "Gottfried Leibniz", nameJP: "ライプニッツ",
                    archetype: "forced_optimist",
                    shieldConcept: "Pre-established Harmony", shieldConceptJP: "予定調和",
                    spriteAsset: "sprite_leibniz", bubbleColorHex: "#FFE5B4",
                    introLine: "これが可能な世界の中で最善の世界…そう、信じなければ。"),
            Heroine(id: "descartes",
                    name: "René Descartes", nameJP: "デカルト",
                    archetype: "doubts_everything",
                    shieldConcept: "Methodical Doubt", shieldConceptJP: "方法的懐疑",
                    spriteAsset: "sprite_descartes", bubbleColorHex: "#E8E8E8",
                    introLine: "あなたが今ここにいると、どうして確かめられますか。私は疑います。"),
            Heroine(id: "mill",
                    name: "John Stuart Mill", nameJP: "ミル",
                    archetype: "student_council",
                    shieldConcept: "Utilitarianism", shieldConceptJP: "功利主義",
                    spriteAsset: "sprite_mill", bubbleColorHex: "#C8E6C9",
                    introLine: "最大多数の最大幸福。感情論で決定を歪めないでください。"),
            Heroine(id: "schopenhauer",
                    name: "Arthur Schopenhauer", nameJP: "ショーペンハウアー",
                    archetype: "extreme_pessimist",
                    shieldConcept: "The Will", shieldConceptJP: "盲目の意志",
                    spriteAsset: "sprite_schopenhauer", bubbleColorHex: "#9E9E9E",
                    introLine: "生きることは苦しむこと。意志が私たちを操り、満足は幻だ。"),
            Heroine(id: "wollstonecraft",
                    name: "Mary Wollstonecraft", nameJP: "ウルストンクラフト",
                    archetype: "rights_activist",
                    shieldConcept: "Rational Education", shieldConceptJP: "理性的教育",
                    spriteAsset: "sprite_wollstonecraft", bubbleColorHex: "#F8BBD0",
                    introLine: "感情に流されるな。理性こそが真の平等への道です。"),
            Heroine(id: "epicurus",
                    name: "Epicurus", nameJP: "エピクロス",
                    archetype: "garden_club",
                    shieldConcept: "Ataraxia", shieldConceptJP: "アタラクシア",
                    spriteAsset: "sprite_epicurus", bubbleColorHex: "#DCEDC8",
                    introLine: "庭で育てたバジルを見てください。これが真の平穏です。"),
            Heroine(id: "pascal",
                    name: "Blaise Pascal", nameJP: "パスカル",
                    archetype: "math_prodigy",
                    shieldConcept: "Pascal's Wager", shieldConceptJP: "賭け",
                    spriteAsset: "sprite_pascal", bubbleColorHex: "#CFD8DC",
                    introLine: "人間は考える葦。でも、私の計算は常に正しい。"),
            Heroine(id: "zhuangzi",
                    name: "Zhuangzi", nameJP: "荘子",
                    archetype: "daydreamer",
                    shieldConcept: "Butterfly Dream", shieldConceptJP: "胡蝶の夢",
                    spriteAsset: "sprite_zhuangzi", bubbleColorHex: "#FFF9C4",
                    introLine: "今あなたと話しているこの私は、夢の中の蝶かもしれない。"),
            Heroine(id: "hypatia",
                    name: "Hypatia", nameJP: "ヒュパティア",
                    archetype: "math_tutor",
                    shieldConcept: "Neoplatonism", shieldConceptJP: "新プラトン主義",
                    spriteAsset: "sprite_hypatia", bubbleColorHex: "#E1BEE7",
                    introLine: "真理は数の中にある。感情的な議論は時間の無駄です。"),
            Heroine(id: "wittgenstein",
                    name: "Ludwig Wittgenstein", nameJP: "ウィトゲンシュタイン",
                    archetype: "taciturn",
                    shieldConcept: "Limits of Language", shieldConceptJP: "言語の限界",
                    spriteAsset: "sprite_wittgenstein", bubbleColorHex: "#B0BEC5",
                    introLine: "語り得ぬことについては、沈黙しなければならない。"),
        ]
    }
}
