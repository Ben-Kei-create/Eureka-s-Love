import SwiftUI

// MARK: - Main Gameplay Screen
//
// Screen split:
//   Top 40%    VisualNovelPanel   — character sprite + background + Art Nouveau motif
//   Bottom 60% ChatPanel          — ChatMessageRow list + ChoiceCardView cards

struct TokimekiHogushiView: View {
    @EnvironmentObject var scenario: ScenarioManager
    @EnvironmentObject var heroineManager: HeroineManager
    @EnvironmentObject var playerStats: PlayerStatsManager

    let heroineId: String
    private var heroine: Heroine? { heroineManager.heroine(id: heroineId) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                TokimekiColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    VisualNovelPanel(heroine: heroine, height: geo.size.height * 0.40)
                    ChatPanel(height: geo.size.height * 0.60)
                }

                // HogushiFlashView lives in its own file; shown as full-screen overlay
                if scenario.isShowingHogushiFlash, let result = scenario.hogushiResult {
                    HogushiFlashView(result: result) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            scenario.dismissHogushiFlash()
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.90)))
                    .zIndex(99)
                }
            }
            .animation(.spring(response: 0.40, dampingFraction: 0.78),
                       value: scenario.isShowingHogushiFlash)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            scenario.playerStats   = playerStats
            scenario.heroineManager = heroineManager
            scenario.loadScenario(heroineId: heroineId)
        }
    }
}

// MARK: - Visual Novel Panel

private struct VisualNovelPanel: View {
    let heroine: Heroine?
    let height: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.95),
                                    Color(red: 0.92, green: 0.88, blue: 0.98)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            StarChartMotifView().opacity(0.18)

            if let heroine {
                ZStack(alignment: .bottom) {
                    // Production: replace with Image(heroine.spriteAsset).resizable()
                    Text(heroine.nameJP)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(TokimekiColors.textPrimary.opacity(0.45))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .offset(y: -20)

                    HStack {
                        TokimekiGaugeView(heroine: heroine).padding([.leading, .bottom], 12)
                        Spacer()
                    }
                }
            }
        }
        .frame(height: height)
        .clipped()
    }
}

// MARK: - Chat Panel

private struct ChatPanel: View {
    @EnvironmentObject var scenario: ScenarioManager
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(scenario.displayedMessages) { msg in
                            // ChatMessageRow handles narrator vs bubble branching
                            ChatMessageRow(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .onChange(of: scenario.displayedMessages.count) { _ in
                    if let last = scenario.displayedMessages.last {
                        withAnimation(.easeOut(duration: 0.28)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if !scenario.pendingChoices.isEmpty {
                Divider().padding(.horizontal, 16)
                ChoiceCardsPanel(choices: scenario.pendingChoices)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TokimekiColors.background)
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: -4)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: scenario.pendingChoices.count)
    }
}

// MARK: - Choice Cards Panel

private struct ChoiceCardsPanel: View {
    @EnvironmentObject var scenario: ScenarioManager
    let choices: [DialogueChoice]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(choices) { choice in
                    ChoiceCardView(choice: choice) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.80)) {
                            scenario.selectChoice(choice)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxHeight: 220)
    }
}

// MARK: - Choice Card

struct ChoiceCardView: View {
    let choice: DialogueChoice
    let onTap: () -> Void
    @State private var isPressed = false
    private var isHogushi: Bool { choice.effect == .hogushiAttempt }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                if isHogushi {
                    Image(systemName: "sparkles")
                        .foregroundStyle(TokimekiColors.accent)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(choice.text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(TokimekiColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isHogushi {
                    Text("翻訳 ×\(choice.translationPower)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(TokimekiColors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(TokimekiColors.hogushiFlash)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TokimekiColors.cardBackground)
                    .shadow(
                        color: isHogushi ? TokimekiColors.accent.opacity(0.22) : .black.opacity(0.06),
                        radius: isHogushi ? 10 : 6, x: 0, y: 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isHogushi ? TokimekiColors.accent.opacity(0.45) : .clear, lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.easeIn(duration: 0.10))  { isPressed = true  } }
            .onEnded   { _ in withAnimation(.easeOut(duration: 0.15)) { isPressed = false } }
        )
    }
}

// MARK: - Tokimeki Gauge

struct TokimekiGaugeView: View {
    let heroine: Heroine

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .foregroundStyle(TokimekiColors.accent)
                .font(.system(size: 11, weight: .semibold))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.5)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [TokimekiColors.playerBubble, TokimekiColors.accent],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * heroine.tokimekiProgress, height: 8)
                        .animation(.spring(response: 0.60, dampingFraction: 0.70),
                                   value: heroine.tokimekiGauge)
                }
            }
            .frame(width: 80, height: 8)

            Text("\(heroine.tokimekiGauge)%")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.black.opacity(0.28)))
    }
}

// MARK: - Star Chart Motif (Art Nouveau overlay — Canvas-drawn)

struct StarChartMotifView: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width  / 2
            let cy = size.height / 2
            let rings = [0.25, 0.45, 0.65].map { $0 * min(size.width, size.height) }

            for r in rings {
                var p = Path()
                p.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.stroke(p, with: .color(.purple.opacity(0.60)), lineWidth: 0.6)
            }
            for deg in stride(from: 0.0, to: 360.0, by: 30.0) {
                let a = deg * .pi / 180
                let r = rings.last ?? 100
                var l = Path()
                l.move(to: CGPoint(x: cx, y: cy))
                l.addLine(to: CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r))
                ctx.stroke(l, with: .color(.indigo.opacity(0.40)), lineWidth: 0.5)
            }
            for deg in stride(from: 0.0, to: 360.0, by: 45.0) {
                let a = deg * .pi / 180
                for r in rings {
                    let pt = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r)
                    ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 2, y: pt.y - 2, width: 4, height: 4)),
                             with: .color(.white.opacity(0.85)))
                }
            }
        }
    }
}
