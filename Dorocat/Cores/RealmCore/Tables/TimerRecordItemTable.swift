//
//  ShoppingList.swift
//  Dorocat
//
//  Created by Developer on 3/18/24.
//

import Foundation
import RealmSwift
final class TimerRecordItemTable: Object,Identifiable{
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var createdAt: Date = Date()
    @Persisted var recordCode:String = ""
    @Persisted var duration:Int = 0
    @Persisted var sessionKey: String
    convenience init(createdAt: Date,duration:Int,sessionKey: String) {
        self.init()
        self.duration = duration
        self.recordCode = createdAt.convertToRecordCode()
        self.createdAt = createdAt
        self.sessionKey = sessionKey
    }
}

extension Date{
    func convertToRecordCode()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
extension TimerRecordItemTable{
    func convertToItem(_ sessionItem:SessionItem) -> TimerRecordItem{
        TimerRecordItem(id: self.id,
                        recordCode: self.recordCode,
                        createdAt: self.createdAt,
                        duration: self.duration,
                        session: sessionItem
        )
    }
}
extension TimerRecordItemTable{
    var convertItem:TimerRecordItem {
        get async throws{
            let timerSessionRepository = try await TimerSessionRepository()
            let item = SessionItem(name: sessionKey)
            return TimerRecordItem(id: self.id,
                            recordCode: self.recordCode,
                            createdAt: self.createdAt,
                            duration: self.duration,
                            session: SessionItem(name: sessionKey)
                            )
        }
    }
}
