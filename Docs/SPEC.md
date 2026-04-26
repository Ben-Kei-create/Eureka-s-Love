# 解きメキほぐし — Technical Specification

**Full Title:** 解きメキほぐし 〜哲学者のセーラー服と、日常の論理〜  
**Working English Title:** Tokimeki Hogushi: The Philosopher's Sailor Uniform and Everyday Logic  
**Platform:** iOS 17+ (SwiftUI, Portrait only)  
**Genre:** Visual Novel / Romance Simulation (Galge)  
**Engine:** Native SwiftUI — no third-party game engines  

---

## 1. Core Concept

The player is "A Perfectly Ordinary Student" enrolled in a high school where every classmate and teacher is the reincarnation of a famous historical philosopher. These figures appear as serious, realistic historical individuals—men or women—all wearing Japanese school uniforms (sailor fuku or blazers). The player's goal is to "melt" (解きほぐす, tokihogusu) the rigid philosophical armor each heroine/hero has built around themselves and find romance.

### The Central Loop

```
Heroine deploys Philosophy Shield (jargon-as-barrier)
  → Player uses 概念翻訳力 (Concept Translation Power)
      → Reinterpret the concept as an Absurdly Ordinary Example
          → Shield breaks → 【解きメキほぐし 完了】 flash
              → Padlock icon → Heart icon
                  → 解きメキ度 (Tokimeki Gauge) rises
```

---

## 2. UI Architecture

### Screen Split (Portrait)

| Zone | Height | Contents |
|------|--------|----------|
| Visual Novel Panel | 40% | Character sprite + school background + Art Nouveau star-chart motif overlay |
| Chat / Interaction Panel | 60% | Message-app-style dialogue bubbles + response option cards |

### Design System

| Property | Value |
|----------|-------|
| Background | `#F8F4EF` (warm off-white) |
| Heroine bubble | `#B5EAD7` pastel mint |
| Player bubble | `#FFB7C5` pastel pink |
| Accent / Hogushi flash | `#FFD6E8` cherry-blossom pink |
| Corner radius | `20` (bubbles), `16` (cards), `12` (panels) |
| Font | `.system(size:, design: .rounded)` |
| Shadows | `.shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)` |

---

## 3. Parameter System

### Player Philosophical Weapons

| Parameter (JP) | Parameter (EN) | Effect |
|----------------|----------------|--------|
| 論理構築力 | Logic Construction | Unlocks deeper counter-argument choices |
| 概念翻訳力 | Concept Translation | Core stat; determines "hogushi" success rate |
| 詭弁耐性 | Sophistry Resistance | Mental HP; absorbs heroine philosophical attacks |

Parameters are stored in `PlayerStats.json` and managed by `PlayerStatsManager`.

### Heroine Gauge

Each heroine has a `tokimekiGauge: Int` (0–100). Successful Hogushi events raise it by 10–25 points depending on difficulty.

---

## 4. Character Roster

### Heroines / Romantic Interests (Classmates)

| # | Historical Figure | Archetype | Philosophy Shield Concept |
|---|-------------------|-----------|--------------------------|
| 1 | Friedrich Nietzsche | Tsundere | Ressentiment / Übermensch |
| 2 | Plato | Cool / Aloof | The Theory of Forms / Ideal |
| 3 | Socrates | Socratic Questioner | Aporia / Elenchus |
| 4 | Immanuel Kant | Rules-Obsessed | Categorical Imperative |
| 5 | Simone de Beauvoir | Fierce Feminist | Existential Freedom / Otherness |
| 6 | Confucius (classmate ver.) | Tradition-strict | Ritual Propriety (Li) |
| 7 | Baruch Spinoza | Quiet Mathematician | Substance Monism / God=Nature |
| 8 | David Hume | Skeptic Pessimist | Causation Skepticism / Bundle Theory |
| 9 | Jean-Paul Sartre | Existential Angsty | Bad Faith / Existence before Essence |
| 10 | Hannah Arendt | Journalism-Club President | Banality of Evil / Public Space |
| 11 | Gottfried Leibniz | Optimist (forced) | Pre-established Harmony / Best World |
| 12 | René Descartes | Doubts Everything | Cogito / Methodical Doubt |
| 13 | John Stuart Mill | Student Council | Utilitarianism / Greatest Happiness |
| 14 | Arthur Schopenhauer | Extreme Pessimist | The Will / Suffering |
| 15 | Mary Wollstonecraft | Rights Activist | Vindication / Rational Education |
| 16 | Epicurus | Garden-Club | Ataraxia / Simple Pleasure |
| 17 | Blaise Pascal | Math Prodigy | The Wager / Human Frailty |
| 18 | Zhuangzi | Daydreamer | Relativism / Butterfly Dream |
| 19 | Hypatia | Math Tutor | Neoplatonism / Astronomical Truth |
| 20 | Ludwig Wittgenstein | Taciturn | Language Games / Limits of Language |

### Staff (Non-Romance NPCs)

| Role | Figure | Mechanic |
|------|--------|----------|
| Principal | Confucius (elder) | Governs school rules; unlocks story arcs |
| Science Teacher | Francis Bacon | Teaches the Inductive method; upgrades Logic Construction |
| Nurse | Sigmund Freud | Restores Sophistry Resistance HP |
| Save/Load Spirit | Laozi | Appears on Save screen: "返って来い" — "Let it be" |
| Transfer Guide | Ibn Battuta | Tutorial NPC for exploring new areas |

---

## 5. Dialogue & Scenario Format

Scenarios are stored as JSON arrays in `Resources/Scenarios/`. Each file corresponds to one heroine chapter.

```json
{
  "scenarioId": "nietzsche_ch01",
  "heroineId": "nietzsche",
  "chapter": 1,
  "title": "ルサンチマンは鎧じゃない",
  "nodes": [
    {
      "id": "n001",
      "speaker": "heroine",
      "text": "...",
      "bubbleStyle": "mint"
    },
    {
      "id": "n002",
      "speaker": "player",
      "choices": [
        { "id": "c1", "text": "...", "effect": "hogushi_attempt", "translationPower": 3 },
        { "id": "c2", "text": "...", "effect": "none" }
      ]
    }
  ]
}
```

---

## 6. Key SwiftUI Views

| View | Description |
|------|-------------|
| `TitleView` | Splash + logo with cherry blossom animation |
| `ClassroomView` | Grid of heroine portrait cards; tap to enter scenario |
| `TokimekiHogushiView` | Main gameplay screen (split panel) |
| `ChatBubbleView` | Individual message bubble (heroine / player) |
| `ChoiceCardView` | Tappable response option card |
| `HogushiFlashView` | Overlay animation: padlock → heart |
| `TokimekiGaugeView` | Animated gauge bar per heroine |
| `ParameterDashboardView` | Player's three weapon stats |
| `SaveLoadView` | Laozi-themed save/load screen |
| `NurseOfficeView` | Freud-themed HP restore mini-scene |

---

## 7. State Management

| Manager | Type | Responsibility |
|---------|------|----------------|
| `GameStateManager` | `ObservableObject` | Current chapter, scene node pointer |
| `PlayerStatsManager` | `ObservableObject` | 3 weapon parameters + persistence |
| `HeroineManager` | `ObservableObject` | Tokimeki gauge for all 20 heroines |
| `ScenarioLoader` | `class` | Loads + parses JSON scenario files |
| `HogushiEngine` | `class` | Evaluates hogushi attempt success |

---

## 8. Copyright & IP Notes

- All historical figures are in the public domain. New creative expressions (tsundere personalities, dialogue) are original works.
- Art style inspired by Art Nouveau / Mucha but rendered as original sprites — no direct reproduction.
- Title is an original portmanteau. Marketing materials must not use the trademarked string "Tokimeki Memorial."
- All philosophical concepts are sourced from primary texts (public domain translations pre-1928) or paraphrased originally.
