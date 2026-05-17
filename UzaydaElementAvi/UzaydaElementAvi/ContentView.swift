//
//  ContentView.swift
//  UzaydaElementAvi
//

import SwiftUI

enum Screen {
    case splash, menu, levels, playing, victory, gameOver, pause, character, scores, boss
}

struct ContentView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        ZStack {
            Color(red: 0.024, green: 0.024, blue: 0.058)
                .ignoresSafeArea()

            // Gameplay stays mounted under modals
            if game.screen == .playing || game.screen == .pause {
                GameplayView(level: game.level)
                    .id(game.gameKey)
                    .transition(.opacity)
            }

            // Active puzzle modal
            if game.currentPuzzle != nil {
                PuzzleView()
                    .transition(.opacity)
                    .zIndex(100)
            }

            // Screen overlays
            switch game.screen {
            case .splash:
                SplashView().transition(.opacity)
            case .menu:
                MainMenuView().transition(.opacity)
            case .levels:
                LevelSelectView().transition(.opacity)
            case .pause:
                PauseView().transition(.opacity).zIndex(90)
            case .victory:
                VictoryView().transition(.opacity)
            case .gameOver:
                GameOverView().transition(.opacity)
            case .character:
                CharacterView().transition(.opacity)
            case .scores:
                ScoresView().transition(.opacity)
            case .boss:
                BossView().transition(.opacity)
            case .playing:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: game.screen)
        .animation(.easeInOut(duration: 0.2), value: game.currentPuzzle?.id)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
