//
//  CRUD.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation

extension TimerRecordRepository {
    
    /// 하나의 아이템을 가져오는 내부 메서드
    func findItemByID(_ id: TimerRecordItem.ID) async -> TimerRecordItem? {
        switch await coreDataService.findItemByID(
                id.uuidString,
                type: TimerRecordItem.self,
                entityKey: .timerRecordEntity
        ) {
        case .failure(.invalidEntity):
            return nil
        case .failure(.noneFetchResult):
            return nil
        case .success(let value):
            return value
        default: return nil
        }
    }
    
    /// 모든 데이터를 가져오는 내부 메서드
    func findAllItems() async -> [TimerRecordItem] {
        switch await coreDataService.findAllItems(
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity
        ) {
        case .success(let value): return value
        case .failure(.invalidEntity):
            assertionFailure("엔티티를 찾지 못함")
            return []
        case .failure(.noneFetchResult): return []
        default: return []
        }
    }
    
    /// ID로 데이터를 가져오는 내부 메서드
    func findItemsByID(_ ids: [TimerRecordItem.ID]) async throws -> [TimerRecordItem] {
        switch await coreDataService.findItemsByIDs(
            ids.map(\.uuidString),
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity
        ) {
        case .success(let value): return value
        case .failure(.invalidEntity):
            assertionFailure("엔티티를 찾지 못함")
            return []
        case .failure(.noneFetchResult): return []
        default: return []
        }
    }
    
    /// 날짜를 가져오는 내부 메서드
    func get(
        predicateFormat: ([String])->String,
        args: CVarArg...
    ) async throws -> [TimerRecordItem] {
        try await coreDataService.findWithCondition(
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity,
            attributes: [\.createdAt],
            args: args,
            predicateFormat: predicateFormat
        ).sorted { $0.createdAt < $1.createdAt }
    }
}



