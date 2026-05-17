//
//  AlienKidView.swift
//  UzaydaElementAvi
//
//  Vector astronaut character. Pure SwiftUI, no assets.
//

import SwiftUI

struct AlienKidView: View {
    let accent: Color
    let accent2: Color
    var hurt: Bool = false
    var suit: Color? = nil
    var size: CGFloat = 38

    @State private var blink = false

    var body: some View {
        let suitColor = suit ?? accent
        let baseFilter = hurt ? Color(hex: 0xFF3B3B) : accent

        Canvas { ctx, canvasSize in
            let s = canvasSize.width / 38.0
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            // Body / suit (ellipse)
            let bodyRect = CGRect(x: (19-11)*s, y: (27-9)*s, width: 22*s, height: 18*s)
            ctx.fill(Path(ellipseIn: bodyRect), with: .color(suitColor.opacity(0.95)))
            ctx.stroke(Path(ellipseIn: bodyRect),
                       with: .color(.white.opacity(0.5)), lineWidth: 0.6*s)

            // Helmet glass
            let helmRect = CGRect(x: (19-10)*s, y: (15-10)*s, width: 20*s, height: 20*s)
            ctx.fill(Path(ellipseIn: helmRect), with: .color(.white.opacity(0.08)))
            ctx.stroke(Path(ellipseIn: helmRect),
                       with: .color(accent2), lineWidth: 1.2*s)

            // Alien head
            let headRect = CGRect(x: (19-6)*s, y: (16-7)*s, width: 12*s, height: 14*s)
            ctx.fill(Path(ellipseIn: headRect),
                     with: .color(hurt ? Color(hex: 0xFFB3B3) : Color(hex: 0xA6F8C5)))

            // Eyes
            let eL = CGRect(x: (16.4-1.4)*s, y: (16-2)*s, width: 2.8*s, height: 4*s)
            let eR = CGRect(x: (21.6-1.4)*s, y: (16-2)*s, width: 2.8*s, height: 4*s)
            ctx.fill(Path(ellipseIn: eL), with: .color(Color(hex: 0x0B0B14)))
            ctx.fill(Path(ellipseIn: eR), with: .color(Color(hex: 0x0B0B14)))
            ctx.fill(Path(ellipseIn: CGRect(x: (16.7-0.4)*s, y: (15.3-0.4)*s, width: 0.8*s, height: 0.8*s)),
                     with: .color(.white))
            ctx.fill(Path(ellipseIn: CGRect(x: (21.9-0.4)*s, y: (15.3-0.4)*s, width: 0.8*s, height: 0.8*s)),
                     with: .color(.white))

            // Helmet shine
            var shine = Path()
            shine.move(to: p(12, 10))
            shine.addQuadCurve(to: p(17, 8), control: p(14, 8))
            ctx.stroke(shine, with: .color(.white.opacity(0.7)), lineWidth: 0.8*s)

            // Antenna
            var ant = Path()
            ant.move(to: p(19, 5))
            ant.addLine(to: p(19, 2.5))
            ctx.stroke(ant, with: .color(accent2), lineWidth: 0.8*s)
            ctx.fill(Path(ellipseIn: CGRect(x: (19-1.2)*s, y: (2-1.2)*s, width: 2.4*s, height: 2.4*s)),
                     with: .color(accent2.opacity(blink ? 0.4 : 1.0)))
        }
        .frame(width: size, height: size)
        .shadow(color: baseFilter.opacity(0.66), radius: 8, x: 0, y: 0)
        .shadow(color: baseFilter.opacity(0.33), radius: 14, x: 0, y: 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                blink.toggle()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AlienKidView(accent: Color(hex: 0x00F0FF), accent2: Color(hex: 0xFF2BD6), size: 140)
    }
}
