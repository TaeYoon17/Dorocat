//
//  HapticService.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation
import UIKit

@MainActor
struct HapticService {
    
    /// 노티피케이션이 발생합니다.
    func notificationOccur(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// 임펙트가 발생합니다.
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }
}
