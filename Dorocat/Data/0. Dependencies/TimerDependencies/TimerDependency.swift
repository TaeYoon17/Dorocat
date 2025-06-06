//
//  TimerDependenc.swift
//  Dorocat
//
//  Created by Developer on 4/19/24.
//

import Foundation
import ComposableArchitecture

protocol TimerProtocol {
    
    var background: TimeBackgroundClient { get } // 앱이 백그라운드 상태에서도 타이머 기능을 작동할 수 있도록 도와주는 인스턴스
    
    func tickEventStream() -> AsyncStream<()> // 1초당 타이머가 시간을 방출하는 스트림
    
    /// 타이머 설정을 변경하는 메서드
    func setTimerSettingEntity(_ entity: TimerSettingEntity) async
    /// 타이머 설정을 가져오는 메서드
    func getTimerSettingEntity() async -> TimerSettingEntity
    
    /// 타이머 진행 상황을 변경하는 메서드
    func setTimerProgressEntity(_ entity: TimerProgressEntity) async
    /// 타이머 진행 상황을 가져오는 메서드
    func getTimerProgressEntity() async -> TimerProgressEntity
}

protocol TimeBackgroundProtocol {
    var date: Date? { get async }
    func set(date:Date) async
    var timerStatus: TimerStatus { get async }
    func set(timerStatus:TimerStatus) async
}

fileprivate enum TimerClientKey: DependencyKey {
    static let liveValue: TimerClient = TimerClient.shared
}

extension DependencyValues {
    var timer: TimerClient {
        get{ self[ TimerClientKey.self ] }
        set{ self[ TimerClientKey.self ] = newValue }
    }
}
