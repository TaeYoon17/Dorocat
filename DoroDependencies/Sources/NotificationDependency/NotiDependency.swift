//
//  NotiDependency.swift
//  
//
//  Created by Greem on 9/22/24.
//

import Foundation
import ComposableArchitecture
import UserNotifications

extension NotificationType{
    var notiContent: UNMutableNotificationContent { // 노티피케이션 내용을 담음
        let content = UNMutableNotificationContent()
        switch self{
        case .breakTimeToFocus(let focusTime):
            let min = focusTime == 1 ? "minute" : "minutes"
//            Break time is up! Start your 20-minute focus session when you're ready.
            content.body = "Break time is up! Start your \(focusTime)-\(min) focus session when you're ready."
        case .complete: content.body = "Congrats! Cat had a purrfect nap and is up now"
        case .sessionComplete(let breakTime):
            let min = breakTime == 1 ? "minute" : "minutes"
            content.body = "Focus session just finished. Take a short break for \(breakTime) \(min)!"
        }
        #if os(iOS)
            content.sound = .defaultRingtone
        #endif
        return content
    }
}

public typealias PNType = NotificationType



fileprivate enum PomoNotificationClientKey: DependencyKey {
    static let liveValue: DoroNotification = DoroNotificationClient()
}
 extension DependencyValues{
    var pomoNotification: DoroNotification {
        get{self[PomoNotificationClientKey.self]}
        set{self[PomoNotificationClientKey.self] = newValue}
    }
}
