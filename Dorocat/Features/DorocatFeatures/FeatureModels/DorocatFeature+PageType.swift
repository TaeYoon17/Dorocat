//
//  DorocatFeature+PageType.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
extension DorocatFeature{
    enum PageType:String,Hashable,Equatable,CaseIterable,Identifiable{
        var id:String{ self.rawValue }
        case analyze
        case timer
        case setting
    }
}
