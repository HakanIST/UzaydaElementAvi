//
//  GameOverView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var game: GameViewModel
    @State private var shake = false

    var body: some View {
        let pal = game.palette

        ZStack {
            RadialGradient(colors: [Color(hex: 0x2A0810), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: Color(hex: 0xFF3B6B), accent2: pal.accent2).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("GÖREV BAŞARISIZ")
                    .font(AppFont.mono(11, weight: .medium))
                    .tracking(4)
                    .foregroundColor(Color(hex: 0xFF3B6B))
                    .padding(.top, 120)

                Text("OYUN BİTTİ")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color(hex: 0xFF3B6B), radius: 16)
                    .offset(x: shake ? 6 : -6)
                    .animation(.easeInOut(duration: 0.15).repeatCount(2, autoreverses: true), value: shake)
                    .onAppear { shake = true }

                Text("İstasyon enerjini tüketti.\nYeni bir kaçış denemeye var mısın?")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 18)

                Text("SON PUAN")
                    .font(AppFont.mono(12))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 30)
                Text(String(format: "%04d", game.lastRunScore))
                    .font(AppFont.mono(48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: pal.accent, radius: 12)

                VStack(spacing: 10) {
                    NeonButton(title: "↻ Yeniden Dene", size: .lg,
                               accent: pal.accent, accent2: pal.accent2) {
                        game.restartLevel()
                    }
                    NeonButton(title: "Ana Menü", size: .sm, variant: .ghost,
                               accent: pal.accent, accent2: pal.accent2) {
                        game.returnToMenu()
                    }
                }
                .padding(.top, 40)

                Spacer()
            }
        }
        .foregroundColor(.white)
    }
}
