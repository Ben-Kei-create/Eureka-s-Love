import Foundation
import Combine

final class HeroineManager: ObservableObject {
    @Published private(set) var heroines: [Heroine]

    private let saveKey = "heroineGauges"

    init() {
        heroines = Self.defaultRoster()
        loadPersistedGauges()
    }

    func raiseGauge(heroineId: String, by amount: Int) {
        guard let idx = heroines.firstIndex(where: { $0.id == heroineId }) else { return }
        heroines[idx].tokimekiGauge = min(100, heroines[idx].tokimekiGauge + amount)
        persistGauges()
    }

    func heroine(id: String) -> Heroine? {
        heroines.first { $0.id == id }
    }

    // MARK: - Persistence

    private func persistGauges() {
        let dict = Dictionary(uniqueKeysWithValues: heroines.map { ($0.id, $0.tokimekiGauge) })
        UserDefaults.standard.set(dict, forKey: saveKey)
    }

    private func loadPersistedGauges() {
        guard let dict = UserDefaults.standard.dictionary(forKey: saveKey) as? [String: Int] else { return }
        for idx in heroines.indices {
            if let saved = dict[heroines[idx].id] {
                heroines[idx].tokimekiGauge = saved
            }
        }
    }

    // MARK: - Default Roster (20 philosophers)

    static func defaultRoster() -> [Heroine] {
        [
            Heroine(id: "nietzsche",      name: "Friedrich Nietzsche",    nameJP: "ニーチェ",
                    archetype: "tsundere",          shieldConcept: "Ressentiment",
                    shieldConceptJP: "ルサンチマン",
                    tokimekiGauge: 0, spriteAsset: "sprite_nietzsche",    bubbleColorHex: "#B5EAD7",
                    introLine: "…別に、あなたに何かを期待しているわけじゃない。"),
            Heroine(id: "plato",          name: "Plato",                  nameJP: "プラトン",
                    archetype: "cool_aloof",        shieldConcept: "Theory of Forms",
                    shieldConceptJP: "イデア論",
                    tokimekiGauge: 0, spriteAsset: "sprite_plato",        bubbleColorHex: "#C7CEEA",
                    introLine: "現実は影に過ぎない。あなたはまだイデアを見たことがないでしょう。"),
            Heroine(id: "socrates",       name: "Socrates",               nameJP: "ソクラテス",
                    archetype: "questioner",        shieldConcept: "Aporia",
                    shieldConceptJP: "アポリア",
                    tokimekiGauge: 0, spriteAsset: "sprite_socrates",     bubbleColorHex: "#FFDAC1",
                    introLine: "あなたは『幸福』とは何か、本当に知っているのですか?"),
            Heroine(id: "kant",           name: "Immanuel Kant",          nameJP: "カント",
                    archetype: "rules_obsessed",    shieldConcept: "Categorical Imperative",
                    shieldConceptJP: "定言命法",
                    tokimekiGauge: 0, spriteAsset: "sprite_kant",         bubbleColorHex: "#E2F0CB",
                    introLine: "規則に従うことが義務です。例外を求めるなら、それは義務ではない。"),
            Heroine(id: "beauvoir",       name: "Simone de Beauvoir",     nameJP: "ボーヴォワール",
                    archetype: "fierce_feminist",   shieldConcept: "Radical Freedom",
                    shieldConceptJP: "根源的自由",
                    tokimekiGauge: 0, spriteAsset: "sprite_beauvoir",     bubbleColorHex: "#FFB7C5",
                    introLine: "私は自分で選ぶ。あなたの定義に収まるつもりはない。"),
            Heroine(id: "confucius_c",    name: "Confucius",              nameJP: "孔子（同級生）",
                    archetype: "tradition_strict",  shieldConcept: "Ritual Propriety",
                    shieldConceptJP: "礼",
                    tokimekiGauge: 0, spriteAsset: "sprite_confucius_c",  bubbleColorHex: "#F9E4B7",
                    introLine: "礼なき行いは、学びとは呼べません。"),
            Heroine(id: "spinoza",        name: "Baruch Spinoza",         nameJP: "スピノザ",
                    archetype: "quiet_mathematician", shieldConcept: "Substance Monism",
                    shieldConceptJP: "実体一元論",
                    tokimekiGauge: 0, spriteAsset: "sprite_spinoza",      bubbleColorHex: "#DCD3FF",
                    introLine: "神即ち自然。この教室も、あなたも、みな一つの実体の様態に過ぎない。"),
            Heroine(id: "hume",           name: "David Hume",             nameJP: "ヒューム",
                    archetype: "skeptic_pessimist", shieldConcept: "Causation Skepticism",
                    shieldConceptJP: "因果懐疑論",
                    tokimekiGauge: 0, spriteAsset: "sprite_hume",         bubbleColorHex: "#B5D5EA",
                    introLine: "原因があるから結果がある、なんて誰が証明したの。"),
            Heroine(id: "sartre",         name: "Jean-Paul Sartre",       nameJP: "サルトル",
                    archetype: "existential_angsty", shieldConcept: "Bad Faith",
                    shieldConceptJP: "自欺",
                    tokimekiGauge: 0, spriteAsset: "sprite_sartre",       bubbleColorHex: "#D4A5A5",
                    introLine: "実存は本質に先立つ。だから今日も、何者にもなれていない自分が苦しい。"),
            Heroine(id: "arendt",         name: "Hannah Arendt",          nameJP: "アーレント",
                    archetype: "journalism_president", shieldConcept: "Banality of Evil",
                    shieldConceptJP: "悪の凡庸さ",
                    tokimekiGauge: 0, spriteAsset: "sprite_arendt",       bubbleColorHex: "#A8D8EA",
                    introLine: "思考を停止した人間ほど、危険なものはない。"),
            Heroine(id: "leibniz",        name: "Gottfried Leibniz",      nameJP: "ライプニッツ",
                    archetype: "forced_optimist",   shieldConcept: "Pre-established Harmony",
                    shieldConceptJP: "予定調和",
                    tokimekiGauge: 0, spriteAsset: "sprite_leibniz",      bubbleColorHex: "#FFE5B4",
                    introLine: "これが可能な世界の中で最善の世界…そう、信じなければ。"),
            Heroine(id: "descartes",      name: "René Descartes",         nameJP: "デカルト",
                    archetype: "doubts_everything", shieldConcept: "Methodical Doubt",
                    shieldConceptJP: "方法的懐疑",
                    tokimekiGauge: 0, spriteAsset: "sprite_descartes",    bubbleColorHex: "#E8E8E8",
                    introLine: "あなたが今ここにいると、どうして確かめられますか。私は疑います。"),
            Heroine(id: "mill",           name: "John Stuart Mill",       nameJP: "ミル",
                    archetype: "student_council",   shieldConcept: "Utilitarianism",
                    shieldConceptJP: "功利主義",
                    tokimekiGauge: 0, spriteAsset: "sprite_mill",         bubbleColorHex: "#C8E6C9",
                    introLine: "最大多数の最大幸福。感情論で決定を歪めないでください。"),
            Heroine(id: "schopenhauer",   name: "Arthur Schopenhauer",    nameJP: "ショーペンハウアー",
                    archetype: "extreme_pessimist", shieldConcept: "The Will",
                    shieldConceptJP: "盲目の意志",
                    tokimekiGauge: 0, spriteAsset: "sprite_schopenhauer", bubbleColorHex: "#9E9E9E",
                    introLine: "生きることは苦しむこと。意志が私たちを操り、満足は幻だ。"),
            Heroine(id: "wollstonecraft", name: "Mary Wollstonecraft",    nameJP: "ウルストンクラフト",
                    archetype: "rights_activist",   shieldConcept: "Rational Education",
                    shieldConceptJP: "理性的教育",
                    tokimekiGauge: 0, spriteAsset: "sprite_wollstonecraft", bubbleColorHex: "#F8BBD0",
                    introLine: "感情に流されるな。理性こそが真の平等への道です。"),
            Heroine(id: "epicurus",       name: "Epicurus",               nameJP: "エピクロス",
                    archetype: "garden_club",       shieldConcept: "Ataraxia",
                    shieldConceptJP: "アタラクシア",
                    tokimekiGauge: 0, spriteAsset: "sprite_epicurus",     bubbleColorHex: "#DCEDC8",
                    introLine: "庭で育てたバジルを見てください。これが真の平穏です。"),
            Heroine(id: "pascal",         name: "Blaise Pascal",          nameJP: "パスカル",
                    archetype: "math_prodigy",      shieldConcept: "Pascal's Wager",
                    shieldConceptJP: "賭け",
                    tokimekiGauge: 0, spriteAsset: "sprite_pascal",       bubbleColorHex: "#CFD8DC",
                    introLine: "人間は考える葦。でも、私の計算は常に正しい。"),
            Heroine(id: "zhuangzi",       name: "Zhuangzi",               nameJP: "荘子",
                    archetype: "daydreamer",        shieldConcept: "Butterfly Dream",
                    shieldConceptJP: "胡蝶の夢",
                    tokimekiGauge: 0, spriteAsset: "sprite_zhuangzi",     bubbleColorHex: "#FFF9C4",
                    introLine: "今あなたと話しているこの私は、夢の中の蝶かもしれない。"),
            Heroine(id: "hypatia",        name: "Hypatia",                nameJP: "ヒュパティア",
                    archetype: "math_tutor",        shieldConcept: "Neoplatonism",
                    shieldConceptJP: "新プラトン主義",
                    tokimekiGauge: 0, spriteAsset: "sprite_hypatia",      bubbleColorHex: "#E1BEE7",
                    introLine: "真理は数の中にある。感情的な議論は時間の無駄です。"),
            Heroine(id: "wittgenstein",   name: "Ludwig Wittgenstein",    nameJP: "ウィトゲンシュタイン",
                    archetype: "taciturn",          shieldConcept: "Limits of Language",
                    shieldConceptJP: "言語の限界",
                    tokimekiGauge: 0, spriteAsset: "sprite_wittgenstein", bubbleColorHex: "#B0BEC5",
                    introLine: "語り得ぬことについては、沈黙しなければならない。"),
        ]
    }
}
