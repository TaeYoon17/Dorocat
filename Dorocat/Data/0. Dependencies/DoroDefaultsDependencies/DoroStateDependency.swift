//
//  DoroStateDependency.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation
import ComposableArchitecture

protocol DoroStateDependency {
    func setDoroStateEntity(_ entity: DoroStateEntity) async
    func getDoroStateEntity() async -> DoroStateEntity
}

fileprivate enum DoroDefaultsClientKey: DependencyKey {
    static let liveValue: DoroStateDependency = {
        /// LiveValue 임으로 원래 값을 사용한다.
        @Dependency(\.cat) var cat
        @Dependency(\.timer) var timer
        return DoroStateRepository(cat: cat, timer: timer)
    }()
}

extension DependencyValues {
    var doroStateDefaults: DoroStateDependency {
        get{ self[DoroDefaultsClientKey.self] }
        set{ self[DoroDefaultsClientKey.self] = newValue }
    }
}
