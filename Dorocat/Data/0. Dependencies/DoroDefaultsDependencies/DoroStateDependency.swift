//
//  DoroStateDependency.swift
//  Dorocat
//
//  Created by Greem on 11/9/24.
//

import Foundation
import ComposableArchitecture

protocol DoroDefaults {
    
    func setCatType(_ type: CatType) async
    func getCatType() async -> CatType
    
    func setIsPromode(_ isPromode: Bool) async
    func getIsPromode() async -> Bool
    
    func setTimerSettingEntity(_ entity: TimerSettingEntity) async
    func getTimerSettingEntity() async -> TimerSettingEntity
    
    func setTimerProgressEntity(_ entity: TimerProgressEntity) async
    func getTimerProgressEntity() async -> TimerProgressEntity
    
    func setDoroStateEntity(_ entity: DoroStateEntity) async
    func getDoroStateEntity() async -> DoroStateEntity
    
}


fileprivate enum DoroDefaultsClientKey: DependencyKey{
    static let liveValue: DoroDefaults = DoroDefaultsClient()
}
extension DependencyValues{
    var doroStateDefaults: DoroDefaults{
        get{self[DoroDefaultsClientKey.self]}
        set{self[DoroDefaultsClientKey.self] = newValue}
    }
}
