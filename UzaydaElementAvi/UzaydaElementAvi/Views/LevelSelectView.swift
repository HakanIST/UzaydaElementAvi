//
//  LevelSelectView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette

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

                Text("Bölüm Seç")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Text("Her bölümün sonunda boss savaşı!")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 4)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(LevelConfig.all, id: \.id) { cfg in
                            levelCard(cfg: cfg)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
        }
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func levelCard(cfg: LevelConfig) -> some View {
        let locked = cfg.id > game.unlockedLevel
        let stars = game.starsFor(level: cfg.id)
        let baseColor = Color(hex: cfg.accentHex)

        Button {
            if !locked { game.pickLevel(cfg.id) }
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

                HStack(spacing: 14) {
                    // Level number badge
                    ZStack {
                        Circle()
                            .fill(locked ? Color.white.opacity(0.05) : baseColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        if locked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.3))
                        } else {
                            Text("\(cfg.id)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(baseColor)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(locked ? "🔒 KİLİTLİ" : cfg.name.uppercased())
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(cfg.subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))

                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { i in
                                Image(systemName: i < stars ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundColor(i < stars ? Color(hex: 0xFFD84D) : .white.opacity(0.18))
                            }
                            Spacer()
                            // Boss indicator
                            Text(cfg.boss.emoji)
                                .font(.system(size: 16))
                                .opacity(locked ? 0.3 : 0.7)
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(locked ? Color.white.opacity(0.08) : baseColor.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: locked ? .clear : baseColor.opacity(0.2), radius: 12)
            .opacity(locked ? 0.5 : 1)
        }
        .buttonStyle(PressDownStyle())
        .disabled(locked)
    }
}

#Preview {
    LevelSelectView().environmentObject(GameViewModel())
}
