//
//  CharacterView.swift
//  UzaydaElementAvi
//

import SwiftUI

private struct SuitDef {
    let color: Color
    let hex: String
    let name: String
    let cost: Int
}

struct CharacterView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette
        let suits: [SuitDef] = [
            SuitDef(color: Color(hex: 0x5A5A78), hex: "#5A5A78", name: "Standart",     cost: 0),
            SuitDef(color: pal.accent,           hex: pal.accentHex, name: "Plazma",   cost: 0),
            SuitDef(color: Color(hex: 0xFF3B6B), hex: "#FF3B6B", name: "Korsan",       cost: 200),
            SuitDef(color: Color(hex: 0xAAFF00), hex: "#AAFF00", name: "Toksik",       cost: 400),
            SuitDef(color: Color(hex: 0xFFD84D), hex: "#FFD84D", name: "Altın Yıldız", cost: 800),
            SuitDef(color: Color(hex: 0xA875FF), hex: "#A875FF", name: "Süpernova",    cost: 1200),
        ]

        ZStack {
            RadialGradient(colors: [Color(hex: 0x0A0820), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: pal.accent, accent2: pal.accent2).ignoresSafeArea()

            ScrollView {
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

                    Text("Astronot")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    Text("Puanlarınla kostüm aç.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.top, 4)

                    HStack {
                        Spacer()
                        AlienKidView(accent: pal.accent, accent2: pal.accent2, suit: game.suit, size: 180)
                        Spacer()
                    }
                    .padding(.top, 28)

                    Text("KOSTÜM SEÇ")
                        .font(AppFont.mono(12))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                              spacing: 10) {
                        ForEach(0..<suits.count, id: \.self) { i in
                            suitCard(suit: suits[i])
                        }
                    }
                    .padding(.top, 14)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)
                .padding(.bottom, 40)
            }
        }
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func suitCard(suit: SuitDef) -> some View {
        let unlocked = suit.cost == 0 || game.totalScore >= suit.cost
        let active = suit.hex.uppercased() == game.suitHex.uppercased()

        Button {
            if unlocked { game.setSuit(hex: suit.hex) }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(suit.color)
                        .frame(width: 36, height: 36)
                        .shadow(color: suit.color.opacity(0.5), radius: 8)
                    if !unlocked {
                        Text("🔒").font(.system(size: 16))
                    }
                }
                Text(suit.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(suit.cost == 0 ? "AÇIK" : "\(suit.cost) P")
                    .font(AppFont.mono(9))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(active ? suit.color.opacity(0.18) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(active ? suit.color : Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: active ? suit.color.opacity(0.5) : .clear, radius: 12)
            .opacity(unlocked ? 1 : 0.5)
        }
        .buttonStyle(PressDownStyle())
        .disabled(!unlocked)
    }
}
