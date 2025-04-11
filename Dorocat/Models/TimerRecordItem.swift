//
//  TimerRecordItem.swift
//  Dorocat
//
//  Created by Developer on 5/14/24.
//

import Foundation
struct TimerRecordItem {
    var id: UUID = UUID()
    // 기록 코드, 년월일로 구분해서 중복된 것을 모두 가져온다.
    var recordCode:String = "" // 이게 고유 ID라고 보기는 애매해진다.
    var createdAt: Date = .init()
    var duration:Int = 0
    var session: SessionItem = .init(name: "")
    var userModificationDate: Date = Date.distantPast
    
    /// The encoded `CKRecord` system fields last known to be on the server.
    var lastKnownRecordData: Data?
    
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
