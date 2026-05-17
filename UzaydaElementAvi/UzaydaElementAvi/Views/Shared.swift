//
//  Shared.swift
//  UzaydaElementAvi
//
//  Neon button, ambient background, fonts.
//

import SwiftUI

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
}

enum NeonButtonSize { case lg, sm }
enum NeonButtonVariant { case primary, ghost }

struct NeonButton: View {
    let title: String
    var size: NeonButtonSize = .lg
    var variant: NeonButtonVariant = .primary
    let accent: Color
    let accent2: Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: { action() }) {
            Text(title.uppercased())
                .font(AppFont.display(size == .lg ? 15 : 13, weight: .bold))
                .tracking(1.2)
                .foregroundColor(variant == .primary ? Color(hex: 0x06060E) : accent)
                .padding(.horizontal, size == .lg ? 28 : 20)
                .padding(.vertical, size == .lg ? 14 : 10)
                .background(
                    Group {
                        if variant == .primary {
                            LinearGradient(colors: [accent, accent2],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        } else {
                            Color.white.opacity(0.04)
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(variant == .ghost ? accent.opacity(0.5) : .clear, lineWidth: 1)
                )
                .shadow(color: variant == .primary ? accent.opacity(0.6) : .clear,
                        radius: 16, x: 0, y: 0)
                .shadow(color: variant == .primary ? .black.opacity(0.4) : .clear,
                        radius: 12, x: 0, y: 8)
        }
        .buttonStyle(PressDownStyle())
    }
}

struct PressDownStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct AmbientBackground: View {
    let accent: Color
    let accent2: Color
    @State private var t1 = false
    @State private var t2 = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [accent.opacity(0.25), .clear],
                                     center: .center, startRadius: 5, endRadius: 160))
                .frame(width: 320, height: 320)
                .blur(radius: 20)
                .offset(x: t1 ? 40 : -80, y: t1 ? 30 : -80)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: t1)

            Circle()
                .fill(RadialGradient(colors: [accent2.opacity(0.25), .clear],
                                     center: .center, startRadius: 5, endRadius: 140))
                .frame(width: 280, height: 280)
                .blur(radius: 20)
                .offset(x: t2 ? -40 : 80, y: t2 ? -30 : 110)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: t2)

            GridLines(color: accent.opacity(0.15))
        }
        .allowsHitTesting(false)
        .onAppear { t1 = true; t2 = true }
    }
}

struct GridLines: View {
    let color: Color
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 40
            var x: CGFloat = 0
            while x < size.width { ctx.stroke(Path { p in p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: size.height)) }, with: .color(color), lineWidth: 0.5); x += step }
            var y: CGFloat = 0
            while y < size.height { ctx.stroke(Path { p in p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y)) }, with: .color(color), lineWidth: 0.5); y += step }
        }
        .opacity(0.6)
    }
}

