//
//  CatTypeExtension.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import Foundation
extension CatType{
    var lockImageLabel:String{
        "\(self.rawValue)_lock"
    }
    var compactLabel: String{
        "\(self.rawValue)_compact"
    }
}
