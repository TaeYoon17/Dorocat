//
//  CKTimerRecortDTO.swift
//  Dorocat
//
//  Created by Greem on 5/11/25.
//

import Foundation
import CloudKit
struct CKTimerRecordDTO: CKConvertible {
    
    
    static var zoneName: String { "DoroTimerZone" }
    /// The record type to use when saving a contact.
    static var recordType: CKRecord.RecordType {
        CKConstants.Label.timerItem.rawValue
    }
    
    var recordType: CKRecord.RecordType {
        CKConstants.Label.timerItem.rawValue
    }
    var ckRecordZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: Self.zoneName)
    }
    
    var ckRecordID: CKRecord.ID {
        CKRecord.ID(
            recordName: self.id.uuidString,
            zoneID: self.ckRecordZoneID
        )
    }
    
    typealias Item = TimerRecordItem
    
    let id: UUID
    let createdAt: Date?
    let recordCode: String?
    let duration: Int?
    let session: String?
    let userModificationDate: Date?
    
    init(record: CKRecord) {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        self.id = UUID(uuidString: record.recordID.recordName)!
        self.recordCode = values[.timerRecordItem_recordCode]
        self.createdAt = values[.timerRecordItem_createdAt]
        self.duration = values[.timerRecordItem_duration]
        self.session = values[.timerRecordItem_sessionName]
        self.userModificationDate = values[.timerRecordItem_userModificationDate]
    }
    
    init(item: TimerRecordItem) {
        self.id = item.id
        self.userModificationDate = item.userModificationDate
        self.createdAt = item.createdAt
        self.duration = item.duration
        self.recordCode = item.recordCode
        self.session = item.session.name
    }
    
}

extension CKTimerRecordDTO {
    /// 정해진 Model에 이 값을 쓴다.
    func applyItem(_ item: inout TimerRecordItem) throws {
        
        guard id == item.id else {
            fatalError("아이디가 없으면 카피를 못 하지용")
        }
        
        let cloudModificationDate = self.userModificationDate ?? .now
        if let localModificationDate = item.userModificationDate {
            guard cloudModificationDate > localModificationDate else {
                fatalError("이상해요")
            }
        }
        item.id = self.id
        item.userModificationDate = cloudModificationDate
        if let createdAt {
            item.createdAt = createdAt
        }
        if let duration {
            item.duration = duration
        }
        if let session {
            item.session = .init(name: session)
        }
    }
    
    
    func convertToItem() throws -> TimerRecordItem {
        guard let recordCode, let createdAt, let duration, let session else {
            fatalError("필요한 게 없어요")
        }
        return .init(
            id: self.id,
            recordCode: recordCode,
            createdAt: createdAt,
            duration: duration,
            session: SessionItem(name: session),
            modificationDate: self.userModificationDate
        )
    }
    
    /// 레코드에 이 DTO 값을 쓴다.
    func populateRecord(_ record: CKRecord) {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        values[.timerRecordItem_duration] = self.duration
        values[.timerRecordItem_recordCode] = self.recordCode
        values[.timerRecordItem_createdAt] = self.createdAt
        values[.timerRecordItem_sessionName] = self.session
        values[.timerRecordItem_userModificationDate] = self.userModificationDate
    }
}

extension CKTimerRecordDTO {
    static func == (lhs: CKTimerRecordDTO, rhs: CKTimerRecordDTO) -> Bool {
        lhs.id == rhs.id &&
        lhs.recordCode == rhs.recordCode &&
        lhs.userModificationDate == rhs.userModificationDate
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.recordCode)
        hasher.combine(self.userModificationDate)
    }
    
    static func < (lhs: CKTimerRecordDTO, rhs: CKTimerRecordDTO) -> Bool {
        if let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt {
            return lhsDate < rhsDate
        }
        return false;
    }
}

extension CKRecord.FieldKey {
    static let timerRecordItem_recordCode: String = "RecordCode"
    static let timerRecordItem_sessionName: String = "SessionName"
    static let timerRecordItem_duration: String = "Duration"
    static let timerRecordItem_createdAt: String = "CreatedAt"
    static let timerRecordItem_userModificationDate: String = "UserModificationDate"
}
