import SwiftUI

/// Player's three philosophical weapon stats — presented like a habit-tracker card.
struct ParameterDashboardView: View {
    @EnvironmentObject var playerStats: PlayerStatsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("哲学的武器")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(TokimekiColors.textPrimary)

            StatRowView(label: "論理構築力",
                        labelEN: "Logic Construction",
                        value: playerStats.stats.logicConstruction,
                        maxValue: PlayerStats.max.logicConstruction,
                        color: Color(red: 0.68, green: 0.80, blue: 1.00))

            StatRowView(label: "概念翻訳力",
                        labelEN: "Concept Translation",
                        value: playerStats.stats.conceptTranslation,
                        maxValue: PlayerStats.max.conceptTranslation,
                        color: TokimekiColors.heroineBubble)

            StatRowView(label: "詭弁耐性",
                        labelEN: "Sophistry Resistance",
                        value: playerStats.stats.sophistryResistance,
                        maxValue: PlayerStats.max.sophistryResistance,
                        color: TokimekiColors.hogushiFlash)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TokimekiColors.cardBackground)
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Stat Row

private struct StatRowView: View {
    let label: String
    let labelEN: String
    let value: Int
    let maxValue: Int
    let color: Color

    private var progress: Double { Double(value) / Double(maxValue) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(TokimekiColors.textPrimary)
                    Text(labelEN)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(TokimekiColors.textSecondary)
                }
                Spacer()
                Text("\(value) / \(maxValue)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(TokimekiColors.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.2)).frame(height: 8)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: value)
                }
            }
            .frame(height: 8)
        }
    }
}
