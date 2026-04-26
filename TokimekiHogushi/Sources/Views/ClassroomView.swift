import SwiftUI

/// The heroine selection screen — styled like a modern app grid.
struct ClassroomView: View {
    @EnvironmentObject var heroineManager: HeroineManager
    @State private var selectedHeroine: Heroine?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                TokimekiColors.background.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(heroineManager.heroines) { heroine in
                                HeroineCardView(heroine: heroine)
                                    .onTapGesture { selectedHeroine = heroine }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedHeroine) { heroine in
                TokimekiHogushiView(heroineId: heroine.id)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("哲学科 2-Φ組")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(TokimekiColors.textSecondary)
            Text("クラスメートたち")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(TokimekiColors.textPrimary)
        }
    }
}

// MARK: - Heroine Card

private struct HeroineCardView: View {
    let heroine: Heroine

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Portrait area
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [TokimekiColors.heroineBubble.opacity(0.6),
                                     TokimekiColors.hogushiFlash.opacity(0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(0.78, contentMode: .fit)

                // Placeholder silhouette
                Text("✦")
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Tokimeki gauge mini bar
                TokimekiGaugeView(heroine: heroine)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Name + concept chip
            VStack(alignment: .leading, spacing: 4) {
                Text(heroine.nameJP)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(TokimekiColors.textPrimary)
                    .lineLimit(1)

                Text(heroine.shieldConceptJP)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(TokimekiColors.textSecondary)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(TokimekiColors.heroineBubble.opacity(0.6))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TokimekiColors.cardBackground)
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
    }
}
