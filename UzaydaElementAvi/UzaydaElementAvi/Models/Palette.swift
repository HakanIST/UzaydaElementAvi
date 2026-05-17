//
//  Palette.swift
//  UzaydaElementAvi
//

import SwiftUI

enum PaletteKey: String, CaseIterable, Identifiable {
    case cyber, matrix, synth, inferno
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cyber:   return "Cyber"
        case .matrix:  return "Matrix"
        case .synth:   return "Synth"
        case .inferno: return "Fire"
        }
    }
}

struct Palette {
    let accent: Color
    let accent2: Color
    let accentHex: String
    let accent2Hex: String

    static func from(_ key: PaletteKey) -> Palette {
        switch key {
        case .cyber:   return Palette(accent: Color(hex: 0x00F0FF), accent2: Color(hex: 0xFF2BD6),
                                       accentHex: "#00F0FF", accent2Hex: "#FF2BD6")
        case .matrix:  return Palette(accent: Color(hex: 0x39FF14), accent2: Color(hex: 0xA875FF),
                                       accentHex: "#39FF14", accent2Hex: "#A875FF")
        case .synth:   return Palette(accent: Color(hex: 0x06D6F0), accent2: Color(hex: 0xB14FFF),
                                       accentHex: "#06D6F0", accent2Hex: "#B14FFF")
        case .inferno: return Palette(accent: Color(hex: 0xFFBE0B), accent2: Color(hex: 0xFF006E),
                                       accentHex: "#FFBE0B", accent2Hex: "#FF006E")
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init?(hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard let v = UInt32(s, radix: 16) else { return nil }
        if s.count == 6 {
            self.init(hex: v)
        } else if s.count == 8 {
            let a = Double((v >> 24) & 0xFF) / 255.0
            let r = Double((v >> 16) & 0xFF) / 255.0
            let g = Double((v >> 8) & 0xFF) / 255.0
            let b = Double(v & 0xFF) / 255.0
            self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        } else {
            return nil
        }
    }

    func toHexString() -> String {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let R = Int((r * 255).rounded()), G = Int((g * 255).rounded()), B = Int((b * 255).rounded())
        return String(format: "#%02X%02X%02X", R, G, B)
        #else
        return "#FFFFFF"
        #endif
    }
}
