//
//  TimerDependency.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import Foundation
import ComposableArchitecture
import Combine

enum AnalyzeEvent {
    case append
    case fetch
}

protocol CloudSyncAble {
    var lastSyncedDate: Date { get async }
    var isICloudSyncEnabled: Bool { get async }
    var isAutomaticallySyncEnabled: Bool { get async }
    func setICloudAccountState(_ state: Bool) async -> iCloudStatusTypeDTO
    func setAutomaticSync(_ state: Bool) async -> Void
    func refresh() async
    
    func synchronizeEventAsyncStream() async -> AsyncStream<SynchronizeEvent>
    
}

protocol AnalyzeAPIs: CloudSyncAble {
    /// 총 시간을 알아온다.
    var totalFocusTime: Double { get async }
    /// 초기화 한다.
    func initAction() async throws
    
    func get(day:Date) async throws -> [TimerRecordItem]
    func get(weekDate: Date) async throws ->[TimerRecordItem]
    func get(monthDate: Date) async throws -> [TimerRecordItem]
    
    func append(_ item: TimerRecordItem) async
    
    func eventAsyncStream() async -> AsyncStream<AnalyzeEvent>
}

fileprivate enum AnalyzeAPIsClientKey: DependencyKey {
    @DBActor static let liveValue: AnalyzeAPIs = AnalyzeCoreDataClient()
}

extension DependencyValues{
    
    var analyzeAPIClients: AnalyzeAPIs {
        get{ self[AnalyzeAPIsClientKey.self] }
        set{ self[AnalyzeAPIsClientKey.self] = newValue }
    }
    
}

