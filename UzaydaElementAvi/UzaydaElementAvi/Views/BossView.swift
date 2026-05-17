//
//  BossView.swift
//  UzaydaElementAvi
//
//  Boss fight screen — rapid-fire quiz to defeat the level boss.
//

import SwiftUI

struct BossView: View {
    @EnvironmentObject var game: GameViewModel
    @State private var bossHP: Int = 0
    @State private var maxHP: Int = 0
    @State private var playerHP: Int = 3
    @State private var currentQ: Puzzle? = nil
    @State private var picked: String? = nil
    @State private var resolved: Bool = false
    @State private var t: Double = 15
    @State private var timer: Timer? = nil
    @State private var shakeOffset: CGFloat = 0
    @State private var bossScale: CGFloat = 1.0
    @State private var optionsHidden: Bool = false
    @State private var showIntro: Bool = true
    @State private var introScale: CGFloat = 0.3

    private var config: BossConfig { LevelConfig.config(for: game.level).boss }
    private var levelCfg: LevelConfig { LevelConfig.config(for: game.level) }

    var body: some View {
        let pal = game.palette
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.05, green: 0, blue: 0.12),
                         Color(red: 0.15, green: 0, blue: 0.05)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            if showIntro {
                bossIntro(pal: pal)
            } else if let q = currentQ {
                fightUI(pal: pal, puzzle: q)
            }
        }
        .onAppear {
            bossHP = config.hp
            maxHP = config.hp
            playerHP = 3
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                introScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showIntro = false }
                nextQuestion()
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Boss Intro

    @ViewBuilder
    private func bossIntro(pal: Palette) -> some View {
        VStack(spacing: 20) {
            Text("⚠️ BOSS SAVAŞI ⚠️")
                .font(.system(size: 14, weight: .bold))
                .tracking(3)
                .foregroundColor(.red)

            Text(config.emoji)
                .font(.system(size: 100))
                .scaleEffect(introScale)
                .shadow(color: .red, radius: 30)

            Text(config.name)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)

            Text("HP: \(config.hp) | \(config.hp) soru doğru cevapla onu yen!")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Fight UI

    @ViewBuilder
    private func fightUI(pal: Palette, puzzle: Puzzle) -> some View {
        VStack(spacing: 12) {
            // Boss section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    // Boss HP bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1))
                            Capsule()
                                .fill(LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(0, geo.size.width * CGFloat(bossHP) / CGFloat(maxHP)))
                        }
                    }
                    .frame(height: 8)
                    Text("HP \(bossHP)/\(maxHP)")
                        .font(AppFont.mono(11))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)

                Text(config.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(bossScale)
                    .offset(x: shakeOffset)
                    .shadow(color: .red.opacity(0.6), radius: 20)
            }
            .padding(.horizontal)

            Divider().background(Color.red.opacity(0.3))

            // Player HP
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < playerHP ? "heart.fill" : "heart")
                        .foregroundColor(i < playerHP ? .red : .white.opacity(0.2))
                        .font(.system(size: 18))
                }
                Spacer()
                Text("⏱ \(Int(ceil(t)))s")
                    .font(AppFont.mono(16, weight: .bold))
                    .foregroundColor(t > 5 ? .white : .red)
            }
            .padding(.horizontal)

            // Question
            Text(puzzle.question)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)

            // Visual
            PuzzleVisualView(visual: puzzle.visual, accent: Color(hex: levelCfg.accentHex))
                .frame(minHeight: 80)

            // Options
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(puzzle.options) { opt in
                    bossOptionButton(opt: opt, puzzle: puzzle)
                }
            }
            .padding(.horizontal)
            .opacity(optionsHidden ? 0 : 1)
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private func bossOptionButton(opt: PuzzleOption, puzzle: Puzzle) -> some View {
        let isPicked = picked == opt.key
        let isCorrect = resolved && opt.key == puzzle.correctKey
        let isWrongPick = resolved && isPicked && !isCorrect

        let bg: Color = isCorrect ? Color(hex: 0xAAFF00).opacity(0.2)
                     : isWrongPick ? Color(hex: 0xFF3B6B).opacity(0.2)
                     : Color.white.opacity(0.06)
        let border: Color = isCorrect ? Color(hex: 0xAAFF00)
                          : isWrongPick ? Color(hex: 0xFF3B6B)
                          : Color.white.opacity(0.15)
        let fg: Color = isCorrect ? Color(hex: 0xAAFF00)
                      : isWrongPick ? Color(hex: 0xFF3B6B)
                      : .white

        Button {
            pickAnswer(opt.key, puzzle: puzzle)
        } label: {
            Text(opt.label)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(fg)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(RoundedRectangle(cornerRadius: 12).fill(bg))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(border))
        }
        .disabled(resolved)
    }

    // MARK: - Logic

    private func nextQuestion() {
        picked = nil
        resolved = false
        t = max(8, 15 - config.timePenalty)
        currentQ = PuzzleGen.make(kind: PuzzleKind.allCases.randomElement()!)
        timer?.invalidate()
        startTimer()

        // Boss power: hide options briefly
        if config.hideOptions {
            optionsHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { optionsHidden = false }
            }
        }
    }

    private func pickAnswer(_ key: String, puzzle: Puzzle) {
        guard !resolved else { return }
        picked = key
        resolved = true
        timer?.invalidate()

        let correct = key == puzzle.correctKey
        if correct {
            AudioManager.shared.playCorrect()
            Haptics.doorOpen()
            bossHP -= 1

            // Boss hit animation
            withAnimation(.easeInOut(duration: 0.1).repeatCount(5)) {
                shakeOffset = 8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeOffset = 0
            }

            if bossHP <= 0 {
                // Boss defeated!
                withAnimation(.easeIn(duration: 0.5)) { bossScale = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    game.onBossDefeated()
                }
                return
            }
        } else {
            AudioManager.shared.playCrash()
            Haptics.wrong()
            playerHP -= 1

            if playerHP <= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    game.onGameOver(score: game.gameRuntime?.score ?? 0)
                }
                return
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            nextQuestion()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !resolved else { return }
                t -= 0.1
                if t <= 0 {
                    t = 0
                    timer?.invalidate()
                    resolved = true
                    playerHP -= 1
                    AudioManager.shared.playCrash()
                    Haptics.wrong()
                    if playerHP <= 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            game.onGameOver(score: game.gameRuntime?.score ?? 0)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            nextQuestion()
                        }
                    }
                }
            }
        }
    }
}
