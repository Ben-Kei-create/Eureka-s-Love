import SwiftUI

// MARK: - Chat Message Row
//
// Renders one entry in the dialogue scroll view.
// @ViewBuilder branches on ChatMessage.role:
//
//   .narrator / .system  →  narratorCaption()
//                           Centered italic text, no bubble, no avatar.
//                           Used for scene descriptions and system hints.
//
//   .heroine             →  speechBubble(side: .left, color: message.bubbleColor)
//                           Per-heroine tint derived from Heroine.bubbleColorHex.
//
//   .player              →  speechBubble(side: .right, color: TokimekiColors.playerBubble)

struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        Group {
            switch message.role {
            case .narrator, .system:
                narratorCaption(text: message.text)
            case .heroine:
                speechBubble(message: message,
                             side: .left,
                             bubbleColor: message.bubbleColor,
                             avatarSymbol: "✦")
            case .player:
                speechBubble(message: message,
                             side: .right,
                             bubbleColor: TokimekiColors.playerBubble,
                             avatarSymbol: "★")
            }
        }
        // Entrance animation — each row slides up from slightly below
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Narrator Caption

    @ViewBuilder
    private func narratorCaption(text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .italic()
            .foregroundStyle(TokimekiColors.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Speech Bubble

    enum BubbleSide { case left, right }

    @ViewBuilder
    private func speechBubble(
        message: ChatMessage,
        side: BubbleSide,
        bubbleColor: Color,
        avatarSymbol: String
    ) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if side == .left {
                avatar(name: message.speakerName, symbol: avatarSymbol, color: bubbleColor)
            } else {
                Spacer(minLength: 52)
            }

            VStack(alignment: side == .left ? .leading : .trailing, spacing: 3) {
                // Speaker name label — only shown for heroine messages
                if side == .left, let name = message.speakerName {
                    Text(name)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(TokimekiColors.textSecondary)
                        .padding(.leading, 4)
                }
                bubbleText(text: message.text, color: bubbleColor, side: side)
            }

            if side == .right {
                avatar(name: nil, symbol: avatarSymbol, color: bubbleColor)
            } else {
                Spacer(minLength: 52)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Bubble Text

    @ViewBuilder
    private func bubbleText(text: String, color: Color, side: BubbleSide) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(TokimekiColors.textPrimary)
            .lineSpacing(3)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .shadow(
                        color: .black.opacity(0.07),
                        radius: 7,
                        x: side == .left ? -1 : 1,
                        y: 4
                    )
            )
            .frame(maxWidth: 258, alignment: side == .left ? .leading : .trailing)
    }

    // MARK: - Avatar

    @ViewBuilder
    private func avatar(name: String?, symbol: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.80))
                .frame(width: 34, height: 34)
                .shadow(color: color.opacity(0.30), radius: 4, x: 0, y: 2)
            Text(symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(TokimekiColors.textPrimary.opacity(0.65))
        }
    }
}

// MARK: - Preview

#Preview("ChatMessageRow — all roles") {
    ScrollView {
        VStack(spacing: 10) {
            ChatMessageRow(message: .narrator(
                id: "p0",
                text: "放課後の教室。夕陽が差し込む中、エピクロスが窓辺の植木鉢の前に立っている。"
            ))
            ChatMessageRow(message: ChatMessage(
                id: "p1", role: .heroine,
                text: "庭のバジルを見てください。これが『アタラクシア』——平静の心です。",
                speakerName: "エピクロス",
                bubbleColor: Color(hex: "#DCEDC8")
            ))
            ChatMessageRow(message: ChatMessage(
                id: "p2", role: .player,
                text: "えっと……それって、昼休みに外でお弁当食べると気持ちいい感じ、みたいな？",
                speakerName: nil,
                bubbleColor: TokimekiColors.playerBubble
            ))
            ChatMessageRow(message: .system(
                id: "p3",
                text: "【ヒント】　エピクロスの「快楽」は欲望の追求ではなく、苦痛の不在。日常の小さな喜びに翻訳しよう。"
            ))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(TokimekiColors.background)
}
