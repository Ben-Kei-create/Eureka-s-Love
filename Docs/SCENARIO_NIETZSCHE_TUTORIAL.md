# Scenario Script: Nietzsche Tsundere Tutorial
## Chapter 1 — "ルサンチマンは鎧じゃない" (Ressentiment Isn't Armor)

This is the annotated walkthrough of `nietzsche_ch01.json` for writers and designers.  
Chat UI: heroine bubbles = LEFT (mint), player choices = RIGHT (pink).

---

```
[SCENE: 放課後の教室 / After-school classroom]
[CHARACTER SPRITE: Nietzsche — sailor uniform, arms crossed, leaning on window frame]
[BG: Late-afternoon classroom, orange light]
```

---

### ACT 1 — The Shield Appears

**NARRATOR (gray system text)**
> 放課後、哲学科の教室。夕陽が窓から差し込む中、ニーチェが一人で窓枠に寄りかかっている。

**NIETZSCHE** *(mint bubble, left)*
> …なに、また来たの。あなたみたいな平凡な存在に、私の独りの時間を邪魔される筋合いはない。

**[PLAYER CHOICE — BRANCH A]** *(pink card, right)*
> "ごめん、邪魔するつもりはなかったんだ。"
→ leads to Nietzsche accusing the player of Ressentiment-via-apology

**[PLAYER CHOICE — BRANCH B]** *(pink card, right)*  *(Recommended / Tutorial path)*
> "独りがいいなら、なんで窓の外じゃなくて教室の扉の方向を向いてたの？"
→ Nietzsche is briefly rattled

**NIETZSCHE** *(mint bubble)*
> …っ！　そ、そんなことは関係ない。私はただ、光の方角を観察していただけ。

**NIETZSCHE** *(second bubble, same turn)*
> そもそも、あなたには理解できないでしょう。私が感じているこの感情——これは『**ルサンチマン**』。
> 弱者が強者への怨恨と嫉妬を力に変える、高尚な哲学的機制よ。
> 私の孤独は、**超人への道程**なの。

---

### 🔒 PHILOSOPHY SHIELD DEPLOYED

```
┌─────────────────────────────────────────────────┐
│  【哲学の鎧】 SHIELD ACTIVE                       │
│  ニーチェ: "ルサンチマン + 超人"                    │
│  難易度: ★★★☆☆ (Archetype: tsundere, diff=3)    │
│  → Direct debate will fail. Use 概念翻訳力!       │
└─────────────────────────────────────────────────┘
```

**NARRATOR (system hint)**
> ここで正面からぶつかっても無駄だ。このジャーゴンを日常の言葉に"翻訳"する方法を考えよう。

---

### ACT 2 — Hogushi Attempt

Three choices appear as tappable cards:

| Card | Text | Effect | 翻訳Power | Notes |
|------|------|--------|-----------|-------|
| ✨ A | 「ルサンチマン」って、つまり……昼ごはんの時間に**焼きそばパンが売り切れ**てて、「どうせあんなパンは体に悪い」って自分に言い聞かせる感じのこと？ | hogushiAttempt | 5 | ✅ Best path — yakisoba pan |
| B | ルサンチマンは哲学的に重要な概念だね。ニーチェの批判はキリスト教道徳に向けられていて…… | sophAttack | 0 | ❌ Wrong — debating → HP drain |
| ✨ C | 孤独が超人への道なら、友達がいなくて寂しいのを「これは修行だ」って思ってるってこと？ | hogushiAttempt | 3 | ⚡ Partial success |

---

### 🎉 HOGUSHI FLASH — Path A (Perfect)

```
╔═══════════════════════════════════════╗
║   🔒 → 💕   解きメキほぐし 完了       ║
║                                       ║
║  "ニーチェの論理の鎧が、溶けていく…" ║
║                                       ║
║         解きメキ度 +25                ║
║        [  続ける  ]                   ║
╚═══════════════════════════════════════╝
```

**Animation sequence:**
1. Dark scrim fades in (0.3s)
2. Lock icon on VN panel starts trembling
3. 0.5s → Lock clicks open → morphs to Heart (spring animation)
4. Cherry-blossom pink glow radiates from heart
5. Text and gauge-gain badge fade in (0.8s)
6. Tap "続ける" to dismiss

---

### ACT 2b — Nietzsche's デレ Response (Path A)

**NIETZSCHE** *(mint bubble — noticeably softer)*
> …っ。や、焼きそばパン……？　な、なんで今そんな話を——
>
> *(pause)*
>
> ……ば、馬鹿にしてるの。でも……そう、そういうこと、かもしれない。
> 売り切れたパンを恨んで、でも本当は食べたかっただけ、みたいな……

*[Sprite: Nietzsche's cheeks are slightly pink. Her arms uncross by 2 degrees.]*

---

### ACT 3 — The Closing Blow (Final Hogushi)

**[PLAYER CHOICE — CARD A]** *(pink)*
> "焼きそばパン、明日一緒に買いに行こうよ。8時に売店に並べば絶対残ってるから。"
→ Effect: gaugeRaise — Nietzsche agrees despite herself

**[PLAYER CHOICE — CARD B]** *(pink, ✨ sparkle badge)*  *(Perfect Hogushi)*
> "超人を目指してる人でも、焼きそばパンは食べたいと思う。それは弱さじゃなくて、**人間ってこと**だと思うんだけど。"
→ Effect: hogushiAttempt (Power 7) — triggers second Hogushi Flash

---

### 🎉 HOGUSHI FLASH — Final (Path B, Perfect)

**NIETZSCHE** *(softest voice of the chapter)*
> 人間、ということ……
>
> *(long silence — sunset light on her profile)*
>
> ……あなた、馬鹿ね。でも……そう、かもしれない。
> 超人を目指す私でも、売り切れたパンを悔しいと思う。
>
> それを……恥じていた、のかも。

*[Sprite: Nietzsche looks away. A single cherry-blossom petal drifts past the window.]*

---

### CHAPTER END

**NARRATOR**
> 【第一章 終了】
>
> ニーチェの「ルサンチマンの鎧」に、小さな亀裂が入った。
> 解きメキ度が上昇した。
> 明日の放課後、また話しかけてみよう。

---

## Design Notes

- **Core lesson of this tutorial:** Never engage philosophy head-on. The winning strategy is always an absurdly ordinary, clumsy, human analogy — yakisoba bread, not Nietzsche scholarship.
- **Tsundere tell:** Watch for contradictions between her words and her body language (facing the door, blushing, arms uncrossing).
- **Writer's rule:** Nietzsche uses 1 philosophy term per speech bubble max. The player's "translation" should be 1–2 everyday sentences with a concrete, almost embarrassingly mundane image. The gap between abstract and mundane *is* the humor and the heart.
- **Audio note (TBD):** A soft "click-pop" SFX plays at the lock-to-heart transition. Background music shifts from minor piano to a major key at the Chapter End card.
