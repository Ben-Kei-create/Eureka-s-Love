import SwiftUI

/// Save / Load screen — themed around Laozi's philosophy of wu wei ("let it be").
struct SaveLoadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var savedMessage: String?

    var body: some View {
        ZStack {
            TokimekiColors.background.ignoresSafeArea()

            VStack(spacing: 28) {
                // Laozi guide header
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [TokimekiColors.heroineBubble,
                                                        TokimekiColors.hogushiFlash],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 80, height: 80)
                        Text("☯")
                            .font(.system(size: 36))
                    }
                    Text("老子（保存の精）")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(TokimekiColors.textPrimary)
                    Text("「為學日益、為道日損」\n— 学べば増え、道を歩めば削ぎ落とされる。\nセーブは、手放すことよ。")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(TokimekiColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Divider()

                // Save slots (3 slots, UserDefaults-backed in real implementation)
                VStack(spacing: 12) {
                    ForEach(1...3, id: \.self) { slot in
                        SaveSlotRow(slot: slot)
                    }
                }

                if let msg = savedMessage {
                    Text(msg)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(TokimekiColors.accent)
                        .transition(.opacity)
                }

                Spacer()

                Button("戻る") { dismiss() }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(TokimekiColors.textSecondary)
            }
            .padding(24)
        }
        .navigationBarHidden(true)
    }
}

private struct SaveSlotRow: View {
    let slot: Int
    @State private var isSaved = false

    var body: some View {
        HStack(spacing: 14) {
            Text("スロット \(slot)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(TokimekiColors.textPrimary)

            Spacer()

            Text(isSaved ? "第1章 — ニーチェ" : "空き")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(TokimekiColors.textSecondary)

            Button(isSaved ? "上書き" : "保存") {
                withAnimation { isSaved = true }
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(TokimekiColors.accent)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TokimekiColors.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}
