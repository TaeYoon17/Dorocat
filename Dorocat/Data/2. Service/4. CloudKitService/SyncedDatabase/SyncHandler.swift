//
//  SyncJobs.swift
//  Dorocat
//
//  Created by Greem on 4/14/25.
//

import Foundation
import CloudKit
import CoreData

enum UserAccountStatusDTO {
    case signIn
    case signOut
}

protocol SyncHandler {
    
    /// 서버에서 데이터를 가져오는 메서드
    func handleFetchedRecordZoneChanges(
        type: CKRecord.RecordEntityType,
        modifications: [CKRecord],
        deletions: [CKRecord.ID]
    ) async
    
    /// 데이터 베이스 엔티티 자체가 변경됨
    func handleFetchedDatabaseChanges(deletionZoneName: Set<String>) async
    
    /// 덮어쓰기 위한 엔티티
    func overWriteEntities(type: CKRecord.RecordEntityType, records:[CKRecord]) async -> [CKRecord]
    
    /// Pending 상태이던 레코드의 실제 값을 쓰기 위해 CKWritable 값을 요청한다.
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable?
    
    
    /// 동기화 시작
    func synchronizeStart() async
    
    /// 동기화 끝
    func synchronizeEnd() async
    
    /// 유저의 계정 상태 변화 감지
    func handleAccountStatusChange(_ status: UserAccountStatusDTO) async
}



