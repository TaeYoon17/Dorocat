//
//  3. HandleFetchedDatabaseChanges.swift
//  Dorocat
//
//  Created by Greem on 5/14/25.
//

import Foundation
import CloudKit
import os.log

extension CloudKitService {
    /// 데이터 베이스 자체가 변화함 => 존 (테이블이 영향받음)
    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) async {
        var zoneNames: Set<String> = .init()
        for deletion in event.deletions {
            zoneNames.insert(deletion.zoneID.zoneName)
        }
        
        for (_, val) in syncHandlers {
            await val?.handleFetchedDatabaseChanges(deletionZoneName: zoneNames)
        }
    }
}
