//
//  3. UpsertTimerItem.swift
//  Dorocat
//
//  Created by Greem on 5/11/25.
//

import Foundation

extension TimerRecordRepository {
    
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
