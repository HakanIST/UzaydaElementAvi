//
//  SplashView.swift
//  UzaydaElementAvi
//
//  Animated splash screen with dedication.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var game: GameViewModel
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var dedicationOpacity: Double = 0
    @State private var starsVisible: Bool = false

    var body: some View {
        let pal = game.palette

        ZStack {
            // Background
            RadialGradient(colors: [Color(hex: 0x0A0820), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.4),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            // Twinkling stars
            if starsVisible {
                Canvas { ctx, size in
                    for i in 0..<40 {
                        let x = CGFloat((i * 137 + 83) % Int(size.width))
                        let y = CGFloat((i * 211 + 47) % Int(size.height))
                        let s: CGFloat = CGFloat(i % 3 + 1) * 0.6
                        let a = Double(i % 5 + 3) / 10.0
                        let rect = CGRect(x: x, y: y, width: s, height: s)
                        ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(a)))
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }

            VStack(spacing: 0) {
                Spacer()

                // Atom icon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(RadialGradient(colors: [pal.accent.opacity(0.3), Color.clear],
                                             center: .center, startRadius: 10, endRadius: 80))
                        .frame(width: 160, height: 160)

                    // Atom orbits
                    ForEach(0..<3, id: \.self) { i in
                        Ellipse()
                            .stroke(pal.accent.opacity(0.6), lineWidth: 1.5)
                            .frame(width: 90, height: 40)
                            .rotationEffect(.degrees(Double(i) * 60))
                    }

                    // Nucleus
                    Circle()
                        .fill(RadialGradient(colors: [pal.accent, pal.accent2],
                                             center: .center, startRadius: 2, endRadius: 14))
                        .frame(width: 22, height: 22)
                        .shadow(color: pal.accent, radius: 12)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Title
                VStack(spacing: 6) {
                    Text("UZAYDA")
                        .font(AppFont.mono(28, weight: .bold))
                        .tracking(8)
                        .foregroundColor(.white)
                    Text("ELEMENT AVI")
                        .font(AppFont.mono(22, weight: .medium))
                        .tracking(6)
                        .foregroundColor(pal.accent)
                }
                .opacity(textOpacity)
                .padding(.top, 28)

                Spacer()

                // Dedication
                VStack(spacing: 4) {
                    Text("— for —")
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.35))
                        .italic()
                    Text("Yusuf Selim Özdemir")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .shadow(color: pal.accent.opacity(0.3), radius: 8)
                }
                .opacity(dedicationOpacity)
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                starsVisible = true
            }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.6).delay(0.3)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                textOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(1.3)) {
                dedicationOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    game.screen = .menu
                }
            }
        }
    }
}
