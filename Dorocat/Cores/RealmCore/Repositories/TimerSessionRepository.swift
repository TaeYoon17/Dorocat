//
//  TimerSessionRepository.swift
//  Dorocat
//
//  Created by Developer on 5/15/24.
//

import Foundation
import RealmSwift
@DBActor final class TimerSessionRepository: TableRepository<TimerSessionTable>{
    private var defaultSession:SessionItem.ID = "Focus"
    private var essentialItemsID:[SessionItem.ID] = ["Focus","Work","Study","Read"]
    override init() async throws {
        
        try await super.init()
    }
    init(defaultSession: String, essentialItemsID: [String]) async throws {
        self.defaultSession = defaultSession
        self.essentialItemsID = essentialItemsID
        try await super.init()
    }
    func setDefaultSession(_ sessionID:SessionItem.ID) async {
        self.defaultSession = sessionID
    }
    func setEssentialItemsID(_ sessionIDs:[SessionItem.ID]) async {
        self.essentialItemsID = sessionIDs
    }
}
@DBActor extension TimerSessionRepository{
    func getAllSessions()-> Results<TimerSessionTable>{
        self.getTasks
    }
    func getEssentialSessions() -> Results<TimerSessionTable>{
        self.getTasks.where { table in
            table.name.in(essentialItemsID)
        }
    }
    func getCustomSessions()-> Results<TimerSessionTable>{
        self.getTasks.where { table in
            !table.name.in(essentialItemsID)
        }
    }
    func getSessions(id:SessionItem.ID) -> TimerSessionTable{
        guard let table = self.getTasks.where({ $0.name == id }).first else {
            return self.getTasks.where({[defaultSession = defaultSession] in
                $0.name == defaultSession
            }).first!
        }
        return table
    }
}
@DBActor extension TimerSessionRepository{
    func append(_ item: TimerSessionTable) async{
        await self.create(item: item)
    }
    func append(items: [TimerSessionTable]) async{
        for item in items{
            await self.create(item: item)
        }
    }
}
@DBActor extension TimerSessionRepository{
    func updateEssentials(sessionItemIDs:[SessionItem.ID],defaultSessionKey:String) async throws{
        await self.setDefaultSession(defaultSessionKey)
        await self.setEssentialItemsID(sessionItemIDs)
        let prevEssentialTables = getEssentialSessions()
        try await realm.asyncWrite {
            for prevEssentialTable in prevEssentialTables{
                realm.delete(prevEssentialTable)
            }
            for newEssentialTable in sessionItemIDs.map({SessionItem(name: $0).convertToTable}){
                realm.add(newEssentialTable,update: .modified)
            }
        }
    }
    func updateCustoms(items updatedItems: [SessionItem]) async throws {
        let updatedTables = updatedItems.map{$0.convertToTable}
        let prevCustomSessionTables = getCustomSessions()
        let deleteTargetSessionTables = prevCustomSessionTables.where { prevCustomSessionTable in
            !prevCustomSessionTable.in(updatedTables)
        }
        let appendTargetSessionTables = prevCustomSessionTables.where { prevCustomSessionTable in
            prevCustomSessionTable.in(updatedTables)
        }
        try await realm.asyncWrite {
            for deleteTargetSessionTable in deleteTargetSessionTables{
                realm.delete(deleteTargetSessionTable)
            }
            for appendTargetSessionTable in appendTargetSessionTables{
                realm.add(appendTargetSessionTable,update: .modified)
            }
        }

    }
}
