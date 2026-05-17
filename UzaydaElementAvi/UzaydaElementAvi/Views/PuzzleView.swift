//
//  PuzzleView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct PuzzleView: View {
    @EnvironmentObject var game: GameViewModel
    @State private var picked: String? = nil
    @State private var showHint: Bool = false
    @State private var t: Double = 20
    @State private var resolved: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        let pal = game.palette
        let puzzle = game.currentPuzzle?.puzzle

        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.058, opacity: 0.78)
                .ignoresSafeArea()

            if let puzzle = puzzle {
                content(pal: pal, puzzle: puzzle)
                    .padding(.horizontal, 16)
            }
        }
        .id(game.currentPuzzle?.puzzle.id)
        .onAppear {
            resetState()
        }
        .onChange(of: game.currentPuzzle?.puzzle.id) { _ in
            resetState()
        }
        .onDisappear { timer?.invalidate() }
    }

    private func resetState() {
        picked = nil; showHint = false; resolved = false
        t = game.tweaks.puzzleTime
        timer?.invalidate()
        startTimer()
    }

    @ViewBuilder
    private func content(pal: Palette, puzzle: Puzzle) -> some View {
        let pct = t / game.tweaks.puzzleTime
        let timeColor: Color = pct > 0.5 ? pal.accent
                              : (pct > 0.25 ? Color(hex: 0xFFD84D) : Color(hex: 0xFF3B6B))

        VStack(spacing: 0) {
            // Top stripe
            HStack(spacing: 10) {
                Text("!")
                    .font(AppFont.mono(18, weight: .bold))
                    .foregroundColor(pal.accent)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 10).fill(pal.accent.opacity(0.18)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(pal.accent))

                VStack(alignment: .leading, spacing: 1) {
                    Text("KAPI KİLİDİ · BULMACA")
                        .font(AppFont.mono(9, weight: .medium))
                        .tracking(1.6)
                        .foregroundColor(.white.opacity(0.55))
                    Text("Saniyeler içinde çöz")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(Int(ceil(t)))s")
                    .font(AppFont.mono(18, weight: .bold))
                    .foregroundColor(timeColor)
                    .shadow(color: timeColor, radius: 6)
            }
            .padding(.bottom, 10)

            // Timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(timeColor)
                        .frame(width: max(0, geo.size.width * pct))
                        .shadow(color: timeColor, radius: 4)
                }
            }
            .frame(height: 3)
            .padding(.bottom, 16)

            // Question
            Text(puzzle.question)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(.bottom, 14)

            // Visual
            PuzzleVisualView(visual: puzzle.visual, accent: pal.accent)
                .frame(minHeight: 100)
                .padding(.bottom, 16)

            // Options grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(puzzle.options) { opt in
                    optionButton(opt: opt, puzzle: puzzle, pal: pal)
                }
            }

            // Hint
            footer(puzzle: puzzle, pal: pal)
                .padding(.top, 14)
                .frame(minHeight: 18)
        }
        .padding(18)
        .background(
            LinearGradient(colors: [Color(red: 0.078, green: 0.063, blue: 0.157, opacity: 0.95),
                                    Color(red: 0.031, green: 0.024, blue: 0.078, opacity: 0.95)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(pal.accent.opacity(0.5), lineWidth: 1))
        .shadow(color: pal.accent.opacity(0.25), radius: 24)
        .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 20)
        .frame(maxWidth: 340)
    }

    @ViewBuilder
    private func optionButton(opt: PuzzleOption, puzzle: Puzzle, pal: Palette) -> some View {
        let isPicked = picked == opt.key
        let isCorrect = resolved && opt.key == puzzle.correctKey
        let isWrongPick = resolved && isPicked && !isCorrect

        let bg: Color = isCorrect ? Color(hex: 0xAAFF00).opacity(0.18)
                     : isWrongPick ? Color(hex: 0xFF3B6B).opacity(0.18)
                     : Color.white.opacity(0.05)
        let border: Color = isCorrect ? Color(hex: 0xAAFF00)
                          : isWrongPick ? Color(hex: 0xFF3B6B)
                          : Color.white.opacity(0.12)
        let fg: Color = isCorrect ? Color(hex: 0xAAFF00)
                      : isWrongPick ? Color(hex: 0xFF3B6B)
                      : .white

        Button {
            pick(opt.key, puzzle: puzzle)
        } label: {
            Text(opt.label)
                .font(opt.label.count < 6 ? AppFont.mono(18, weight: .bold)
                                          : .system(size: 18, weight: .bold))
                .foregroundColor(fg)
                .frame(maxWidth: .infinity, minHeight: 52)
                .padding(.vertical, 14).padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 14).fill(bg))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(border, lineWidth: 1))
                .shadow(color: isCorrect ? Color(hex: 0xAAFF00).opacity(0.5)
                          : (isWrongPick ? Color(hex: 0xFF3B6B).opacity(0.5) : .clear),
                        radius: 10)
        }
        .disabled(resolved)
        .buttonStyle(PressDownStyle())
    }

    @ViewBuilder
    private func footer(puzzle: Puzzle, pal: Palette) -> some View {
        Group {
            if resolved {
                if picked == puzzle.correctKey {
                    Text("✓ KAPI AÇILDI")
                        .foregroundColor(Color(hex: 0xAAFF00))
                        .font(.system(size: 14, weight: .bold))
                } else {
                    Text("✗ TEHLİKE — CAN −1")
                        .foregroundColor(Color(hex: 0xFF3B6B))
                        .font(.system(size: 14, weight: .bold))
                }
            } else if showHint && game.tweaks.hints {
                Text(puzzle.hint)
                    .font(.system(size: 12).italic())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else if game.tweaks.hints {
                Button {
                    withAnimation { showHint = true }
                } label: {
                    Text("💡 İpucu")
                        .font(.system(size: 12))
                        .foregroundColor(pal.accent2)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Timer / picking
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !resolved else { return }
                t -= 0.1
                if t <= 0 {
                    t = 0
                    timer?.invalidate()
                    resolved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        game.answerPuzzle(correct: false)
                    }
                }
            }
        }
    }

    private func pick(_ key: String, puzzle: Puzzle) {
        guard !resolved else { return }
        picked = key
        let correct = key == puzzle.correctKey
        resolved = true
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            game.answerPuzzle(correct: correct)
        }
    }
}

// MARK: - Visuals

struct PuzzleVisualView: View {
    let visual: PuzzleVisual
    let accent: Color

    var body: some View {
        switch visual {
        case .fraction(let num, let den):
            FractionGrid(num: num, den: den, accent: accent)
        case .atom(_):
            AtomBadge(accent: accent)
        case .equation(let text):
            Text(text)
                .font(AppFont.mono(36, weight: .bold))
                .foregroundColor(accent)
                .shadow(color: accent, radius: 12)
        case .shapeSquare(let side):
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(accent.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(accent, lineWidth: 2))
                    .frame(width: 90, height: 90)
                    .shadow(color: accent.opacity(0.5), radius: 12)
                Text("\(side) cm")
                    .font(AppFont.mono(13))
                    .foregroundColor(accent)
            }
        case .shapeRect(let a, let b):
            let w = CGFloat(70 + b*4); let h = CGFloat(50 + a*4)
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(accent.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(accent, lineWidth: 2))
                    .frame(width: w, height: h)
                    .shadow(color: accent.opacity(0.5), radius: 12)
                Text("\(a) × \(b) cm")
                    .font(AppFont.mono(13))
                    .foregroundColor(accent)
            }
        case .shapeAngle(let deg):
            AngleVisual(deg: deg, accent: accent)
        case .sequence(let items):
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, it in
                    let isQ = it == "?"
                    Text(it)
                        .font(AppFont.mono(18, weight: .bold))
                        .foregroundColor(isQ ? .white : accent)
                        .frame(width: 40, height: 40)
                        .background(RoundedRectangle(cornerRadius: 8).fill(isQ ? Color.white.opacity(0.06) : accent.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isQ ? Color.white : accent))
                        .shadow(color: isQ ? .clear : accent.opacity(0.4), radius: 4)
                }
            }
        case .none:
            EmptyView()
        }
    }
}

private struct FractionGrid: View {
    let num: Int
    let den: Int
    let accent: Color

    var body: some View {
        let cols = den <= 4 ? den : Int(ceil(sqrt(Double(den))))
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: cols), spacing: 4) {
            ForEach(0..<den, id: \.self) { i in
                RoundedRectangle(cornerRadius: 6)
                    .fill(i < num ? accent : Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(i < num ? accent : Color.white.opacity(0.15), lineWidth: 1))
                    .shadow(color: i < num ? accent.opacity(0.5) : .clear, radius: 6)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .frame(width: 120, height: 120)
    }
}

private struct AtomBadge: View {
    let accent: Color
    @State private var rot: Double = 0

    var body: some View {
        ZStack {
            ForEach([0.0, 60.0, 120.0], id: \.self) { r in
                Ellipse()
                    .stroke(accent.opacity(0.4), lineWidth: 1)
                    .rotationEffect(.degrees(r))
                    .scaleEffect(x: 1, y: 0.4)
            }
            .rotationEffect(.degrees(rot))
            Circle()
                .fill(accent)
                .frame(width: 40, height: 40)
                .shadow(color: accent, radius: 18)
        }
        .frame(width: 110, height: 110)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rot = 360
            }
        }
    }
}

private struct AngleVisual: View {
    let deg: Int
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let origin = CGPoint(x: 10, y: h - 20)
            let rad = Double(-deg) * .pi / 180.0
            let r: CGFloat = 110
            let end = CGPoint(x: origin.x + r * CGFloat(cos(rad)),
                              y: origin.y + r * CGFloat(sin(rad)))

            Path { p in
                p.move(to: origin)
                p.addLine(to: CGPoint(x: w - 10, y: origin.y))
            }
            .stroke(accent, lineWidth: 2)

            Path { p in
                p.move(to: origin)
                p.addLine(to: end)
            }
            .stroke(accent, lineWidth: 2)

            Path { p in
                p.addArc(center: origin, radius: 30,
                         startAngle: .degrees(0),
                         endAngle: .degrees(-Double(deg)),
                         clockwise: true)
            }
            .stroke(accent.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
        }
        .frame(width: 130, height: 100)
    }
}
