//
//  HapticClient.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import UIKit
@MainActor final class HapticClient:HapticProtocol{
    static let shared = HapticClient()
    private(set) var enable:Bool{
        get{ UserDefaults.standard.bool(forKey: "HapticEnabled") }
        set{ UserDefaults.standard.setValue(newValue, forKey: "HapticEnabled") }
    }
    private init(){}
    func setEnable(_ isEnable: Bool) {
        self.enable = isEnable
    }
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard enable else {return}
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impact(style: style, intensity: 1.0)
    }
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle,intensity: CGFloat = 1.0) {
        guard enable else {return}
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }
}
