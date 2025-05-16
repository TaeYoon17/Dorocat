//
//  TimerRecordItemEntity+CoreDataProperties.swift
//  Dorocat
//
//  Created by Developer on 6/9/24.
//
//

import Foundation
import CoreData


extension TimerRecordItemEntity {

    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerRecordItemEntity> {
        return NSFetchRequest<TimerRecordItemEntity>(entityName: "TimerRecordItemEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var recordCode: String?
    @NSManaged public var sessionKey: String?
    @NSManaged public var userModificationDate: Date?
    @NSManaged public var duration: Int32

}

extension TimerRecordItemEntity : Identifiable {

}
