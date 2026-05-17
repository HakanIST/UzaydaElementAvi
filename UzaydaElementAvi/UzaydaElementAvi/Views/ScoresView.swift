//
//  ScoresView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct ScoresView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette

        ZStack {
            RadialGradient(colors: [Color(hex: 0x0D0820), Color(hex: 0x050510)],
                           center: .center, startRadius: 20, endRadius: 600)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { game.returnToMenu() } label: {
                        Text("← Geri")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)

                Text("Skorlar")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 16)

                // Total score
                Text("\(game.totalScore)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(pal.accent)
                    .shadow(color: pal.accent.opacity(0.5), radius: 12)
                    .padding(.top, 8)
                Text("Toplam Puan")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))

                // Levels progress
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(LevelConfig.all, id: \.id) { cfg in
                            let stars = game.starsFor(level: cfg.id)
                            let unlocked = cfg.id <= game.unlockedLevel
                            let color = Color(hex: cfg.accentHex)

                            HStack(spacing: 12) {
                                // Number
                                ZStack {
                                    Circle()
                                        .fill(unlocked ? color.opacity(0.15) : Color.white.opacity(0.05))
                                        .frame(width: 36, height: 36)
                                    Text("\(cfg.id)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(unlocked ? color : .white.opacity(0.3))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cfg.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(unlocked ? .white : .white.opacity(0.3))
                                    HStack(spacing: 3) {
                                        ForEach(0..<3, id: \.self) { i in
                                            Image(systemName: i < stars ? "star.fill" : "star")
                                                .font(.system(size: 11))
                                                .foregroundColor(i < stars ? Color(hex: 0xFFD84D) : .white.opacity(0.15))
                                        }
                                    }
                                }

                                Spacer()

                                // Boss
                                Text(cfg.boss.emoji)
                                    .font(.system(size: 18))
                                    .opacity(unlocked ? 0.8 : 0.2)

                                // Status
                                if stars > 0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: 0xAAFF00))
                                        .font(.system(size: 16))
                                } else if unlocked {
                                    Image(systemName: "play.circle")
                                        .foregroundColor(color)
                                        .font(.system(size: 16))
                                } else {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white.opacity(0.2))
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .padding(.top, 16)
            }
            .padding(.top, 80)
        }
        .foregroundColor(.white)
    }
}
