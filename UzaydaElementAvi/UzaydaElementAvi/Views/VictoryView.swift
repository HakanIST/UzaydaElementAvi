//
//  VictoryView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct VictoryView: View {
    @EnvironmentObject var game: GameViewModel
    @State private var starsShown = 0

    var body: some View {
        let pal = game.palette
        let stars: Int = game.lastRunScore > 800 ? 3 : (game.lastRunScore > 500 ? 2 : 1)

        ZStack {
            RadialGradient(colors: [Color(hex: 0x0D2818), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: pal.accent, accent2: pal.accent2).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("SEKTÖR \(String(format: "%02d", game.level)) TEMİZLENDİ")
                    .font(AppFont.mono(11, weight: .medium))
                    .tracking(4)
                    .foregroundColor(Color(hex: 0xAAFF00))
                    .padding(.top, 90)

                Text("KAÇIŞ TAMAMLANDI")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color(hex: 0xAAFF00)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: Color(hex: 0xAAFF00).opacity(0.5), radius: 18)
                    .padding(.top, 6)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                HStack(spacing: 14) {
                    ForEach(0..<3, id: \.self) { i in
                        Text("★")
                            .font(.system(size: 48))
                            .foregroundColor(i < stars ? Color(hex: 0xFFD84D) : .white.opacity(0.14))
                            .shadow(color: i < stars ? Color(hex: 0xFFD84D) : .clear, radius: 10)
                            .scaleEffect(i < starsShown ? 1.0 : 0.5)
                            .opacity(i < starsShown ? 1 : 0)
                            .animation(.spring(response: 0.4).delay(Double(i) * 0.2), value: starsShown)
                    }
                }
                .padding(.top, 22)
                .onAppear {
                    starsShown = stars
                }

                // Score breakdown
                VStack(spacing: 0) {
                    breakdownRow(label: "Toplam puan", value: "\(game.lastRunScore)", highlight: true, palette: pal)
                    breakdownRow(label: "Element atomu", value: "× \(game.lastRunAtoms)", palette: pal)
                    breakdownRow(label: "Kapı bonusu", value: "+ \(3 * 300)", palette: pal)
                    breakdownRow(label: "Tamamlama bonusu", value: "+ 420", palette: pal)
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12)))
                .frame(maxWidth: 300)
                .padding(.top, 28)

                VStack(spacing: 10) {
                    NeonButton(title: "Sonraki Sektör ►", size: .lg,
                               accent: Color(hex: 0xAAFF00), accent2: pal.accent) {
                        if game.level < 3 { game.nextLevel() } else { game.returnToMenu() }
                    }
                    NeonButton(title: "Ana Menüye Dön", size: .sm, variant: .ghost,
                               accent: pal.accent, accent2: pal.accent2) {
                        game.returnToMenu()
                    }
                }
                .padding(.top, 28)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func breakdownRow(label: String, value: String, highlight: Bool = false, palette: Palette) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.65))
                .font(.system(size: 14))
            Spacer()
            Text(value)
                .font(AppFont.mono(highlight ? 18 : 14, weight: .bold))
                .foregroundColor(highlight ? palette.accent : .white)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .top) {
            if !highlight {
                Divider().background(Color.white.opacity(0.06))
            }
        }
    }
}
