//
//  TimerItemEntity+CloudKit.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import CloudKit
import os.log
protocol CKWritable {
    var recordType: CKRecord.RecordType { get }
    func populateRecord(_ record: CKRecord)
}

protocol CKReadable {
    var ckRecordZoneID: CKRecordZone.ID { get }
    var ckRecordID: CKRecord.ID { get }
}

extension TimerRecordItem: CKWritable, CKReadable {
    var recordType: CKRecord.RecordType {
        CKRecord.RecordEntityType.timerItem.rawValue
    }
    
    static let zoneName = "DoroTimerZone"
    
    /// The record type to use when saving a contact.
    static let recordType: CKRecord.RecordType = CKRecord.RecordEntityType.timerItem.rawValue
    
    var ckRecordZoneID: CKRecordZone.ID { CKRecordZone.ID(zoneName: Self.zoneName) }
    var ckRecordID: CKRecord.ID {
        CKRecord.ID(recordName: self.id.uuidString, zoneID: self.ckRecordZoneID)
    }
    init(record: CKRecord) {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
//        self.id = values[.id] ?? UUID()
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.recordCode = values[.timerRecordItem_recordCode] ?? ""
        self.createdAt = values[.timerRecordItem_createdAt] ?? Date()
        self.duration = values[.timerRecordItem_duration] ?? 0
        self.session = .init(name:values[.timerRecordItem_sessionName] ?? "Study")
        self.userModificationDate = values[.timerRecordItem_userModificationDate] ?? Date.distantPast
    }
    // 서버에서 가져온 데이터와 동기화시킨다.
    mutating func mergeFromServerRecord(_ record: CKRecord) {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        let userModificationDate: Date = values[.timerRecordItem_userModificationDate] ?? Date.distantPast

        guard userModificationDate > self.userModificationDate else { return }
        /// 클라우드에 있는 시간이 더 최신이다. 변경!
        self.userModificationDate = userModificationDate
        if let recordCode = values[.timerRecordItem_recordCode] as? String {
            self.recordCode = recordCode
        }
        if let createdAt = record.encryptedValues[.timerRecordItem_createdAt] as? Date {
            self.createdAt = createdAt
        }
        if let duration = record.encryptedValues[.timerRecordItem_duration] as? Int {
            self.duration = duration
        }
        if let sessionName = record.encryptedValues[.timerRecordItem_sessionName] as? String {
            self.session = .init(name: sessionName)
        }
    }
    
    /// 레코드에 이 값을 쓴다.
    func populateRecord(_ record: CKRecord) {
        let values: any CKRecordKeyValueSetting = record.encryptedValues
        values[.timerRecordItem_duration] = self.duration
        values[.timerRecordItem_recordCode] = self.recordCode
        values[.timerRecordItem_createdAt] = self.createdAt
        values[.timerRecordItem_sessionName] = self.session.name
        values[.timerRecordItem_userModificationDate] = self.userModificationDate
    }
}


extension TimerRecordItem : Identifiable, Hashable, Equatable, Comparable {
    static func == (lhs: TimerRecordItem, rhs: TimerRecordItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.recordCode == rhs.recordCode &&
        lhs.userModificationDate == rhs.userModificationDate
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.recordCode)
        hasher.combine(self.userModificationDate)
    }
    
    static func < (lhs: TimerRecordItem, rhs: TimerRecordItem) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }

}

extension CKRecord.FieldKey {
    static let timerRecordItem_recordCode: String = "RecordCode"
    static let timerRecordItem_sessionName: String = "SessionName"
    static let timerRecordItem_duration: String = "Duration"
    static let timerRecordItem_createdAt: String = "CreatedAt"
    static let timerRecordItem_userModificationDate: String = "UserModificationDate"
}


/*
extension TimerRecordItem {
    
    /// A CKRecord 타입으로 변형한 `lastKnownRecordData` 변수
    /// 타입 변환이 실패하거나 이전 레코드 값이 없으면 nil 반환
    var lastKnownRecord: CKRecord? {
        get {
            if let data = self.lastKnownRecordData {
                do {
                    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                    unarchiver.requiresSecureCoding = true
                    return CKRecord(coder: unarchiver)
                } catch {
                    // Why would this happen? What could go wrong? 🔥
                    Logger.dataModel.fault("Failed to decode local system fields record: \(error)")
                    return nil
                }
            } else {
                return nil
            }
        }
        
        set {
            if let newValue {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                newValue.encodeSystemFields(with: archiver)
                self.lastKnownRecordData = archiver.encodedData
            } else {
                self.lastKnownRecordData = nil
            }
        }
    }
    
    /// 이 연락처의 `lastKnownRecordData`를 설정합니다.
    /// 단, 다른 레코드가 기존의 마지막으로 알려진 레코드보다 더 최신 버전일 경우에만 설정됩니다.
    mutating func setLastKnownRecordIfNewer(_ otherRecord: CKRecord) {
        let localRecord = self.lastKnownRecord
        if let localDate = localRecord?.modificationDate {
            if let otherDate = otherRecord.modificationDate, localDate < otherDate {
                self.lastKnownRecord = otherRecord
            } else {
                // The other record is older than the one we already have.
            }
        } else {
            self.lastKnownRecord = otherRecord
        }
    }
}
*/
