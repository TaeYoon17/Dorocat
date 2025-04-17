//
//  TimerRecordItem.swift
//  Dorocat
//
//  Created by Developer on 5/14/24.
//

import Foundation
struct TimerRecordItem: Identifiable,Equatable{
    var id: UUID = UUID()
    // 기록 코드, 년월일로 구분해서 중복된 것을 모두 가져온다.
    var recordCode:String = ""
    var createdAt: Date = .init()
    var duration:Int = 0
    var session: SessionItem = .init(name: "")
    init(createdAt: Date, duration: Int,session:SessionItem) {
        self.id = UUID()
        self.recordCode = createdAt.convertToRecordCode()
        self.createdAt = createdAt
        self.duration = duration
        self.session = session
    }
    init(id: UUID, recordCode: String, createdAt: Date, duration: Int,session:SessionItem) {
        self.id = id
        self.recordCode = recordCode
        self.createdAt = createdAt
        self.duration = duration
        self.session = session
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
