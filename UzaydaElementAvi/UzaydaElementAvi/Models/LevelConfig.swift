//
//  LevelConfig.swift
//  UzaydaElementAvi
//
//  Level definitions for 10 levels with boss fights.
//

import SwiftUI

struct LevelConfig {
    let id: Int
    let name: String
    let subtitle: String
    let icon: String        // SF Symbol
    let accentHex: UInt32
    let doors: Int          // number of puzzle doors
    let speed: Double       // scroll speed multiplier
    let worldLength: CGFloat // total world Y length
    let boss: BossConfig

    static let all: [LevelConfig] = [
        LevelConfig(
            id: 1, name: "Kozmik Koridor", subtitle: "Toplama & Çıkarma",
            icon: "star.fill", accentHex: 0x00F0FF,
            doors: 2, speed: 1.0, worldLength: 2000,
            boss: BossConfig(name: "Karbon Kral", emoji: "🤖", hp: 3, timePenalty: 0, hideOptions: false)
        ),
        LevelConfig(
            id: 2, name: "Meteor Yağmuru", subtitle: "Çarpma Temelleri",
            icon: "flame.fill", accentHex: 0xFF6B35,
            doors: 2, speed: 1.05, worldLength: 2200,
            boss: BossConfig(name: "Meteor Lordu", emoji: "☄️", hp: 4, timePenalty: 0, hideOptions: false)
        ),
        LevelConfig(
            id: 3, name: "Nebula Geçidi", subtitle: "Bölme & Kesirler",
            icon: "sparkles", accentHex: 0xBB86FC,
            doors: 3, speed: 1.1, worldLength: 2500,
            boss: BossConfig(name: "Nebula Hayaleti", emoji: "👻", hp: 4, timePenalty: 2, hideOptions: false)
        ),
        LevelConfig(
            id: 4, name: "Asteroit Kuşağı", subtitle: "Geometri Başlangıç",
            icon: "circle.hexagongrid.fill", accentHex: 0x00E676,
            doors: 3, speed: 1.15, worldLength: 2800,
            boss: BossConfig(name: "Kaya Devi", emoji: "🗿", hp: 5, timePenalty: 2, hideOptions: false)
        ),
        LevelConfig(
            id: 5, name: "Plazma Hol", subtitle: "Denklemler",
            icon: "bolt.fill", accentHex: 0xFFD600,
            doors: 3, speed: 1.2, worldLength: 3000,
            boss: BossConfig(name: "Plazma Ejderhası", emoji: "🐉", hp: 5, timePenalty: 3, hideOptions: false)
        ),
        LevelConfig(
            id: 6, name: "Karanlık Madde", subtitle: "Sayı Dizileri",
            icon: "moon.stars.fill", accentHex: 0x7C4DFF,
            doors: 4, speed: 1.25, worldLength: 3300,
            boss: BossConfig(name: "Gölge Şövalye", emoji: "🦇", hp: 5, timePenalty: 3, hideOptions: true)
        ),
        LevelConfig(
            id: 7, name: "Güneş Fırtınası", subtitle: "Çarpma İleri",
            icon: "sun.max.fill", accentHex: 0xFF9100,
            doors: 4, speed: 1.3, worldLength: 3500,
            boss: BossConfig(name: "Güneş Komutanı", emoji: "🌞", hp: 6, timePenalty: 3, hideOptions: true)
        ),
        LevelConfig(
            id: 8, name: "Kuasar Labirenti", subtitle: "Karma Problemler",
            icon: "hurricane", accentHex: 0x00BFA5,
            doors: 4, speed: 1.35, worldLength: 3800,
            boss: BossConfig(name: "Kuasar Ustası", emoji: "🛡️", hp: 6, timePenalty: 4, hideOptions: true)
        ),
        LevelConfig(
            id: 9, name: "Kara Delik", subtitle: "Bölme İleri",
            icon: "circle.fill", accentHex: 0xEF5350,
            doors: 5, speed: 1.4, worldLength: 4000,
            boss: BossConfig(name: "Kara Delik Lordu", emoji: "🕳️", hp: 7, timePenalty: 4, hideOptions: true)
        ),
        LevelConfig(
            id: 10, name: "Galaktik Savaş", subtitle: "Tüm Konular",
            icon: "shield.lefthalf.filled", accentHex: 0xFFD700,
            doors: 5, speed: 1.45, worldLength: 4200,
            boss: BossConfig(name: "Galaktik İmparator", emoji: "👑", hp: 8, timePenalty: 5, hideOptions: true)
        ),
    ]

    static func config(for level: Int) -> LevelConfig {
        all.first { $0.id == level } ?? all[0]
    }
}

struct BossConfig {
    let name: String
    let emoji: String
    let hp: Int             // number of correct answers to defeat
    let timePenalty: Double  // seconds removed from timer each round
    let hideOptions: Bool    // boss power: briefly hide answer options
}
