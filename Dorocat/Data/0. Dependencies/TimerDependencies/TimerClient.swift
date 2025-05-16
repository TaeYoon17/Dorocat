//
//  TimerClient.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import Combine
final class TimerClient: TimerProtocol {
    
    static let shared = TimerClient()
    var background: TimeBackgroundClient = .init()
    
    private let defaultsService = UserDefaultsService()
    private init(){ }
    
    func tickEventStream() -> AsyncStream<()> {
        return .init { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            let cancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink(receiveValue: { _ in
                continuation.yield()
            })
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    func setTimerSettingEntity(_ entity: TimerSettingEntity) async {
        defaultsService.saveData(value: entity, key: .settingEntity)
    }
    
    func getTimerSettingEntity() async -> TimerSettingEntity {
        let result = defaultsService.loadData(type: TimerSettingEntity.self, key: .settingEntity)
        switch result {
        case .success(let entity): return entity
        case .failure: return TimerSettingEntity()
        }
    }
    
    func setTimerProgressEntity(_ entity: TimerProgressEntity) async {
        defaultsService.saveData(value: entity, key: .progressEntity)
    }
    
    func getTimerProgressEntity() async -> TimerProgressEntity {
        let result = defaultsService.loadData(type: TimerProgressEntity.self, key: .progressEntity)
        switch result {
        case .success(let entity): return entity
        case .failure: return TimerProgressEntity()
        }
    }
}
