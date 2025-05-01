//
//  SyncJobs.swift
//  Dorocat
//
//  Created by Greem on 4/14/25.
//

import Foundation
import CloudKit
import CoreData

protocol SyncHandler {
    
    func handleFetchedRecordZoneChanges(
        type: CKRecord.RecordEntityType,
        modifications: [CKRecord],
        deletions: [CKRecord.ID]
    ) async
    
    func handleFetchedDatabaseChanges(deletionZoneName: Set<String>) async
    
    func overWriteEntities(type: CKRecord.RecordEntityType, records:[CKRecord]) async
    
    /// Pending 상태이던 레코드의 실제 값을 쓰기 위해 CKWritable 값을 요청한다.
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable?
    
}



