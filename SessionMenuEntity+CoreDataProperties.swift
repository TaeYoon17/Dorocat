//
//  SessionMenuEntity+CoreDataProperties.swift
//  Dorocat
//
//  Created by Developer on 6/11/24.
//
//

import Foundation
import CoreData


extension SessionMenuEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionMenuEntity> {
        return NSFetchRequest<SessionMenuEntity>(entityName: "SessionMenuEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?

}

extension SessionMenuEntity : Identifiable {

}
