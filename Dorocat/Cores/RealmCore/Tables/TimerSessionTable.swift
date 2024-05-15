//
//  TimerSessionTable.swift
//  Dorocat
//
//  Created by Developer on 5/14/24.
//

import Foundation
import RealmSwift
final class TimerSessionTable: Object,Identifiable{
    @Persisted(primaryKey: true) var id: String
    @Persisted var name:String = ""
    convenience init(_ name:String) {
        self.init()
        self.id = name
        self.name = name
    }
}

extension TimerSessionTable{
    var convertToItem:SessionItem{
        SessionItem(name: name)
    }
}
extension SessionItem{
    var convertToTable: TimerSessionTable{
        TimerSessionTable(name)
    }
}
