//
//  TimerRecordItem.swift
//  Dorocat
//
//  Created by Developer on 5/14/24.
//

import Foundation
struct TimerRecordItem {
    var id: UUID
    // 기록 코드, 년월일로 구분해서 중복된 것을 모두 가져온다.
    
    var recordCode:String = "" // 이게 고유 ID라고 보기는 애매해진다.
    var createdAt: Date = .init()
    var duration:Int = 0
    var session: SessionItem = .init(name: "")
    
    /// 데이터를 변경한 날짜 -> 최신 날짜 기준으로 동기화 할 것
    var userModificationDate: Date? = Date()
    
    
    init(createdAt: Date, duration: Int, session: SessionItem) {
        self.id = UUID()
        self.recordCode = createdAt.convertToRecordCode()
        self.createdAt = createdAt
        self.duration = duration
        self.session = session
        self.userModificationDate = Date()
    }
    
    init(id: UUID, recordCode: String, createdAt: Date, duration: Int, session: SessionItem, modificationDate: Date?) {
        
        self.id = id
        self.recordCode = recordCode
        self.createdAt = createdAt
        self.duration = duration
        self.session = session
        self.userModificationDate = modificationDate
    }
}
