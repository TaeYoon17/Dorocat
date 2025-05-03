//
//  SessionItem.swift
//  Dorocat
//
//  Created by Developer on 5/11/24.
//

import Foundation

struct SessionItem:Identifiable,Codable,Hashable{
    var id:String { name }
    var name: String
}
extension SessionItem{
    static func defaultItem()->Self{
        .init(name: "Focus")
    }
}
