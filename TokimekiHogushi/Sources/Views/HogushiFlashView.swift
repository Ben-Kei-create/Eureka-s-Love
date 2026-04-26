import SwiftUI

// MARK: - Hogushi Flash Overlay
//
// 3-step animation sequence:
//   0.00s  Scrim (ultraThinMaterial) fades in; glow circle scales up
//   0.25s  Lock icon trembles (pre-flip anxiety) via stiff interpolatingSpring
//   0.50s  Lock disappears → Heart pops in with interpolatingSpring(stiffness:280, damping:14)
//          — stiffness 280 = snappy response; damping 14 = slight overshoot = ぷるん
//          Petal burst launches simultaneously
//   0.80s  Title text + gauge badge + continue button slide up with spring

struct HogushiFlashView: View {
    let result: HogushiResult
    let onDismiss: () -> Void

    // Step 1 state
    @State private var scrimVisible  = false
    @State private var circleScale   = 0.5
    @State private var glowRadius: CGFloat = 0

    // Step 2 state
    @State private var lockShake     = false  // oscillates via stiff spring
    @State private var lockOpen      = false  // triggers the ぷるん heart
    @State private var petalsBurst   = false

    // Step 3 state
    @State private var contentOffset: CGFloat = 28
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            // ── Scrim ────────────────────────────────────────────────
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(scrimVisible ? 1 : 0)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // ── Card ─────────────────────────────────────────────────
            VStack(spacing: 22) {
                iconStack
                textContent
                continueButton
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.97))
                    .shadow(color: TokimekiColors.accent.opacity(0.20), radius: 36, x: 0, y: 14)
            )
            .padding(.horizontal, 30)
        }
        .onAppear { runAnimation() }
    }

    // MARK: - Icon Stack

    private var iconStack: some View {
        ZStack {
            // Cherry-blossom glow circle
            Circle()
                .fill(TokimekiColors.hogushiFlash)
                .frame(width: 116, height: 116)
                .shadow(color: TokimekiColors.accent.opacity(0.50), radius: glowRadius)
                .scaleEffect(circleScale)
                .animation(.spring(response: 0.5, dampingFraction: 0.65), value: circleScale)

            // Petal burst — 10 petals launch outward at step 2
            PetalBurstView(launched: $petalsBurst)

            // Lock icon: trembles right before disappearing
            Image(systemName: "lock.fill")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(TokimekiColors.textSecondary)
                .rotationEffect(.degrees(lockShake ? 16 : 0))
                // Trembling: stiff spring with low damping = fast jitter
                .animation(.interpolatingSpring(stiffness: 650, damping: 7), value: lockShake)
                .scaleEffect(lockOpen ? 0.05 : 1.0)
                .opacity(lockOpen ? 0 : 1)
                .animation(.easeIn(duration: 0.10), value: lockOpen)

            // Heart icon: the ぷるん moment
            // interpolatingSpring(stiffness: 280, damping: 14)
            //   → snappy (280) with controlled overshoot (14) for the "cute bounce"
            Image(systemName: "heart.fill")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(TokimekiColors.accent)
                .scaleEffect(lockOpen ? 1.0 : 0.05)
                .rotationEffect(.degrees(lockOpen ? 0 : -18))
                .opacity(lockOpen ? 1 : 0)
                .animation(.interpolatingSpring(stiffness: 280, damping: 14), value: lockOpen)
        }
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(spacing: 10) {
            Text("解きメキほぐし 完了")
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(TokimekiColors.accent)

            Text(result.message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(TokimekiColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            if result.gaugeGain > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "heart.fill").font(.system(size: 11))
                    Text("解きメキ度 +\(result.gaugeGain)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Capsule().fill(TokimekiColors.accent))
            }
        }
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button(action: onDismiss) {
            Label("続ける", systemImage: "arrow.right")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 13)
                .background(Capsule().fill(TokimekiColors.accent))
                .shadow(color: TokimekiColors.accent.opacity(0.40), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    // MARK: - Animation Sequence

    private func runAnimation() {
        // Step 1 (0.00s): scrim fades in, circle scales up
        withAnimation(.easeOut(duration: 0.30)) {
            scrimVisible = true
            circleScale  = 1.0
            glowRadius   = 18
        }

        // Step 1b (0.25s): lock trembles — stiff spring fires the rotation oscillation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            lockShake = true
        }

        // Step 2 (0.50s): lock → heart + petal burst + glow expands
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            lockShake   = false
            lockOpen    = true          // triggers interpolatingSpring(280, 14) on heart
            petalsBurst = true
            withAnimation(.easeOut(duration: 0.45)) { glowRadius = 38 }
        }

        // Step 3 (0.80s): text + button slide up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 18)) {
                contentOffset  = 0
                contentOpacity = 1
            }
        }
    }
}

// MARK: - Petal Burst

private struct PetalBurstView: View {
    @Binding var launched: Bool

    private struct Petal: Identifiable {
        let id: Int; let angle: Double; let color: Color; let size: CGFloat
    }

    // 10 petals, alternating the three pastel tones, random-ish sizes
    private let petals: [Petal] = (0..<10).map { i in
        let colors: [Color] = [TokimekiColors.playerBubble,
                               TokimekiColors.hogushiFlash,
                               TokimekiColors.accent.opacity(0.75)]
        return Petal(id: i,
                     angle: Double(i) * 36.0,
                     color: colors[i % colors.count],
                     size:  CGFloat([7, 9, 6, 10, 7, 8, 5, 9, 7, 8][i]))
    }

    var body: some View {
        ZStack {
            ForEach(petals) { p in
                Ellipse()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size * 1.7)
                    .rotationEffect(.degrees(p.angle))
                    .offset(
                        x: launched ? cos(p.angle * .pi / 180) * 70 : 0,
                        y: launched ? sin(p.angle * .pi / 180) * 70 : 0
                    )
                    .scaleEffect(launched ? 0.15 : 1.0)
                    .opacity(launched ? 0 : 0.90)
                    // Stagger the petals slightly so they don't all launch at once
                    .animation(
                        .easeOut(duration: 0.55).delay(Double(p.id % 4) * 0.03),
                        value: launched
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview("HogushiFlashView — Perfect") {
    HogushiFlashView(
        result: HogushiResult(
            success: true, gaugeGain: 25,
            message: "「焼きそばパン」の翻訳が、\nニーチェの鎧を完全に溶かした。"
        ),
        onDismiss: {}
    )
}
