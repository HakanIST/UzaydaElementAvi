//
//  World.swift
//  UzaydaElementAvi
//
//  World generation: obstacles, pickups, doors. Mirrors the JSX generator.
//

import Foundation
import CoreGraphics

enum ObstacleType {
    case block(x: CGFloat, w: CGFloat, moves: BlockMovement?)
    case barrier(gapX: CGFloat, gapW: CGFloat, laser: Bool, blink: Double)
}

struct BlockMovement {
    var amp: CGFloat
    var speed: Double
    var phase: Double
}

final class Obstacle: Identifiable {
    let id = UUID()
    var type: ObstacleType
    var y: CGFloat
    var h: CGFloat

    // Scratch (updated by game loop)
    var screenY: CGFloat = 0

    init(type: ObstacleType, y: CGFloat, h: CGFloat) {
        self.type = type
        self.y = y
        self.h = h
    }
}

final class Pickup: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var taken: Bool = false

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

final class Door: Identifiable {
    let id = UUID()
    var y: CGFloat
    var opened: Bool = false

    init(y: CGFloat) {
        self.y = y
    }
}

struct GameWorld {
    var obstacles: [Obstacle]
    var pickups: [Pickup]
    var doors: [Door]
}

// ── Constants ─────────────────────────────────────────────────────
enum GameConst {
    static let width: CGFloat = 390
    static let height: CGFloat = 760
    static let playerSize: CGFloat = 38
    static let playerY: CGFloat = 560
    static let doorYList: [CGFloat] = [700, 1700, 2700]
    static let worldEndY: CGFloat = 2800
}

// ── Seeded PRNG (matches JSX behavior closely) ────────────────────
struct SeededRNG {
    private var s: Double
    init(seed: Double) { self.s = seed * 1000 }
    mutating func next() -> Double {
        s = (s * 9301 + 49297).truncatingRemainder(dividingBy: 233280)
        return s / 233280
    }
}

// ── World generation ──────────────────────────────────────────────
func generateWorld(level: Int, seed: Double = Double.random(in: 0..<1)) -> GameWorld {
    var rng = SeededRNG(seed: seed)
    var obstacles: [Obstacle] = []
    var pickups: [Pickup] = []

    let stepMin = max(40, 130 - level * 8)
    let stepRand = max(20, 90 - level * 8)
    var y: CGFloat = 220

    while y < GameConst.worldEndY - 100 {
        let nearDoor = GameConst.doorYList.contains { abs($0 - y) < 110 }
        if nearDoor { y += 50; continue }

        let r = rng.next()
        if r < 0.42 {
            // Laser/barrier with a gap
            let gapW = 95 + CGFloat(rng.next()) * 25
            let gapX = 18 + CGFloat(rng.next()) * (GameConst.width - gapW - 36)
            let laser = rng.next() < 0.55
            let blinkVal = rng.next() < 0.3 ? (1.2 + rng.next()) : 0
            obstacles.append(Obstacle(
                type: .barrier(gapX: gapX, gapW: gapW, laser: laser, blink: blinkVal),
                y: y, h: 14
            ))
        } else if r < 0.82 {
            let w = 70 + CGFloat(rng.next()) * 110
            let x = CGFloat(rng.next()) * (GameConst.width - w)
            let moves: BlockMovement? = rng.next() < 0.35
                ? BlockMovement(
                    amp: 30 + CGFloat(rng.next()) * 40,
                    speed: 0.6 + rng.next() * 0.8,
                    phase: rng.next() * 6
                  )
                : nil
            obstacles.append(Obstacle(type: .block(x: x, w: w, moves: moves), y: y, h: 26))
        } else {
            // diagonal slash (chevron)
            let cx = 80 + CGFloat(rng.next()) * (GameConst.width - 160)
            obstacles.append(Obstacle(type: .block(x: cx - 90, w: 70, moves: nil), y: y, h: 14))
            obstacles.append(Obstacle(type: .block(x: cx + 20, w: 70, moves: nil), y: y + 18, h: 14))
        }

        if rng.next() < 0.45 {
            pickups.append(Pickup(
                x: 30 + CGFloat(rng.next()) * (GameConst.width - 60),
                y: y + 60
            ))
        }
        y += CGFloat(stepMin) + CGFloat(rng.next()) * CGFloat(stepRand)
    }

    let doors = GameConst.doorYList.map { Door(y: $0) }
    return GameWorld(obstacles: obstacles, pickups: pickups, doors: doors)
}

// ── Collision check ───────────────────────────────────────────────
func obstacleHits(_ o: Obstacle, px: CGFloat, py: CGFloat, t: Double) -> Bool {
    let size = GameConst.playerSize
    switch o.type {
    case .block(let bx, let w, let moves):
        var x = bx
        if let m = moves {
            x += sin(t * m.speed + m.phase) * m.amp
            x = max(0, min(GameConst.width - w, x))
        }
        return px + size > x && px < x + w
            && py + size > o.screenY && py < o.screenY + o.h
    case .barrier(let gapX, let gapW, _, let blink):
        if blink > 0 && sin(t * blink) < -0.3 { return false }
        let inGap = px >= gapX && (px + size) <= (gapX + gapW)
        let yOverlap = py + size > o.screenY && py < o.screenY + o.h
        return yOverlap && !inGap
    }
}
