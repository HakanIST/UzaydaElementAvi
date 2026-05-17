//
//  MainMenuView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette

        ZStack {
            RadialGradient(colors: [Color(hex: 0x1A0B2E), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: .top, startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: pal.accent, accent2: pal.accent2)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                titleBlock
                    .padding(.top, 22)

                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [pal.accent.opacity(0.25), .clear],
                                             center: .center, startRadius: 5, endRadius: 120))
                        .frame(width: 200, height: 200)
                    AlienKidView(accent: pal.accent, accent2: pal.accent2, suit: game.suit, size: 140)
                }
                .padding(.top, 14)

                VStack(spacing: 12) {
                    NeonButton(title: "► Göreve Başla", size: .lg,
                               accent: pal.accent, accent2: pal.accent2) {
                        game.goPlay()
                    }
                    HStack(spacing: 12) {
                        NeonButton(title: "Astronot", size: .sm, variant: .ghost,
                                   accent: pal.accent, accent2: pal.accent2) {
                            game.openCharacter()
                        }
                        NeonButton(title: "Skorlar", size: .sm, variant: .ghost,
                                   accent: pal.accent, accent2: pal.accent2) {
                            game.openScores()
                        }
                    }
                }
                .padding(.top, 18)

                Spacer()
            }
            .padding(.top, 60)
        }
        .foregroundColor(.white)
    }

    private var topBar: some View {
        HStack {
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: 0xFFD84D), Color(hex: 0xC2820F)],
                                         center: .center, startRadius: 1, endRadius: 8))
                    .frame(width: 12, height: 12)
                    .shadow(color: Color(hex: 0xFFD84D), radius: 4)
                Text("\(game.totalScore)")
                    .font(AppFont.mono(13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.06)))
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
        .padding(.horizontal, 20)
    }

    private var titleBlock: some View {
        let pal = game.palette
        return VStack(spacing: 6) {
            Text("SEKTÖR-7 · GÖREV BAŞLATILIYOR")
                .font(AppFont.mono(11, weight: .medium))
                .tracking(4)
                .foregroundColor(pal.accent)
            Text("UZAYDA\nELEMENT AVI")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(colors: [.white, pal.accent],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: pal.accent.opacity(0.6), radius: 18)
                .padding(.top, 2)
            Text("İstasyondan kaç. Kapıları aç.\nElementleri topla.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
}

#Preview {
    MainMenuView().environmentObject(GameViewModel())
}
