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
    @AppStorage("uea_stars_1")  var starsLevel1: Int = 0
    @AppStorage("uea_stars_2")  var starsLevel2: Int = 0
    @AppStorage("uea_stars_3")  var starsLevel3: Int = 0
    @AppStorage("uea_music")    var musicEnabled: Bool = true

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
    }

    func nextLevel() {
        let next = min(3, level + 1)
        level = next
        gameKey += 1
        screen = .playing
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

    func onVictory(score: Int, atoms: Int) {
        Haptics.victory()
        let completionBonus = 420
        lastRunScore = score + completionBonus
        lastRunAtoms = atoms
        totalScore += lastRunScore
        let stars = lastRunScore > 800 ? 3 : (lastRunScore > 500 ? 2 : 1)
        switch level {
        case 1: starsLevel1 = max(starsLevel1, stars)
        case 2: starsLevel2 = max(starsLevel2, stars)
        case 3: starsLevel3 = max(starsLevel3, stars)
        default: break
        }
        if level + 1 > unlockedLevel { unlockedLevel = min(3, level + 1) }
        AudioManager.shared.stopMusic()
        screen = .victory
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

    func starsFor(level: Int) -> Int {
        switch level {
        case 1: return starsLevel1
        case 2: return starsLevel2
        case 3: return starsLevel3
        default: return 0
        }
    }
}
