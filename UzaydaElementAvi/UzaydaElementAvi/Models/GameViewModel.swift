//
//  GameViewModel.swift
//  UzaydaElementAvi
//
//  Single source of truth: screen routing, persistence, tweaks, game-state.
//

import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    // ── Persistent ────────────────────────────────────────────────
    @AppStorage("uea_unlocked") var unlockedLevel: Int = 1
    @AppStorage("uea_total")    var totalScore: Int = 0
    @AppStorage("uea_suit")     var suitHex: String = "#00F0FF"
    @AppStorage("uea_music")    var musicEnabled: Bool = true

    // Stars stored per level (up to 10)
    @AppStorage("uea_stars_1")  var stars1: Int = 0
    @AppStorage("uea_stars_2")  var stars2: Int = 0
    @AppStorage("uea_stars_3")  var stars3: Int = 0
    @AppStorage("uea_stars_4")  var stars4: Int = 0
    @AppStorage("uea_stars_5")  var stars5: Int = 0
    @AppStorage("uea_stars_6")  var stars6: Int = 0
    @AppStorage("uea_stars_7")  var stars7: Int = 0
    @AppStorage("uea_stars_8")  var stars8: Int = 0
    @AppStorage("uea_stars_9")  var stars9: Int = 0
    @AppStorage("uea_stars_10") var stars10: Int = 0

    static let maxLevel = 10

    // ── Live UI state ─────────────────────────────────────────────
    @Published var tweaks: Tweaks = Tweaks()
    @Published var screen: Screen = .splash
    @Published var level: Int = 1
    @Published var currentPuzzle: PuzzlePayload?
    @Published var lastRunScore: Int = 0
    @Published var lastRunAtoms: Int = 0
    @Published var gameKey: Int = 0

    var palette: Palette { Palette.from(tweaks.palette) }

    // Imperative hook into the running gameplay (set by GameplayView)
    weak var gameRuntime: GameRuntime?

    struct PuzzlePayload: Identifiable, Equatable {
        let id = UUID()
        let doorIdx: Int
        let puzzle: Puzzle
        static func == (lhs: PuzzlePayload, rhs: PuzzlePayload) -> Bool { lhs.id == rhs.id }
    }

    // ── Screen flow ───────────────────────────────────────────────
    func goPlay()              { screen = .levels }
    func openCharacter()       { screen = .character }
    func openScores()          { screen = .scores }
    func returnToMenu()        { screen = .menu; AudioManager.shared.stopMusic() }
    func pause()               { screen = .pause; AudioManager.shared.pauseMusic() }
    func resume()              { screen = .playing; if musicEnabled { AudioManager.shared.resumeMusic() } }

    func pickLevel(_ id: Int) {
        level = id
        gameKey += 1
        screen = .playing
        if musicEnabled { AudioManager.shared.startMusic() }
    }

    func restartLevel() {
        gameKey += 1
        screen = .playing
        if musicEnabled { AudioManager.shared.startMusic() }
    }

    func nextLevel() {
        let next = min(Self.maxLevel, level + 1)
        level = next
        gameKey += 1
        screen = .playing
        if musicEnabled { AudioManager.shared.startMusic() }
    }

    // ── Puzzle handling ───────────────────────────────────────────
    func presentPuzzle(doorIdx: Int) {
        let kind: PuzzleKind
        if doorIdx == 0 {
            kind = Double.random(in: 0..<1) < 0.6 ? .fraction : .multiply
        } else {
            kind = PuzzleKind.allCases.randomElement()!
        }
        currentPuzzle = PuzzlePayload(doorIdx: doorIdx, puzzle: PuzzleGen.make(kind: kind))
    }

    func answerPuzzle(correct: Bool) {
        guard let pp = currentPuzzle else { return }
        if correct {
            gameRuntime?.openDoor(idx: pp.doorIdx)
            Haptics.doorOpen()
            AudioManager.shared.playCorrect()
        } else {
            gameRuntime?.loseLife()
            Haptics.wrong()
            AudioManager.shared.playCrash()
            // If lives exhausted, transition to game over BEFORE dismissing
            // puzzle — prevents the game loop from restarting on the same door.
            if (gameRuntime?.lives ?? 0) <= 0 {
                onGameOver(score: gameRuntime?.score ?? 0)
            }
        }
        currentPuzzle = nil
    }

    // ── Boss fight ────────────────────────────────────────────────
    func startBossFight(score: Int, atoms: Int) {
        lastRunScore = score
        lastRunAtoms = atoms
        screen = .boss
    }

    func onBossDefeated() {
        Haptics.victory()
        let completionBonus = 420 + level * 50
        let bossBonus = LevelConfig.config(for: level).boss.hp * 100
        lastRunScore += completionBonus + bossBonus
        totalScore += lastRunScore

        let stars = lastRunScore > 800 ? 3 : (lastRunScore > 500 ? 2 : 1)
        setStars(level: level, stars: stars)

        if level + 1 > unlockedLevel {
            unlockedLevel = min(Self.maxLevel, level + 1)
        }
        AudioManager.shared.stopMusic()
        screen = .victory
    }

    func onVictory(score: Int, atoms: Int) {
        // Called when player reaches end of world → triggers boss fight
        startBossFight(score: score, atoms: atoms)
    }

    func onGameOver(score: Int) {
        guard screen != .gameOver else { return }
        lastRunScore = score
        AudioManager.shared.stopMusic()
        screen = .gameOver
    }

    // ── Suit handling ─────────────────────────────────────────────
    var suit: Color {
        Color(hexString: suitHex) ?? palette.accent
    }

    func setSuit(hex: String) { suitHex = hex }

    // ── Stars (10 levels) ─────────────────────────────────────────
    func starsFor(level: Int) -> Int {
        switch level {
        case 1: return stars1
        case 2: return stars2
        case 3: return stars3
        case 4: return stars4
        case 5: return stars5
        case 6: return stars6
        case 7: return stars7
        case 8: return stars8
        case 9: return stars9
        case 10: return stars10
        default: return 0
        }
    }

    private func setStars(level: Int, stars: Int) {
        let current = starsFor(level: level)
        let best = max(current, stars)
        switch level {
        case 1: stars1 = best
        case 2: stars2 = best
        case 3: stars3 = best
        case 4: stars4 = best
        case 5: stars5 = best
        case 6: stars6 = best
        case 7: stars7 = best
        case 8: stars8 = best
        case 9: stars9 = best
        case 10: stars10 = best
        default: break
        }
    }
}
