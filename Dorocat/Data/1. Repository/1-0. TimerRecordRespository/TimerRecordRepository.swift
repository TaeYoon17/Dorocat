//
//  AnalyzeCoreDataClient.swift
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
final class AnalyzeCoreDataClient {
    let coreDataService = CoreDataService()
    let defaultsService = UserDefaultsService()
    lazy var syncedDatabase: SyncedDatabase = SyncedDatabase()
    
    var isInit:Bool = false
    
    private(set) var analyzeEventContinuation: AsyncStream<AnalyzeEvent>.Continuation?
    private(set) var syncrhozieEventContiuation: AsyncStream<SynchronizeEvent>.Continuation?
    
    lazy var analyzeEvent: AsyncStream<AnalyzeEvent> = .init { continuation in
        self.analyzeEventContinuation = continuation
    }
    
    lazy var synchronizeEvent: AsyncStream<SynchronizeEvent> = .init { continuation in
        syncrhozieEventContiuation = continuation
    }
}
