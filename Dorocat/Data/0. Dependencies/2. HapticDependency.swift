//
//  HapticDependency.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import Foundation
import ComposableArchitecture
import UIKit

protocol HapticDependency {
    var enable:Bool { get async }
    
    func setEnable(_ isEnable:Bool) async
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) async
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) async
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) async
}

fileprivate enum HapticClientKey: DependencyKey {
    static let liveValue: HapticDependency = HapticRepositoryImpl()
}

extension DependencyValues {
    var haptic: HapticDependency {
        get{ self[HapticClientKey.self] }
        set{ self[HapticClientKey.self] = newValue }
    }
}
