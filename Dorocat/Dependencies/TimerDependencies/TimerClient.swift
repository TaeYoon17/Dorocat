//
//  TimerClient.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
import Combine
final class TimerClient:TimerProtocol{
    var background: TimeBackgroundClient = .init()
    static let shared = TimerClient()
    private init(){}
    var settingEntity = TimerSettingEntity()
    var progressEntity = TimerProgressEntity()
    
    func tickEventStream() -> AsyncStream<()> {
        return .init { [weak self] continuation in
            guard let self else{
                print("찾기 실패")
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
    
}
