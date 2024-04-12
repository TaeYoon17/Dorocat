//
//  IntExtensions.swift
//  Dorocat
//
//  Created by Developer on 4/13/24.
//

import Foundation
extension Int{
    var hourString:String{
        "\(self / 60 < 10 ? "0" : "")\(self / 60)"
    }
    var minuteString:String{
        "\(self % 60 < 10 ? "0" : "")\(self % 60)"
    }
}
