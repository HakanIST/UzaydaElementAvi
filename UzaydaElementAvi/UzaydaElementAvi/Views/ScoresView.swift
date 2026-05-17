//
//  ScoresView.swift
//  UzaydaElementAvi
//
//  Oyuncu istatistikleri ve seviye bazlı skor ekranı.
//

import SwiftUI

struct ScoresView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette

        ZStack {
            RadialGradient(colors: [Color(hex: 0x0A0820), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: pal.accent, accent2: pal.accent2).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Button {
                    game.returnToMenu()
                } label: {
                    Text("← Geri")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12)))
                }

                Text("Skorlar")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Text("En iyi performansın burada.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 4)

                // Total score card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOPLAM PUAN")
                            .font(AppFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundColor(pal.accent)
                        Text("\(game.totalScore)")
                            .font(AppFont.mono(42, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: pal.accent.opacity(0.5), radius: 12)
                    }
                    Spacer()
                    Circle()
                        .fill(RadialGradient(colors: [Color(hex: 0xFFD84D), Color(hex: 0xC2820F)],
                                             center: .center, startRadius: 2, endRadius: 24))
                        .frame(width: 48, height: 48)
                        .shadow(color: Color(hex: 0xFFD84D).opacity(0.5), radius: 12)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(pal.accent.opacity(0.3), lineWidth: 1))
                .padding(.top, 24)

                // Per-level stats
                Text("SEKTÖR PERFORMANSI")
                    .font(AppFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                VStack(spacing: 10) {
                    levelRow(id: 1, name: "Kozmik Koridor", color: pal.accent)
                    levelRow(id: 2, name: "Plazma Hol", color: pal.accent2)
                    levelRow(id: 3, name: "Kriyo Labirent", color: Color(hex: 0xFF3B6B))
                }

                // Unlocked level
                HStack {
                    Text("Açılan sektör sayısı")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.65))
                    Spacer()
                    Text("\(game.unlockedLevel) / 3")
                        .font(AppFont.mono(16, weight: .bold))
                        .foregroundColor(pal.accent)
                }
                .padding(.top, 24)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
        }
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func levelRow(id: Int, name: String, color: Color) -> some View {
        let stars = game.starsFor(level: id)
        let unlocked = id <= game.unlockedLevel

        HStack(spacing: 14) {
            Text("0\(id)")
                .font(AppFont.mono(22, weight: .bold))
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(unlocked ? name : "🔒 Kilitli")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Text("★")
                            .font(.system(size: 16))
                            .foregroundColor(i < stars ? Color(hex: 0xFFD84D) : .white.opacity(0.18))
                            .shadow(color: i < stars ? Color(hex: 0xFFD84D) : .clear, radius: 3)
                    }
                }
            }

            Spacer()

            if unlocked && stars > 0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: 0xAAFF00))
                    .font(.system(size: 18))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(unlocked ? color.opacity(0.25) : Color.white.opacity(0.08), lineWidth: 1))
        .opacity(unlocked ? 1.0 : 0.5)
    }
}
