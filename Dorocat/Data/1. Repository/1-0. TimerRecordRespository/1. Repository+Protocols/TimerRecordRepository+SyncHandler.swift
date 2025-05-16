//
//  TimerRecordRepository+SyncHandler.swift
//  Dorocat
//
//  Created by Greem on 4/16/25.
//

import Foundation
import CloudKit

typealias ResultAllRecordItems = Result<[TimerRecordItem], Error>

extension TimerRecordRepository: CloudKitServicingHandler {
    
    typealias CKDTO = CKTimerRecordDTO
    
    /// overWriteEntities를 DTO로 통신하기 위해 변경함, 상위로 타입별 행동을 넘긴다
    func applyRemoteToLocal(
        dtos: [CKTimerRecordDTO],
        updateDTOs: inout Set<CKTimerRecordDTO>
    ) async {
        for dto in dtos {
            guard var item = await findItemByID(dto.id) else {
                continue
            }
            do {
                try dto.applyItem(&item)
                await timerItemUpsert(item: item)
            } catch {
                let updatedDTO = CKTimerRecordDTO(item: item)
                updateDTOs.insert(updatedDTO)
            }
        }
    }
    
    /// 실제로 서버에서 받은 값들... 싱크를 DTO로 하기 위함
    func applyFetchedRemoteValueChanges(
        modifications: [CKTimerRecordDTO],
        deletions: [CKTimerRecordDTO.ID]
    ) async {
        var modificationItems:[TimerRecordItem] = []
        var deletionItems: [TimerRecordItem] = []
        
        for modification in modifications {
            if var item = await findItemByID(modification.id) {
                do {
                    try modification.applyItem(&item)
                    modificationItems.append(item)
                } catch(CloudKitError.localIsNewer) {
                    
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } else {
                guard let item = try? modification.convertToItem() else {
                    continue
                }
                modificationItems.append(item)
            }
        }
        
        for deletionId in deletions {
            if let findItem = await findItemByID(deletionId) {
                deletionItems.append(findItem)
            }
        }
        
        for modificationItem in modificationItems {
            await self.timerItemUpsert(item: modificationItem)
        }
        try? await timerItemDeletes(items: deletionItems)
        analyzeEventContinuation?.yield(.fetch)
    }
    
    func synchronizeStart() async {
        self.syncrhozieEventContiuation?.yield(.start)
        Task.detached {
            try await Task.sleep(for: .seconds(10))
            await self.syncrhozieEventContiuation?.yield(.end)
        }
    }
    
    func synchronizeEnd() async {
        self.lastSyncedDate = Date()
        self.syncrhozieEventContiuation?.yield(.end)
    }
    
    func requestCKWritableForPendingRecord(id: String) async -> (any CKWritable)? {
        guard let uuid = UUID(uuidString: id) else {
            assertionFailure("이게 이상해요...")
            return nil
        }
        guard let item = await self.findItemByID(uuid) else {
            return nil
        }
        return CKTimerRecordDTO(item: item)
    }
    
    
    /// 데이터 베이스 자체가 변화함 => 존 (테이블이 영향받음)
    func handleFetchedDatabaseChanges(deletionZoneName: Set<String>) async {
        if deletionZoneName.contains(CKTimerRecordDTO.zoneName) {
            try? await timerRecordDeleteAll()
        }
    }
    
    func handleAccountStatusChange(_ status: UserAccountStatusDTO) async {
        switch status {
        case .signIn: break
        case .signOut: /// 자동 동기화 및 일반 동기화 모두 가능하지 않게 한다.
            self.isAutomaticallySyncEnabled = false
            self.isICloudSyncEnabled = false
        }
    }
}
