//
//  CloudKitConvertible.swift
//  Dorocat
//
//  Created by Greem on 4/30/25.
//

import Foundation
import CloudKit

protocol CKWritable {
    var recordType: CKRecord.RecordType { get }
    func populateRecord(_ record: CKRecord)
}

protocol CKReadable {
    var recordType: CKRecord.RecordType { get }
    
    var ckRecordZoneID: CKRecordZone.ID { get }
    var ckRecordID: CKRecord.ID { get }
}

protocol CKIdentifiable: Identifiable, Hashable, Equatable, Comparable {}

protocol CKConvertible: CKReadable, CKWritable, CKIdentifiable {
    
    associatedtype Item
    
    static var zoneName: String { get }
    static var recordType: CKRecord.RecordType { get }
    var ckRecordZoneID: CKRecordZone.ID { get }
    var ckRecordID: CKRecord.ID { get }
    init(record: CKRecord)
    
    func convertToItem() throws -> Item
    func applyItem(_ item: inout Item) throws
    /// 레코드에 이 프로토콜을 지키는 Value의 값을 쓴다.
    func populateRecord(_ record: CKRecord)
}
