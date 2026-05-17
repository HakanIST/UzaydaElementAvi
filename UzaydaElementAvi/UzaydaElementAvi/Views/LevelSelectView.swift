//
//  LevelSelectView.swift
//  UzaydaElementAvi
//

import SwiftUI

private struct LevelInfo {
    let id: Int
    let name: String
    let sub: String
    let stars: Int
    let color: Color
}

struct LevelSelectView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette
        let levels: [LevelInfo] = [
            LevelInfo(id: 1, name: "KOZMİK KORİDOR",  sub: "Eğitim Sektörü",     stars: game.starsFor(level: 1), color: pal.accent),
            LevelInfo(id: 2, name: "PLAZMA HOL",      sub: "Hareketli Engeller", stars: game.starsFor(level: 2), color: pal.accent2),
            LevelInfo(id: 3, name: "KRİYO LABİRENT",  sub: "Lazer Bariyerler",   stars: game.starsFor(level: 3), color: Color(hex: 0xFF3B6B)),
        ]

        ZStack {
            RadialGradient(colors: [Color(hex: 0x0D0820), Color(hex: 0x050510), Color(hex: 0x02020A)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 700)
                .ignoresSafeArea()

            AmbientBackground(accent: pal.accent, accent2: pal.accent2)
                .ignoresSafeArea()

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

                Text("Sektör seç")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Text("3 kapı, 3 bulmaca, 1 dakika.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 4)

                VStack(spacing: 14) {
                    ForEach(levels, id: \.id) { lv in
                        levelCard(lv: lv)
                    }
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
    private func levelCard(lv: LevelInfo) -> some View {
        let locked = lv.id > game.unlockedLevel
        let baseColor = lv.color

        Button {
            if !locked { game.pickLevel(lv.id) }
        } label: {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: locked
                        ? [Color.white.opacity(0.03), Color.white.opacity(0.03)]
                        : [baseColor.opacity(0.18), Color.white.opacity(0.02)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Circle()
                    .fill(RadialGradient(colors: [baseColor.opacity(0.25), .clear],
                                          center: .center, startRadius: 5, endRadius: 80))
                    .frame(width: 120, height: 120)
                    .offset(x: 230, y: -30)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SEKTÖR 0\(lv.id)")
                        .font(AppFont.mono(10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(baseColor)
                    Text(locked ? "🔒 KİLİTLİ" : lv.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                    Text(lv.sub)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Text("★")
                                .font(.system(size: 18))
                                .foregroundColor(i < lv.stars ? Color(hex: 0xFFD84D) : .white.opacity(0.18))
                                .shadow(color: i < lv.stars ? Color(hex: 0xFFD84D) : .clear, radius: 4)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(locked ? Color.white.opacity(0.08) : baseColor.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: locked ? .clear : baseColor.opacity(0.2), radius: 16)
            .opacity(locked ? 0.5 : 1)
        }
        .buttonStyle(PressDownStyle())
        .disabled(locked)
    }
}

#Preview {
    LevelSelectView().environmentObject(GameViewModel())
}
