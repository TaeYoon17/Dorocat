//
//  CRUD.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation

extension AnalyzeCoreDataClient {
    func findItemByID(_ id: TimerRecordItem.ID) async -> TimerRecordItem? {
        switch await coreDataService.findItemByID(
                id.uuidString,
                type: TimerRecordItem.self,
                entityKey: .timerRecordEntity
        ) {
        case .failure(.invalidEntity):
//            assertionFailure("엔티티를 찾지 못함")
            return nil
        case .failure(.noneFetchResult):
            return nil
        case .success(let value):
            return value
        }
    }
    
    func findAllItems() async -> [TimerRecordItem] {
        switch await coreDataService.findAllItems(
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity
        ) {
        case .success(let value): return value
        case .failure(.invalidEntity):
            assertionFailure("엔티티를 찾지 못함")
            return []
        case .failure(.noneFetchResult):
            return []
        }
    }
    
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
        }
    }
}


extension AnalyzeCoreDataClient {
    
    
    func timerItemDeletes(items: [TimerRecordItem]) async throws {
        switch await coreDataService.deleteItemsById(items.map(\.id.uuidString), entityKey: .timerRecordEntity) {
        case .success(_): break
        case .failure(let error): throw error
        }
    }
    
    /// 모든 타이머 기록 관련 로컬 DB 데이터를 지운다.
    func timerRecordDeleteAll() async throws {
        switch await coreDataService.deleteAllItem(entityKey: .timerRecordEntity) {
        case .success(_): break
        case .failure(let error): throw error
        }
    }
    
    func timerItemUpsert(item: TimerRecordItem) async {
        switch await coreDataService.upsertItem(
            item: item,
            id: item.id.uuidString,
            entityKey: .timerRecordEntity
        ) {
        case .success(_): return
        case .failure(let error):
            assertionFailure(error.rawValue)
            return
        }
    }
}
