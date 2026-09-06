import SwiftUI

struct OpeningView: View {
    @State private var showWelcome = false
    @State private var animateLogo = false
    @State private var floatLogo = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.20, blue: 0.47),
                    Color(red: 0.14, green: 0.44, blue: 0.82),
                    Color(red: 0.16, green: 0.72, blue: 0.63)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 8)
                .offset(y: floatLogo ? -10 : 10)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floatLogo)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 124, height: 124)

                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 144, height: 144)

                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundStyle(.white)
                        .scaleEffect(animateLogo ? 1.0 : 0.9)
                        .opacity(animateLogo ? 1.0 : 0.8)
                }
                .offset(y: floatLogo ? -12 : 12)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floatLogo)

                VStack(spacing: 8) {
                    Text("Tax Buddy")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Simple tax help for first-time filers")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateLogo = true
            }

            floatLogo = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                showWelcome = true
            }
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView()
        }
    }
}

#Preview {
    OpeningView()
}
