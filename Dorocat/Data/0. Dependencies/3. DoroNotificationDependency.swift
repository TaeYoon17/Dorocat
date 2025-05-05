//
//  PomoNotiDependency.swift
//  Dorocat
//
//  Created by Developer on 4/19/24.
//

import ComposableArchitecture
import NotificationDependency


fileprivate enum DoroNotificationClientKey: DependencyKey {
    static let liveValue: DoroNotification = DoroNotificationClient()
}

extension DependencyValues {
    var pomoNotification: DoroNotification {
        get { self[DoroNotificationClientKey.self] }
        set { self[DoroNotificationClientKey.self] = newValue }
    }
}
