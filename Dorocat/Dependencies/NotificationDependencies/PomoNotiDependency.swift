//
//  PomoNotiDependency.swift
//  Dorocat
//
//  Created by Developer on 4/19/24.
//

import ComposableArchitecture
import NotificationDependency

fileprivate enum PomoNotificationClientKey: DependencyKey{
    static let liveValue: PomoNotification = PomoNotificationClient()
}

extension DependencyValues {
    var pomoNotification: PomoNotification {
        get { self[PomoNotificationClientKey.self] }
        set { self[PomoNotificationClientKey.self] = newValue }
    }
}
