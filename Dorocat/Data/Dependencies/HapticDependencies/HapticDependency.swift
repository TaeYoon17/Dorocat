//
//  HapticDependency.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import Foundation
import ComposableArchitecture
import UIKit
protocol HapticProtocol{
    @MainActor var enable:Bool{ get }
    @MainActor func notification(type: UINotificationFeedbackGenerator.FeedbackType)
    @MainActor func impact(style: UIImpactFeedbackGenerator.FeedbackStyle,intensity: CGFloat)
    @MainActor func impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    @MainActor func setEnable(_ isEnable:Bool)
}

fileprivate enum HapticClientKey: DependencyKey{
    @MainActor static let liveValue: HapticProtocol = HapticClient.shared
}
extension DependencyValues{
    var haptic: HapticProtocol{
        get{self[HapticClientKey.self]}
        set{self[HapticClientKey.self] = newValue}
    }
}
