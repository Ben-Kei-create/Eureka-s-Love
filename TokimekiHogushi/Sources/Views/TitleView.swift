import SwiftUI

struct TitleView: View {
    @State private var isAnimating = false
    @State private var showStart  = false
    @State private var navigateToClassroom = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.97, green: 0.88, blue: 0.93),
                             Color(red: 0.88, green: 0.90, blue: 0.98)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Star-chart decorative layer
                StarChartMotifView()
                    .opacity(0.12)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo block
                    VStack(spacing: 8) {
                        Text("解きメキほぐし")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(TokimekiColors.accent)
                            .shadow(color: TokimekiColors.accent.opacity(0.25), radius: 12, x: 0, y: 4)
                            .scaleEffect(isAnimating ? 1.0 : 0.85)

                        Text("〜哲学者のセーラー服と、日常の論理〜")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(TokimekiColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1 : 0)

                    Spacer().frame(height: 60)

                    // Cherry-blossom decoration
                    HStack(spacing: 14) {
                        ForEach(0..<5, id: \.self) { i in
                            Text("🌸")
                                .font(.system(size: 24))
                                .offset(y: isAnimating ? sin(Double(i) * 0.8) * 6 : 0)
                                .animation(
                                    .easeInOut(duration: 1.8).repeatForever().delay(Double(i) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .opacity(isAnimating ? 1 : 0)

                    Spacer()

                    // Start button
                    if showStart {
                        Button {
                            navigateToClassroom = true
                        } label: {
                            Text("はじめる")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(TokimekiColors.accent)
                                        .shadow(color: TokimekiColors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                        }
                        .padding(.horizontal, 48)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 60)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) { isAnimating = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.5)) { showStart = true }
                }
            }
            .navigationDestination(isPresented: $navigateToClassroom) {
                ClassroomView()
            }
        }
    }
}
