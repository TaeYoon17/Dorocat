//
//  TimerRecordRepository.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//

import Foundation
import CoreData

enum SynchronizeEvent {
    case start
    case end
}

@DBActor
final class TimerRecordRepository {
    
    /// 내부 데이터 접근자
    let coreDataService = CoreDataService()
    /// 내부 단순 데이터 접근자
    let defaultsService: UserDefaultsServicing
    /// 외부 데이터베이스 접근자
    private(set) lazy var syncedDatabase: SyncedDatabase = SyncedDatabase()
    
    /// 초기화 되었는지 확인하는 프로퍼티
    var isInit:Bool = false
    
    private(set) var analyzeEventContinuation: AsyncStream<AnalyzeEvent>.Continuation?
    private(set) var syncrhozieEventContiuation: AsyncStream<SynchronizeEvent>.Continuation?
    
    private(set) lazy var analyzeEvent: AsyncStream<AnalyzeEvent> = .init { continuation in
        self.analyzeEventContinuation = continuation
    }
    
    private(set) lazy var synchronizeEvent: AsyncStream<SynchronizeEvent> = .init { continuation in
        syncrhozieEventContiuation = continuation
    }
    
    init(defaultService: UserDefaultsServicing = UserDefaultsService()) {
        self.defaultsService = defaultService
    }
    
}
