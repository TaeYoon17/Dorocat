//
//  DoroSession+Snapshot.swift
//  Dorocat
//
//  Created by Developer on 5/11/24.
//
import Foundation

struct DoroSessionSnapshot {
    var allSessions: [SessionItem]
    var defaultSession: SessionItem.ID
    private var essentialSessions:[SessionItem]
    private(set) var appendedSessions:[SessionItem] = []
    private(set) var deletedSessions:[SessionItem] = []
    init(allSessions: [SessionItem],
         defaultSession: SessionItem.ID,
         essentialSessions: [SessionItem]) {
        self.allSessions = allSessions
        self.defaultSession = defaultSession
        self.essentialSessions = essentialSessions
    }
    mutating func add(name: String) throws {
        if contain(name: name){ throw SessionErrorType.addFailed_isExistItem }
        
        let item = SessionItem(name: name)
        allSessions.append(item)
        appendedSessions.append(item)
    }
    mutating func delete(name: String) throws {
        if essentialSessions.contains(where:{$0.name == name}){ throw SessionErrorType.deleteFailed_isEssentialItem }
        allSessions.removeAll(where: {$0.name == name})
        deletedSessions.append(SessionItem(name: name))
    }
    func contain(name: String) -> Bool {
        allSessions.contains(where: {$0.name == name})
    }
}
