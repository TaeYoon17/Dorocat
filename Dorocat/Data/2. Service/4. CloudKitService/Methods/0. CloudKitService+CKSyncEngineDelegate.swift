//
//  SyncedDatabase+CKSyncEngineDelegate.swift
//  Dorocat
//
//  Created by Greem on 4/30/25.
//

import Foundation
import CloudKit
import os.log

extension CloudKitService : CKSyncEngineDelegate {
    
    /// CKSyncEngine에서 이벤트가 발생한 것을 알려준다.
    /// CKSyncEngine.Event는 CloudKit에서 동기화 엔진(CKSyncEngine)이 동작 중에 발생하는 이벤트를 나타내는 열거형(enum)
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        Logger.database.debug("Handling event \(event)")
        /// State는 그 엔진이 현재까지 동기화를 어디까지 했는지, 어떤 레코드들을 처리했는지 등을 기억하는 객체
        /// Serialization은 직렬화하여 CoreData나 로컬에 저장할 수 있게 만듦
        switch event {
        case .stateUpdate(let event): // 상태 업데이트, 저장 공간에 최신 상태가 무엇인지 저장하게 만들 필요가 있다.
            self.stateSerialization = event.stateSerialization
        case .accountChange(let event): // 계정이 바뀜
            self.handleAccountChange(event)
        case .fetchedDatabaseChanges(let event): // 처리할 데이터베이스 변경 사항을 가져왔음. -> 레코드 존의 변경 사항을 알 것이다.
            await self.handleFetchedDatabaseChanges(event)
        case .fetchedRecordZoneChanges(let event): // 레코드 존 내부의 테이블 변화를 가져온다. -> 튜플(레코드)의 추가나 삭제를 알 것이다.
            await self.handleFetchedRecordZoneChanges(event)
        case .sentRecordZoneChanges(let event):
            await self.handleSentRecordZoneChanges(event)
        case .sentDatabaseChanges: break
        case .willSendChanges, .willFetchChanges: // 여기에 동기화 시작 토글링

            for syncHandler in self.syncHandlers.values {
                await syncHandler?.synchronizeStart()
            }
        case .didFetchChanges, .didSendChanges: // 여기에 동기화 끝남 토글링
        // We don't do anything here in the sample app, but these events might be helpful if you need to do any setup/cleanup when sync starts/ends.
            for syncHandler in self.syncHandlers.values {
                await syncHandler?.synchronizeEnd()
            }
        case .willFetchRecordZoneChanges, .didFetchRecordZoneChanges: break
        @unknown default:
            Logger.database.info("Received unknown event: \(event)")
        }
    }

}
