//
//  UzaydaElementAviApp.swift
//  UzaydaElementAvi
//
//  Uzayda Element Avı — 5. sınıf matematik / fen bulmacalı uzay koşusu
//

import SwiftUI

@main
struct UzaydaElementAviApp: App {
    @StateObject private var game = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
