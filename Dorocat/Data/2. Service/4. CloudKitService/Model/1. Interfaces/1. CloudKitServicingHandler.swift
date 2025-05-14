//
//  SyncJobs.swift
//  Dorocat
//
//  Created by Greem on 4/14/25.
//

import Foundation
import CloudKit

enum UserAccountStatusDTO {
    case signIn
    case signOut
}

protocol CloudKitServicingHandler {
    associatedtype CKDTO: CKConvertible
    
    /// 데이터 베이스 엔티티 자체가 변경됨
    func handleFetchedDatabaseChanges(deletionZoneName: Set<String>) async
    
    /// 원격에 존재하는 값을 업데이트하기 위해 가져온다.
    func applyRemoteToLocal(
        dtos: [CKDTO],
        updateDTOs: inout Set<CKDTO>
    ) async
    
    /// 원격에서 값이 바뀐 것을 가져온다.
    func applyFetchedRemoteValueChanges(
        modifications: [CKDTO],
        deletions: [CKDTO.ID]
    ) async
    
    /// Pending 상태이던 레코드의 실제 값을 쓰기 위해 CKWritable 값을 요청한다.
    func requestCKWritableForPendingRecord(id: String) async -> CKWritable?
    
    
    /// 동기화 시작
    func synchronizeStart() async
    
    /// 동기화 끝
    func synchronizeEnd() async
    
    /// 유저의 계정 상태 변화 감지
    func handleAccountStatusChange(_ status: UserAccountStatusDTO) async
}



