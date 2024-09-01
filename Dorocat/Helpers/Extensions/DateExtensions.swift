//
//  DateExtensions.swift
//  Dorocat
//
//  Created by Developer on 3/30/24.
//

import Foundation
//MARK: -- static methods...
extension Date{
    static func getMonthNumberToName(_ num: Int) -> String{
        let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        return months[num]
    }
    static func numberOfDaysInMonth(year: Int, month: Int) -> Int? {
        let calendar = Calendar.current
        // 유효한 연도와 월인지 확인
        guard let date = calendar.date(from: DateComponents(year: year, month: month)),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        return range.count
    }
}
//MARK: -- variable methods...
extension Date{
    // 이전 날짜와 비교해서 2일을 넘겼는지 확인하는 메서드
    func isOverTwoDays(prevDate:Date) -> Bool{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: prevDate)
        if let days = components.day, days >= 2 {
            return true
        } else {
            return false
        }
    }
    // 한 달에 날짜 계수
    func numberOfDaysInMonth() -> Int?{
        let cpt = Calendar.current.dateComponents([.year,.month], from: self)
        return Self.numberOfDaysInMonth(year: cpt.year ?? 0, month: cpt.month ?? 0)
    }
    // 오늘 Day 숫자
    func numberOfDay()->Int{
        let current = Calendar.current
        return current.dateComponents([.day], from: self).day ?? 0
    }
    // 같은 Day인지 확인
    func isSameDay(_ date: Date) -> Bool{
        let calendar = Calendar.current
        let leftCPT = calendar.dateComponents([.year,.month,.day], from: self)
        let rightCPT = calendar.dateComponents([.year,.month,.day], from: date)
        return leftCPT == rightCPT
    }
}
