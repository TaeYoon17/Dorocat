//
//  DateExtensions.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
extension Date{
    func isOverTwoDays(prevDate:Date) -> Bool{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: prevDate)
        if let days = components.day, days >= 2 {
            return true
        } else {
            return false
        }
    }
}
