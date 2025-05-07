//
//  CoreConvertible.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation
import CoreData

protocol CoreEntityConvertible {
    associatedtype T:Identifiable
    
    func applyItem(_ item: T)
    var convertToItem: T { get }
}
