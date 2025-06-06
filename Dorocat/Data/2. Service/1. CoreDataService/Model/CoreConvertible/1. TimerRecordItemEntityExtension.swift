//
//  EntityExtension.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation
import CoreData

extension TimerRecordItemEntity: CoreEntityConvertible {
    
    
    typealias T = TimerRecordItem
    static var dateSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: "createdAt", ascending: false)
    }
    
    func applyItem(_ item: TimerRecordItem) {
        self.id = item.id
        self.duration = Int32(item.duration)
        self.createdAt = item.createdAt
        self.recordCode = item.recordCode
        self.sessionKey = item.session.name
        self.userModificationDate = item.userModificationDate
    }
    
    var convertToItem: TimerRecordItem {
        TimerRecordItem (
            id: self.id!,
            recordCode: self.recordCode!,
            createdAt: self.createdAt!,
            duration: Int(self.duration),
            session: .init(name: self.sessionKey!),
            modificationDate: self.userModificationDate
        )
    }
    
    static func attributes(key: PartialKeyPath<TimerRecordItem>) throws -> String {
        switch key {
        case \.createdAt: return "createdAt"
        case \.recordCode: return "recordCode"
        case \.id: return "id"
        case \.session: return "sessionKey"
        case \.duration: return "duration"
        default: throw NSError(domain: "KeyPath Error", code: 1)
        }
    }
    
}
