//
//  DataModel.swift
//  SyncEngine
//

import CloudKit
import os.log

// MARK: - Data


/// An object representing the entire data model of the app.
struct AppData : Codable {
    
    /// All the contacts in the database.
    var contacts: [Contact.ID : Contact] = [:]
    
    /// The last known state we got from the sync engine.
    var stateSerialization: CKSyncEngine.State.Serialization?
}

/// The main model object for the app.
struct Contact {
    
    /// The unique identifier of this contact. Also used as the CloudKit record name.
    var id: String = UUID().uuidString
    
    /// The name of this contact.
    var name: String = "New Contact \(Self.randomEmoji())"
    
    /// The date this contact was last modified in the UI.
    /// Used for conflict resolution.
    /// 이 연락처가 UI에서 마지막으로 수정된 날짜입니다.
    /// 충돌 해결에 사용됩니다.
    var userModificationDate: Date = Date.distantPast
    
    /// The encoded `CKRecord` system fields last known to be on the server.
    /// 서버에 마지막으로 알려진 `CKRecord` 시스템 필드가 인코딩된 값입니다.
    var lastKnownRecordData: Data?
    
    
}

extension Contact : Codable, Identifiable, Hashable, Equatable, Sendable, Comparable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.userModificationDate == rhs.userModificationDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
        hasher.combine(self.userModificationDate)
    }
    
    static func < (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}

extension TimerRecordItem : Identifiable, Hashable, Equatable, Comparable {
    static func == (lhs: TimerRecordItem, rhs: TimerRecordItem) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func < (lhs: TimerRecordItem, rhs: TimerRecordItem) -> Bool {
        return lhs.recordCode.localizedCompare(rhs.recordCode) == .orderedAscending
    }
    static let zoneName = "DoroTimerZone"
    
    /// The record type to use when saving a contact.
    static let recordType: CKRecord.RecordType = "TimerRecordItem"
    
    var zoneID: CKRecordZone.ID { CKRecordZone.ID(zoneName: Self.zoneName) }
    var recordID: CKRecord.ID { CKRecord.ID(recordName: self.recordCode, zoneID: self.zoneID) }
    
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
}

extension TimerRecordItem {
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



// MARK: - CloudKit

extension Contact {
    
    /// The name of the zone used for storing contact records.
    static let zoneName = "Contacts"
    
    /// The record type to use when saving a contact.
    static let recordType: CKRecord.RecordType = "Contact"
    
    /// The zone where this contact record is stored.
    var zoneID: CKRecordZone.ID { CKRecordZone.ID(zoneName: Self.zoneName) }
    
    /// The CloudKit record ID for this contact.
    var recordID: CKRecord.ID { CKRecord.ID(recordName: self.id, zoneID: self.zoneID) }
    
    /// Merges data from a record into this contact.
    /// This handles any conflict resolution if necessary.
    mutating func mergeFromServerRecord(_ record: CKRecord) {
        
        // 충돌 해결은 조금 까다로울 수 있습니다.
        // 예를 들어, 두 대의 기기(DeviceA와 DeviceB)에서 다음과 같은 상황을 상상해보세요:
        //
        // 1. DeviceA는 네트워크에 연결되어 있지 않습니다.
        // 2. DeviceA에서 데이터가 수정됩니다.
        // 3. 몇 시간 후, DeviceB에서도 데이터가 수정됩니다.
        // 4. DeviceB는 변경 사항을 서버에 전송합니다.
        // 5. 이후 DeviceA가 네트워크에 연결되어 자신의 변경 사항을 서버에 전송합니다.
        //
        // 만약 '마지막으로 업로드한 기기가 우선'이라는 정책을 그대로 따른다면,
        // 우리는 DeviceA의 데이터를 선택하게 되는데, 이는 오래된 데이터입니다.
        // 사용자가 실제로 원했던 것은 DeviceB에서 수정한 데이터입니다.
        //
        // 사용자가 실제로 데이터를 수정한 시점을 파악하기 위해,
        // 우리는 사용자의 수정 날짜를 따로 추적합니다.
        // 그리고 그 날짜가 더 최신일 때만 서버의 데이터를 병합하도록 합니다.
        let userModificationDate: Date
        /// 직접 클라우드 데이터 타입에 접근해서 레코드에 저장된 날짜를 가져온다.
        if let dateFromRecord = record.encryptedValues[.contact_userModificationDate] as? Date {
            userModificationDate = dateFromRecord
        } else {
            Logger.dataModel.info("No user modification date in contact record")
            userModificationDate = Date.distantPast
        }
        
        /// 현재 로컬에 저장되어있던 엔티티랑 새로 가져온 클라우드에 있던 엔티티와 시간을 비교한다.
        if userModificationDate > self.userModificationDate {
            /// 클라우드에 있는 시간이 더 최신이다.
            self.userModificationDate = userModificationDate
            
            if let name = record.encryptedValues[.contact_name] as? String {
                self.name = name
            } else {
                Logger.dataModel.info("No name in contact record")
            }
        } else {
            /// 로컬에 있는 시간이 더 최신이다.
            Logger.dataModel.info("Not overwriting data from older contact record")
        }
    }
    
    /// Populates a record with the data for this contact.
    func populateRecord(_ record: CKRecord) {
        record.encryptedValues[.contact_name] = self.name
        record.encryptedValues[.contact_userModificationDate] = self.userModificationDate
    }
    
    /// Sets `lastKnownRecordData` for this contact, but only if the other record is a newer version than the existing last known record.
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
    
    /// A deserialized version of `lastKnownRecordData`.
    /// Will return `nil` if there is no data or if the deserialization fails for some reason.
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
}

extension CKRecord.FieldKey {
    
    static let contact_name = "name"
    static let contact_userModificationDate = "userModificationDate"
}

// MARK: - Helpers

extension Contact {
    
    static let contactEmojis = [
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎",
        "🟥", "🟧", "🟨", "🟩", "🟦", "🟪", "⬛️", "⬜️", "🟫",
        "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚫️", "⚪️", "🟤",
    ]
    
    static func randomEmoji() -> String {
        return Self.contactEmojis.randomElement() ?? UUID().uuidString
    }
}
