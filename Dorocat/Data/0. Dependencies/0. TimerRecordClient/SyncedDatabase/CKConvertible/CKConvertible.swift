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

protocol CKConvertible: CKReadable, CKWritable {
    init(record: CKRecord)
    
    mutating func mergeFromServerRecord(_ record: CKRecord) -> Bool
    
//    func populateRecord(_ record: inout CKRecord)
}
