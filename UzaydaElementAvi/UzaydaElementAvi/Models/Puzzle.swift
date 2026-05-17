//
//  Puzzle.swift
//  UzaydaElementAvi
//
//  5. sınıf bulmaca üreteçleri.
//

import Foundation

enum PuzzleVisual: Equatable {
    case fraction(num: Int, den: Int)
    case atom(name: String)
    case equation(text: String)
    case shapeSquare(side: Int)
    case shapeRect(a: Int, b: Int)
    case shapeAngle(deg: Int)
    case sequence(items: [String])
    case none
}

enum PuzzleKind: String, CaseIterable {
    case fraction, element, multiply, geometry, sequence, units
}

struct PuzzleOption: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let key: String
}

struct Puzzle: Identifiable, Equatable {
    let id = UUID()
    let kind: PuzzleKind
    let question: String
    let visual: PuzzleVisual
    let options: [PuzzleOption]
    let correctKey: String
    let hint: String
}

enum PuzzleGen {

    static func make(kind: PuzzleKind? = nil) -> Puzzle {
        let k = kind ?? PuzzleKind.allCases.randomElement()!
        switch k {
        case .fraction:  return fraction()
        case .element:   return element()
        case .multiply:  return multiply()
        case .geometry:  return geometry()
        case .sequence:  return sequenceP()
        case .units:     return units()
        }
    }

    // MARK: Fraction
    static func fraction() -> Puzzle {
        let nums = [2,3,1,3]
        let dens = [4,5,3,8]
        var num = nums.randomElement()!
        var den = dens.randomElement()!
        if num >= den { num = max(1, den - 1) }
        let correct = "\(num)/\(den)"

        var wrongs: [String] = []
        var attempts = 0
        while wrongs.count < 3 && attempts < 50 {
            attempts += 1
            let n = Int.random(in: 1...7)
            let d = max(n + 1, Int.random(in: 2...9))
            let f = "\(n)/\(d)"
            if f != correct && !wrongs.contains(f) && n < d { wrongs.append(f) }
        }
        let all = ([correct] + wrongs).shuffled()
        return Puzzle(
            kind: .fraction,
            question: "Boyanmış kısım hangi kesre eşit?",
            visual: .fraction(num: num, den: den),
            options: all.map { PuzzleOption(label: $0, key: $0) },
            correctKey: correct,
            hint: "Boyalı kareleri say, toplam kareye böl."
        )
    }

    // MARK: Element
    static func element() -> Puzzle {
        struct E { let name: String; let formula: String; let distractors: [String] }
        let pool: [E] = [
            E(name: "Su", formula: "H₂O", distractors: ["HO₂","H₃O","OH₂"]),
            E(name: "Karbondioksit", formula: "CO₂", distractors: ["C₂O","CO","C₂O₃"]),
            E(name: "Tuz", formula: "NaCl", distractors: ["NaCl₂","Na₂Cl","NCl"]),
            E(name: "Oksijen gazı", formula: "O₂", distractors: ["O","O₃","O₄"]),
            E(name: "Amonyak", formula: "NH₃", distractors: ["N₃H","NH","N₂H"]),
            E(name: "Metan", formula: "CH₄", distractors: ["CH₂","C₄H","CH₃"]),
        ]
        let it = pool.randomElement()!
        let all = ([it.formula] + it.distractors).shuffled()
        return Puzzle(
            kind: .element,
            question: "\(it.name) bileşiği hangisidir?",
            visual: .atom(name: it.name),
            options: all.map { PuzzleOption(label: $0, key: $0) },
            correctKey: it.formula,
            hint: "Element sembollerini ve atom sayılarını hatırla."
        )
    }

    // MARK: Multiply / divide
    static func multiply() -> Puzzle {
        let a = Int.random(in: 6...17)
        let b = Int.random(in: 4...12)
        let useMul = Bool.random()
        let q: String
        let ans: Int
        if useMul { q = "\(a) × \(b)"; ans = a * b }
        else { ans = a; q = "\(a*b) ÷ \(b)" }

        var set = Set<Int>([ans])
        var attempts = 0
        while set.count < 4 && attempts < 50 {
            attempts += 1
            let delta = (Int.random(in: 0..<14) - 7) * (1 + Int.random(in: 0..<3))
            let cand = ans + delta
            if cand != ans { set.insert(cand) }
        }
        let all = Array(set).shuffled()
        return Puzzle(
            kind: .multiply,
            question: "\(q) = ?",
            visual: .equation(text: q),
            options: all.map { PuzzleOption(label: String($0), key: String($0)) },
            correctKey: String(ans),
            hint: "Adım adım hesapla."
        )
    }

    // MARK: Geometry
    static func geometry() -> Puzzle {
        enum Variant { case square, rect, angle }
        let v: Variant = [.square, .rect, .angle].randomElement()!
        let q: String, ans: Int, unit: String, visual: PuzzleVisual
        switch v {
        case .square:
            let s = Int.random(in: 4...11)
            q = "Kenarı \(s) cm olan karenin alanı?"
            ans = s * s
            unit = "cm²"
            visual = .shapeSquare(side: s)
        case .rect:
            let a = Int.random(in: 3...9)
            let b = a + Int.random(in: 1...6)
            q = "\(a)×\(b) dikdörtgenin alanı?"
            ans = a * b
            unit = "cm²"
            visual = .shapeRect(a: a, b: b)
        case .angle:
            let degs = [30,45,60,90,120,135]
            let d = degs.randomElement()!
            q = "Gösterilen açı kaç derece?"
            ans = d
            unit = "°"
            visual = .shapeAngle(deg: d)
        }

        var set = Set<Int>([ans])
        var attempts = 0
        while set.count < 4 && attempts < 50 {
            attempts += 1
            let delta = (Int.random(in: 0..<8) - 4) * (1 + Int.random(in: 0..<5))
            let d = ans + delta
            if d > 0 { set.insert(d) }
        }
        let all = Array(set).shuffled()
        return Puzzle(
            kind: .geometry,
            question: q,
            visual: visual,
            options: all.map { PuzzleOption(label: "\($0) \(unit)", key: String($0)) },
            correctKey: String(ans),
            hint: "Formülü hatırla: alan = a×b."
        )
    }

    // MARK: Sequence
    static func sequenceP() -> Puzzle {
        if Bool.random() {
            let start = Int.random(in: 2...9)
            let step = Int.random(in: 2...6)
            let seq = [start, start + step, start + 2*step, start + 3*step]
            let ans = start + 4 * step
            var set = Set<Int>([ans])
            var attempts = 0
            while set.count < 4 && attempts < 50 {
                attempts += 1
                set.insert(ans + Int.random(in: -5...5))
            }
            let items = seq.map { String($0) } + ["?"]
            return Puzzle(
                kind: .sequence,
                question: "Sıradaki sayı?",
                visual: .sequence(items: items),
                options: Array(set).shuffled().map { PuzzleOption(label: String($0), key: String($0)) },
                correctKey: String(ans),
                hint: "Sayılar arasındaki farkı bul."
            )
        } else {
            let shapes = ["▲","●","■","◆"]
            let a = shapes.randomElement()!
            var b = shapes.randomElement()!
            while b == a { b = shapes.randomElement()! }
            let pattern = [a, b, a, b, a]
            let ans = b
            var options = [ans]
            for s in shapes where s != ans { options.append(s) }
            let all = Array(options.prefix(4)).shuffled()
            return Puzzle(
                kind: .sequence,
                question: "Sıradaki şekil?",
                visual: .sequence(items: pattern + ["?"]),
                options: all.map { PuzzleOption(label: $0, key: $0) },
                correctKey: ans,
                hint: "Örüntüyü gözle."
            )
        }
    }

    // MARK: Units
    static func units() -> Puzzle {
        enum Case { case cmToM, mToCm, gToKg, kgToG, lToMl }
        let c: Case = [.cmToM, .mToCm, .gToKg, .kgToG, .lToMl].randomElement()!
        let q: String, ansNum: Double, unit: String

        switch c {
        case .cmToM:
            let v = (Int.random(in: 1...9)) * 100
            q = "\(v) cm = ?"
            ansNum = Double(v) / 100
            unit = "m"
        case .mToCm:
            let v = Int.random(in: 1...9)
            q = "\(v) m = ?"
            ansNum = Double(v * 100)
            unit = "cm"
        case .gToKg:
            let v = (Int.random(in: 1...9)) * 1000
            q = "\(v) g = ?"
            ansNum = Double(v) / 1000
            unit = "kg"
        case .kgToG:
            let v = Int.random(in: 1...9)
            q = "\(v) kg = ?"
            ansNum = Double(v * 1000)
            unit = "g"
        case .lToMl:
            let v = Int.random(in: 1...9)
            q = "\(v) L = ?"
            ansNum = Double(v * 1000)
            unit = "mL"
        }

        func fmt(_ d: Double) -> String {
            if d == d.rounded() { return String(Int(d)) }
            return String(d)
        }

        var set = Set<String>([fmt(ansNum)])
        var attempts = 0
        while set.count < 4 && attempts < 50 {
            attempts += 1
            let d = Bool.random() ? ansNum * 10 : ansNum / 10
            if d > 0 && d != ansNum { set.insert(fmt(d)) }
            else { set.insert(fmt(ansNum + Double(Int.random(in: -5...5)))) }
        }
        let all = Array(set).shuffled()
        return Puzzle(
            kind: .units,
            question: "\(q) \(unit)",
            visual: .equation(text: q),
            options: all.map { PuzzleOption(label: "\($0) \(unit)", key: $0) },
            correctKey: fmt(ansNum),
            hint: "1 m = 100 cm, 1 kg = 1000 g."
        )
    }
}
