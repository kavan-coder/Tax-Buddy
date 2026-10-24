import SwiftUI
import AVFoundation

struct WelcomeView: View {
    @AppStorage("showTaxBuddyCelebration") private var showCelebration = false
    @State private var showOverlay = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color.white,
                        Color(red: 0.94, green: 0.97, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.16), Color.green.opacity(0.16)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 96, height: 96)

                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 42, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.green],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.top, 8)

                            Text("Welcome to Tax Buddy")
                                .font(.system(size: 31, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.10, green: 0.14, blue: 0.24))

                            Text("A cleaner, easier way for first-time filers to learn taxes or get guided help step by step.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.34, green: 0.39, blue: 0.49))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .lineSpacing(2)
                        }
                        .padding(.top, 14)
                        .padding(.bottom, 4)

                        VStack(spacing: 45) {
                            NavigationLink {
                                StepsView(mode: .practice)
                            } label: {
                                WelcomeOptionCard(
                                    title: "Practice Mode",
                                    subtitle: "Learn how filing works using safe sample numbers we provide.",
                                    icon: "graduationcap.fill",
                                    accentTop: Color(red: 0.18, green: 0.70, blue: 0.42),
                                    accentBottom: Color(red: 0.12, green: 0.54, blue: 0.31),
                                    badgeText: "Best for learning"
                                )
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                SoundManager.shared.playClick()
                            })
                            .buttonStyle(.plain)

                            NavigationLink {
                                StepsView(mode: .real)
                            } label: {
                                WelcomeOptionCard(
                                    title: "File With My Information",
                                    subtitle: "Get guided help using your own tax information and personal data.",
                                    icon: "shield.lefthalf.filled.badge.checkmark",
                                    accentTop: Color(red: 0.22, green: 0.58, blue: 0.95),
                                    accentBottom: Color(red: 0.10, green: 0.33, blue: 0.74),
                                    badgeText: "For real filing help"
                                )
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                SoundManager.shared.playClick()
                            })
                            .buttonStyle(.plain)
                        }

                        VStack(spacing: 10) {
                            Label("Built for first-time filers", systemImage: "checkmark.seal.fill")
                            Label("Step-by-step explanations", systemImage: "list.bullet.clipboard.fill")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color(red: 0.42, green: 0.47, blue: 0.57))
                        .padding(.top, 10)
                        .padding(.bottom, 18)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 24)
                }

                if showOverlay {
                    CelebrationOverlayView()
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(10)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                triggerCelebrationIfNeeded()
            }
        }
    }

    private func triggerCelebrationIfNeeded() {
        guard showCelebration else { return }
        showCelebration = false

        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            showOverlay = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showOverlay = false
            }
        }
    }
}

private struct CelebrationOverlayView: View {
    private let confettiColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<26, id: \.self) { index in
                Circle()
                    .fill(confettiColors[index % confettiColors.count])
                    .frame(width: CGFloat(8 + (index % 6)), height: CGFloat(8 + (index % 6)))
                    .offset(x: CGFloat((index % 7) * 46 - 138), y: CGFloat((index / 7) * 22 - 170))
                    .rotationEffect(.degrees(Double(index * 17)))
                    .opacity(0.9)
            }

            VStack(spacing: 10) {
                Text("🎉")
                    .font(.system(size: 42))

                Text("You did it!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.10, green: 0.14, blue: 0.24))

                Text("Nice work finishing your tax steps.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.24, green: 0.29, blue: 0.38))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.16).ignoresSafeArea())
    }
}

private struct WelcomeOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentTop: Color
    let accentBottom: Color
    let badgeText: String
    @State private var badgePulse = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentTop, accentBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accentBottom.opacity(0.22), radius: 18, x: 0, y: 12)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 54, height: 54)

                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Text(badgeText)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.24))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                        .scaleEffect(badgePulse ? 1.06 : 0.98)
                        .opacity(badgePulse ? 1 : 0.9)
                        .animation(
                            .easeInOut(duration: 1.15).repeatForever(autoreverses: true),
                            value: badgePulse
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.headline)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .foregroundStyle(accentBottom)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 5)
                .padding(.top, 6)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .onAppear {
            badgePulse = true
        }
    }
}

#Preview {
    WelcomeView()
}
