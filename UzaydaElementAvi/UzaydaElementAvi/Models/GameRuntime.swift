//
//  GameRuntime.swift
//  UzaydaElementAvi
//
//  Mutable runtime state of an in-progress run. Driven by the gameplay view
//  but exposed to the view model so puzzle handlers can poke at it.
//

import SwiftUI
import Combine

@MainActor
final class GameRuntime: ObservableObject {
    // World
    @Published var world: GameWorld
    @Published var worldY: CGFloat = 0
    @Published var playerX: CGFloat = GameConst.width / 2 - GameConst.playerSize / 2
    var targetX: CGFloat = GameConst.width / 2 - GameConst.playerSize / 2
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var atomsCollected: Int = 0

    static let invulnDuration: TimeInterval = 1.2
    @Published var doorsPassed: Int = 0
    @Published var hurt: Bool = false
    var invulnUntil: TimeInterval = 0
    var t: Double = 0

    let level: Int
    init(level: Int) {
        self.level = level
        self.world = generateWorld(level: level)
    }

    func openDoor(idx: Int) {
        guard idx >= 0 && idx < world.doors.count else { return }
        let d = world.doors[idx]
        d.opened = true
        doorsPassed = idx + 1
        score += 300
        worldY = d.y + 90
        invulnUntil = CACurrentMediaTime() + Self.invulnDuration
        objectWillChange.send()
    }

    func loseLife() {
        lives -= 1
        invulnUntil = CACurrentMediaTime() + Self.invulnDuration
    }
}
