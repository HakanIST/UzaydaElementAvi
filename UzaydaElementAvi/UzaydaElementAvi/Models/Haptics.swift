//
//  Haptics.swift
//  UzaydaElementAvi
//
//  Centralized haptic feedback helper.
//

import UIKit

enum Haptics {
    private static let light   = UIImpactFeedbackGenerator(style: .light)
    private static let medium  = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy   = UIImpactFeedbackGenerator(style: .heavy)
    private static let notify  = UINotificationFeedbackGenerator()

    /// Pickup collected
    static func pickup() { light.impactOccurred() }

    /// Obstacle hit / life lost
    static func hit() { heavy.impactOccurred() }

    /// Door opened (puzzle correct)
    static func doorOpen() { notify.notificationOccurred(.success) }

    /// Puzzle wrong answer
    static func wrong() { notify.notificationOccurred(.error) }

    /// Button tap
    static func tap() { light.impactOccurred(intensity: 0.5) }

    /// Victory
    static func victory() { notify.notificationOccurred(.success) }
}
