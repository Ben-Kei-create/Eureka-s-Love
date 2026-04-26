import SwiftUI

/// The main gameplay screen.
/// Top 40%  → Visual Novel panel (character sprite + background + motif overlay)
/// Bottom 60% → Chat interface (bubbles + choice cards)
struct TokimekiHogushiView: View {
    @EnvironmentObject var gameState: GameStateManager
    @EnvironmentObject var heroineManager: HeroineManager
    @EnvironmentObject var playerStats: PlayerStatsManager

    let heroineId: String

    // Local state for scroll-to-bottom and panel sizing
    @State private var scrollProxy: ScrollViewProxy?

    private var heroine: Heroine? { heroineManager.heroine(id: heroineId) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                TokimekiColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── TOP 40%: Visual Novel Panel ──────────────────────
                    VisualNovelPanel(heroine: heroine, height: geo.size.height * 0.40)

                    // ── BOTTOM 60%: Chat Panel ────────────────────────────
                    ChatPanel(height: geo.size.height * 0.60)
                }

                // ── Hogushi Flash Overlay ─────────────────────────────────
                if gameState.isShowingHogushiFlash, let result = gameState.hogushiResult {
                    HogushiFlashView(result: result) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            gameState.dismissHogushiFlash()
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .zIndex(99)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: gameState.isShowingHogushiFlash)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            gameState.currentHeroineId = heroineId
            gameState.playerStats = playerStats
            gameState.heroineManager = heroineManager
            gameState.loadScenario(id: "\(heroineId)_ch01")
        }
    }
}

// MARK: - Visual Novel Panel

private struct VisualNovelPanel: View {
    let heroine: Heroine?
    let height: CGFloat

    var body: some View {
        ZStack {
            // School background placeholder (replace with Image("bg_classroom"))
            LinearGradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.95),
                                    Color(red: 0.92, green: 0.88, blue: 0.98)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            // Art Nouveau star-chart motif overlay
            StarChartMotifView()
                .opacity(0.18)

            // Character sprite placeholder
            if let heroine {
                ZStack(alignment: .bottom) {
                    // Sprite (use Image(heroine.spriteAsset) in production)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white.opacity(0.0))
                        .overlay(
                            Text(heroine.nameJP)
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(TokimekiColors.textPrimary.opacity(0.55))
                                .offset(y: -30)
                        )

                    // Tokimeki gauge badge — bottom-left of VN panel
                    HStack {
                        TokimekiGaugeView(heroine: heroine)
                            .padding([.leading, .bottom], 12)
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
    @EnvironmentObject var gameState: GameStateManager
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable message list
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(gameState.displayedMessages) { msg in
                            ChatBubbleView(message: msg)
                                .id(msg.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .onChange(of: gameState.displayedMessages.count) { _ in
                    if let last = gameState.displayedMessages.last {
                        withAnimation(.easeOut(duration: 0.3)) { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Divider + choice cards
            if !gameState.pendingChoices.isEmpty {
                Divider().padding(.horizontal, 16)
                ChoiceCardsPanel(choices: gameState.pendingChoices)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TokimekiColors.background)
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: -4)
        )
    }
}

// MARK: - Chat Bubble

struct ChatBubbleView: View {
    let message: ChatMessage

    private var isHeroine: Bool { message.role == .heroine }
    private var isNarrator: Bool { message.role == .narrator || message.role == .system }

    var body: some View {
        Group {
            if isNarrator {
                // Narrator / system messages: centered italic caption
                Text(message.text)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .italic()
                    .foregroundColor(TokimekiColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    if isHeroine {
                        Circle()
                            .fill(TokimekiColors.heroineBubble)
                            .frame(width: 36, height: 36)
                            .overlay(Text("✦").font(.system(size: 14)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    } else {
                        Spacer()
                    }

                    Text(message.text)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(TokimekiColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(isHeroine ? TokimekiColors.heroineBubble : TokimekiColors.playerBubble)
                                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
                        )
                        .frame(maxWidth: 260, alignment: isHeroine ? .leading : .trailing)

                    if !isHeroine {
                        Circle()
                            .fill(TokimekiColors.playerBubble)
                            .frame(width: 36, height: 36)
                            .overlay(Text("★").font(.system(size: 14)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: message.id)
    }
}

// MARK: - Choice Cards Panel

private struct ChoiceCardsPanel: View {
    @EnvironmentObject var gameState: GameStateManager
    let choices: [DialogueChoice]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(choices) { choice in
                    ChoiceCardView(choice: choice) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            gameState.selectChoice(choice)
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
                        .foregroundColor(TokimekiColors.accent)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(choice.text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TokimekiColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isHogushi {
                    Text("翻訳 ×\(choice.translationPower)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(TokimekiColors.accent)
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
                    .shadow(color: isHogushi
                            ? TokimekiColors.accent.opacity(0.25)
                            : Color.black.opacity(0.06),
                            radius: isHogushi ? 10 : 6,
                            x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isHogushi ? TokimekiColors.accent.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeIn(duration: 0.1)) { isPressed = true } }
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
                .foregroundColor(TokimekiColors.accent)
                .font(.system(size: 11, weight: .semibold))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.5)).frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(colors: [TokimekiColors.playerBubble, TokimekiColors.accent],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * heroine.tokimekiProgress, height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: heroine.tokimekiGauge)
                }
            }
            .frame(width: 80, height: 8)

            Text("\(heroine.tokimekiGauge)%")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.black.opacity(0.28))
        )
    }
}

// MARK: - Hogushi Flash Overlay

struct HogushiFlashView: View {
    let result: HogushiResult
    let onDismiss: () -> Void

    @State private var lockOpen = false
    @State private var glowOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Blurred scrim
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                // Padlock → Heart animation
                ZStack {
                    Circle()
                        .fill(TokimekiColors.hogushiFlash)
                        .frame(width: 110, height: 110)
                        .shadow(color: TokimekiColors.accent.opacity(0.5 * glowOpacity), radius: 30)

                    Image(systemName: lockOpen ? "heart.fill" : "lock.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(lockOpen ? TokimekiColors.accent : TokimekiColors.textSecondary)
                        .scaleEffect(lockOpen ? 1.15 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55), value: lockOpen)
                }

                // Flash label
                VStack(spacing: 6) {
                    Text("解きメキほぐし 完了")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(TokimekiColors.accent)

                    Text(result.message)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TokimekiColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    if result.gaugeGain > 0 {
                        Text("解きメキ度 +\(result.gaugeGain)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(TokimekiColors.accent)
                            .clipShape(Capsule())
                    }
                }
                .opacity(textOpacity)

                Button("続ける") { onDismiss() }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(TokimekiColors.accent)
                    .clipShape(Capsule())
                    .shadow(color: TokimekiColors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    .opacity(textOpacity)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // Step 1: glow in
        withAnimation(.easeIn(duration: 0.3)) { glowOpacity = 1 }
        // Step 2: lock flips to heart after 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) { lockOpen = true }
        }
        // Step 3: text fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.35)) { textOpacity = 1 }
        }
    }
}

// MARK: - Star Chart Motif (Art Nouveau-inspired overlay)

private struct StarChartMotifView: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let rings = [0.25, 0.45, 0.65].map { $0 * min(size.width, size.height) }

            for r in rings {
                var path = Path()
                path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.stroke(path, with: .color(.purple.opacity(0.6)), lineWidth: 0.6)
            }

            // Radiating lines
            for deg in stride(from: 0.0, to: 360.0, by: 30.0) {
                let angle = deg * .pi / 180
                let r = rings.last ?? 100
                var line = Path()
                line.move(to: CGPoint(x: cx, y: cy))
                line.addLine(to: CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r))
                ctx.stroke(line, with: .color(.indigo.opacity(0.4)), lineWidth: 0.5)
            }

            // Small star dots at ring/line intersections
            for deg in stride(from: 0.0, to: 360.0, by: 45.0) {
                let angle = deg * .pi / 180
                for r in rings {
                    let pt = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
                    ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 2, y: pt.y - 2, width: 4, height: 4)),
                             with: .color(.white.opacity(0.85)))
                }
            }
        }
    }
}
