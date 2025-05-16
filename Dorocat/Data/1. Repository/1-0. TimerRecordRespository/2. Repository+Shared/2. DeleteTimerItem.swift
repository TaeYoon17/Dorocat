//
//  DeleteItemShared.swift
//  Dorocat
//
//  Created by Greem on 5/11/25.
//

import Foundation

extension TimerRecordRepository {
    
    /// 아이템 삭제
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
}
