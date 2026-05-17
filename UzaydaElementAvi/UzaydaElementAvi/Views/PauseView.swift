//
//  PauseView.swift
//  UzaydaElementAvi
//

import SwiftUI

struct PauseView: View {
    @EnvironmentObject var game: GameViewModel

    var body: some View {
        let pal = game.palette

        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.058, opacity: 0.7)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Text("SİSTEM DURDURULDU")
                    .font(AppFont.mono(11, weight: .medium))
                    .tracking(4)
                    .foregroundColor(pal.accent)
                Text("Mola")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                NeonButton(title: "► Devam Et", size: .lg,
                           accent: pal.accent, accent2: pal.accent2) {
                    game.resume()
                }
                NeonButton(title: "Ana Menü", size: .sm, variant: .ghost,
                           accent: pal.accent, accent2: pal.accent2) {
                    game.returnToMenu()
                }
            }
        }
    }
}
