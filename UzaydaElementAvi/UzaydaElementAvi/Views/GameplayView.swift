//
//  GameplayView.swift
//  UzaydaElementAvi
//
//  Core game loop: CADisplayLink, drag controls, world rendering,
//  collisions, doors, pickups.
//

import SwiftUI
import UIKit
import QuartzCore

struct GameplayView: View {
    let level: Int
    @EnvironmentObject var game: GameViewModel
    @StateObject private var runtime: GameRuntime
    @State private var lastTick: TimeInterval = CACurrentMediaTime()
    @StateObject private var displayLink = DisplayLinkHolder()
    @State private var dragStart: (localX: CGFloat, playerX: CGFloat)? = nil
    @State private var hurtFlash: Bool = false

    init(level: Int) {
        self.level = level
        _runtime = StateObject(wrappedValue: GameRuntime(level: level))
    }

    var body: some View {
        let pal = game.palette

        GeometryReader { geo in
            let bounds = CGSize(width: GameConst.width, height: GameConst.height)
            let scale = min(geo.size.width / bounds.width, geo.size.height / bounds.height)

            ZStack(alignment: .topLeading) {
                // World canvas (fixed virtual size, then scaled)
                ZStack(alignment: .topLeading) {
                    background(pal: pal)
                    Starfield(scrollY: runtime.worldY, accent2: pal.accent2)
                    obstaclesLayer(pal: pal)
                    pickupsLayer(pal: pal)
                    doorsLayer(pal: pal)

                    // Player
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(colors: [pal.accent2.opacity(0.7), .clear],
                                                  startPoint: .top, endPoint: .bottom))
                            .frame(width: 12, height: 30)
                            .blur(radius: 4)
                            .offset(x: runtime.playerX + GameConst.playerSize/2 - 6,
                                    y: GameConst.playerY + GameConst.playerSize - 4)

                        AlienKidView(accent: pal.accent, accent2: pal.accent2,
                                     hurt: hurtFlash, suit: game.suit,
                                     size: GameConst.playerSize)
                            .offset(x: runtime.playerX, y: GameConst.playerY)
                    }
                    .allowsHitTesting(false)

                    // Swipe hint at start
                    if runtime.worldY < 80 {
                        Text("← PARMAĞINI KAYDIR →")
                            .font(AppFont.mono(13))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: bounds.width)
                            .offset(y: 320)
                            .opacity(0.6)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: bounds.width, height: bounds.height, alignment: .topLeading)
                .clipped()
                .scaleEffect(scale, anchor: .topLeading)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            let localX = (v.location.x - (geo.size.width - bounds.width*scale)/2) / scale
                            if dragStart == nil {
                                dragStart = (localX: localX, playerX: runtime.playerX)
                            } else {
                                let dx = localX - dragStart!.localX
                                let next = dragStart!.playerX + dx
                                runtime.targetX = max(0, min(GameConst.width - GameConst.playerSize, next))
                            }
                        }
                        .onEnded { _ in dragStart = nil }
                )

                // HUD layer (not scaled — uses real screen)
                HUDView(score: runtime.score, lives: runtime.lives,
                        doorsPassed: runtime.doorsPassed, level: level,
                        accent: pal.accent, accent2: pal.accent2,
                        progress: min(1, runtime.worldY / GameConst.worldEndY),
                        onPause: { game.pause() })
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Tie runtime to view model
            game.gameRuntime = runtime
            startLoop()
        }
        .onDisappear {
            displayLink.stop()
        }
        .onChange(of: game.gameKey) { _ in
            // Caller forces a reset by remounting via .id(gameKey); body is recomputed.
        }
        .onChange(of: game.screen) { newValue in
            // Pause loop when not playing
            if newValue == .pause || newValue == .victory || newValue == .gameOver {
                displayLink.stop()
            } else if newValue == .playing && game.currentPuzzle == nil {
                startLoop()
            }
        }
        .onChange(of: game.currentPuzzle?.id) { newValue in
            if newValue == nil && game.screen == .playing {
                startLoop()
            } else {
                displayLink.stop()
            }
        }
        .onChange(of: runtime.lives) { _ in
            hurtFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { hurtFlash = false }
            if runtime.lives <= 0 { game.onGameOver(score: runtime.score) }
        }
    }

    // MARK: - Loop
    private func startLoop() {
        lastTick = CACurrentMediaTime()
        displayLink.start { now in
            let dt = min(0.05, now - lastTick)
            lastTick = now
            step(dt: dt, now: now)
        }
    }

    private func step(dt: Double, now: TimeInterval) {
        let speedMul = game.tweaks.speed
        let st = runtime

        st.t += dt
        // Smooth follow
        st.playerX += (st.targetX - st.playerX) * CGFloat(min(1, dt * 18))

        let baseSpeed = 130 + CGFloat(level) * 28
        let speed = baseSpeed * CGFloat(speedMul)

        // Doors
        if let nextDoor = st.world.doors.first(where: { !$0.opened }) {
            let distance = nextDoor.y - st.worldY
            if distance < 80 && distance > -10 {
                // Snap and present puzzle
                st.worldY = nextDoor.y
                let idx = st.world.doors.firstIndex(where: { $0 === nextDoor }) ?? 0
                game.presentPuzzle(doorIdx: idx)
                displayLink.stop()
                return
            } else {
                st.worldY += speed * CGFloat(dt)
            }
        } else {
            st.worldY += speed * CGFloat(dt)
            if st.worldY >= GameConst.worldEndY {
                game.onVictory(score: st.score, atoms: st.atomsCollected)
                displayLink.stop()
                return
            }
        }

        // Update screenY and check collisions
        let invulnNow = now < st.invulnUntil
        for o in st.world.obstacles {
            o.screenY = GameConst.playerY - (o.y - st.worldY)
        }
        if !invulnNow {
            for o in st.world.obstacles {
                if o.screenY > GameConst.height + 50 || o.screenY < -50 { continue }
                if obstacleHits(o, px: st.playerX, py: GameConst.playerY, t: st.t) {
                    st.lives -= 1
                    st.invulnUntil = now + GameRuntime.invulnDuration
                    Haptics.hit()
                    AudioManager.shared.playCrash()
                    // onChange(of: runtime.lives) handles game-over routing
                    if st.lives <= 0 {
                        displayLink.stop()
                        return
                    }
                    break
                }
            }
        }

        // Pickups
        for p in st.world.pickups where !p.taken {
            let sy = GameConst.playerY - (p.y - st.worldY)
            if sy < -20 || sy > GameConst.height + 20 { continue }
            let dx = (st.playerX + GameConst.playerSize/2) - p.x
            let dy = GameConst.playerY + GameConst.playerSize/2 - sy
            if dx*dx + dy*dy < 28*28 {
                p.taken = true
                st.score += 50
                st.atomsCollected += 1
                Haptics.pickup()
            }
        }

        st.objectWillChange.send()
    }

    // MARK: - Layers
    private func background(pal: Palette) -> some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0x0C0A1F), Color(hex: 0x050510), Color(hex: 0x020205)],
                           center: UnitPoint(x: 0.5, y: 0.3),
                           startRadius: 20, endRadius: 600)

            // Scrolling grid
            GameGrid(offsetY: -(runtime.worldY * 0.6).truncatingRemainder(dividingBy: 40),
                     accent: pal.accent)
                .opacity(0.5)
        }
        .frame(width: GameConst.width, height: GameConst.height)
    }

    @ViewBuilder
    private func obstaclesLayer(pal: Palette) -> some View {
        ForEach(runtime.world.obstacles) { o in
            ObstacleNode(obstacle: o, t: runtime.t, accent: pal.accent, accent2: pal.accent2)
        }
    }

    @ViewBuilder
    private func pickupsLayer(pal: Palette) -> some View {
        ForEach(runtime.world.pickups) { p in
            if !p.taken {
                let screenY = GameConst.playerY - (p.y - runtime.worldY)
                if screenY > -30 && screenY < GameConst.height + 30 {
                    PickupNode(accent2: pal.accent2)
                        .offset(x: p.x - 9, y: screenY - 9)
                }
            }
        }
    }

    @ViewBuilder
    private func doorsLayer(pal: Palette) -> some View {
        ForEach(Array(runtime.world.doors.enumerated()), id: \.element.id) { idx, d in
            let screenY = GameConst.playerY - (d.y - runtime.worldY)
            if screenY > -100 && screenY < GameConst.height + 100 {
                DoorNode(doorIndex: idx, opened: d.opened,
                         accent: pal.accent, accent2: pal.accent2)
                    .offset(x: 0, y: screenY - 50)
            }
        }
    }
}

// MARK: - DisplayLink wrapper
final class DisplayLinkHolder: ObservableObject {
    private var link: CADisplayLink?
    private var handler: ((TimeInterval) -> Void)?

    deinit { stop() }

    func start(_ tick: @escaping (TimeInterval) -> Void) {
        stop()
        handler = tick
        link = CADisplayLink(target: ProxyTarget(self), selector: #selector(ProxyTarget.tick(_:)))
        link?.add(to: .main, forMode: .common)
    }
    func stop() {
        link?.invalidate()
        link = nil
    }
    func fire(_ time: TimeInterval) { handler?(time) }
}
private final class ProxyTarget {
    weak var holder: DisplayLinkHolder?
    init(_ h: DisplayLinkHolder) { holder = h }
    @objc func tick(_ link: CADisplayLink) { holder?.fire(link.timestamp) }
}

// MARK: - HUD
struct HUDView: View {
    let score: Int
    let lives: Int
    let doorsPassed: Int
    let level: Int
    let accent: Color
    let accent2: Color
    let progress: CGFloat
    let onPause: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                Button(action: onPause) {
                    HStack(spacing: 3) {
                        Capsule().fill(.white).frame(width: 3, height: 14)
                        Capsule().fill(.white).frame(width: 3, height: 14)
                    }
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.14)))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SEKTÖR \(level) · KAPI \(doorsPassed)/3")
                        .font(AppFont.mono(10, weight: .medium))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.55))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [accent, accent2],
                                                      startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(0, geo.size.width * progress), height: 4)
                                .shadow(color: accent, radius: 4)
                        }
                    }
                    .frame(height: 4)
                }

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%04d", score))
                        .font(AppFont.mono(18, weight: .bold))
                        .foregroundColor(.white)
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < lives ? Color(hex: 0xFF3B6B) : Color.white.opacity(0.12))
                                .frame(width: 8, height: 8)
                                .shadow(color: i < lives ? Color(hex: 0xFF3B6B) : .clear, radius: 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 54)
            .padding(.bottom, 8)
            .background(
                LinearGradient(colors: [Color(red: 0.027, green: 0.027, blue: 0.05, opacity: 0.85),
                                        .clear],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )

            Spacer()
        }
    }
}

// MARK: - Grid
private struct GameGrid: View {
    let offsetY: CGFloat
    let accent: Color

    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 40
            var x: CGFloat = 0
            while x < size.width {
                ctx.stroke(Path { p in
                    p.move(to: .init(x: x, y: 0))
                    p.addLine(to: .init(x: x, y: size.height))
                }, with: .color(accent.opacity(0.05)), lineWidth: 1)
                x += step
            }
            var y: CGFloat = offsetY
            while y < size.height {
                ctx.stroke(Path { p in
                    p.move(to: .init(x: 0, y: y))
                    p.addLine(to: .init(x: size.width, y: y))
                }, with: .color(accent.opacity(0.06)), lineWidth: 1)
                y += step
            }
        }
    }
}

// MARK: - Starfield using scrollY
private struct Starfield: View {
    let scrollY: CGFloat
    let accent2: Color
    @State private var stars: [(x: CGFloat, y: CGFloat, s: CGFloat, a: Double, isAccent: Bool)] = {
        (0..<60).map { _ in
            (x: CGFloat.random(in: 0..<GameConst.width),
             y: CGFloat.random(in: 0..<4000),
             s: 0.6 + CGFloat.random(in: 0..<1.4),
             a: 0.3 + Double.random(in: 0..<0.7),
             isAccent: Double.random(in: 0..<1) < 0.1)
        }
    }()

    var body: some View {
        Canvas { ctx, _ in
            for st in stars {
                let y = ((st.y + scrollY * 0.3).truncatingRemainder(dividingBy: GameConst.height + 100)) - 50
                let rect = CGRect(x: st.x, y: y, width: st.s, height: st.s)
                let c = (st.isAccent ? accent2 : Color.white).opacity(st.a)
                ctx.fill(Path(ellipseIn: rect), with: .color(c))
            }
        }
        .frame(width: GameConst.width, height: GameConst.height)
        .allowsHitTesting(false)
    }
}

// MARK: - Obstacle node
private struct ObstacleNode: View {
    let obstacle: Obstacle
    let t: Double
    let accent: Color
    let accent2: Color

    var body: some View {
        switch obstacle.type {
        case .block(let x, let w, let moves):
            let bx: CGFloat = {
                if let m = moves {
                    let drift = sin(t * m.speed + m.phase) * m.amp
                    return max(0, min(GameConst.width - w, x + drift))
                }
                return x
            }()
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(colors: [accent2.opacity(0.5), accent2.opacity(0.25)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(accent2, lineWidth: 1))
                .frame(width: w, height: obstacle.h)
                .shadow(color: accent2.opacity(0.5), radius: 8)
                .offset(x: bx, y: obstacle.screenY)

        case .barrier(let gapX, let gapW, let laser, let blink):
            let blinkOff = blink > 0 && sin(t * blink) < -0.3
            let c: Color = laser ? Color(hex: 0xFF3B6B) : accent
            ZStack(alignment: .topLeading) {
                if blinkOff {
                    Rectangle().fill(.clear)
                        .frame(width: GameConst.width, height: obstacle.h)
                        .overlay(
                            VStack(spacing: 0) {
                                Rectangle().fill(.clear).frame(height: 1)
                                    .border(accent.opacity(0.25), width: 1)
                            }
                        )
                } else {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(LinearGradient(colors: [c.opacity(0.2), c],
                                                  startPoint: .leading, endPoint: .trailing))
                            .frame(width: gapX, height: obstacle.h)
                            .shadow(color: c, radius: 10)
                        Spacer().frame(width: gapW)
                        Rectangle()
                            .fill(LinearGradient(colors: [c.opacity(0.2), c],
                                                  startPoint: .trailing, endPoint: .leading))
                            .frame(maxWidth: .infinity)
                            .frame(height: obstacle.h)
                            .shadow(color: c, radius: 10)
                    }
                    .frame(width: GameConst.width, height: obstacle.h)
                }
            }
            .frame(width: GameConst.width, height: obstacle.h)
            .offset(x: 0, y: obstacle.screenY)
        }
    }
}

// MARK: - Pickup node
private struct PickupNode: View {
    let accent2: Color
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: [Color(hex: 0xAAFF00), accent2.opacity(0.5)],
                                  center: .center, startRadius: 2, endRadius: 12))
            .frame(width: 18, height: 18)
            .shadow(color: Color(hex: 0xAAFF00), radius: 8)
            .scaleEffect(pulse ? 1.25 : 1.0)
            .opacity(pulse ? 0.75 : 1.0)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

// MARK: - Door node
private struct DoorNode: View {
    let doorIndex: Int
    let opened: Bool
    let accent: Color
    let accent2: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(opened ? AnyShapeStyle(Color.clear)
                       : AnyShapeStyle(LinearGradient(colors: [accent.opacity(0.12), accent2.opacity(0.06)],
                                         startPoint: .top, endPoint: .bottom)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent, lineWidth: 2))
                .shadow(color: accent.opacity(0.6), radius: 14)
                .padding(.horizontal, 12)

            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(opened
                          ? LinearGradient(colors: [accent, .clear], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [accent2.opacity(0.8), accent2.opacity(0.4)],
                                            startPoint: .leading, endPoint: .trailing))
                    .frame(width: opened ? 8 : 138)
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .fill(opened
                          ? LinearGradient(colors: [accent, .clear], startPoint: .trailing, endPoint: .leading)
                          : LinearGradient(colors: [accent2.opacity(0.8), accent2.opacity(0.4)],
                                            startPoint: .trailing, endPoint: .leading))
                    .frame(width: opened ? 8 : 138)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: opened)

            Text(opened ? "✓ AÇIK" : "KAPI \(doorIndex + 1)")
                .font(AppFont.mono(10, weight: .bold))
                .tracking(2)
                .foregroundColor(opened ? accent : .white)
                .shadow(color: accent, radius: 6)
        }
        .frame(width: GameConst.width, height: 80)
    }
}
