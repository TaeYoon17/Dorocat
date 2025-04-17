//
//  AnalyzeFeature+State.swift
//  Dorocat
//
//  Created by Developer on 4/12/24.
//

import Foundation
import ComposableArchitecture
protocol AnalyzeInformationAble {
    var title:String { get }
    var totalTime:String { get }
    var date:Date { get }
    var timerRecordList: IdentifiedArrayOf<TimerRecordItem> { get set }
    var isLastDuration:Bool { get }
    @discardableResult
    mutating func prev() -> Date
    @discardableResult
    mutating func next() -> Date
}
extension AnalyzeInformationAble {
    var totalTime: String {
        let totalNum = timerRecordList.reduce(0) { partialResult, item in
            partialResult + item.duration
        }
        return "\(totalNum / 60)h \(totalNum.minuteString)m"
    }
}
extension AnalyzeFeature {
    @ObservableState struct DayInformation:Equatable,AnalyzeInformationAble {
        var date = Date()
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem> = []
        var isLastDuration: Bool {
            let current = Calendar.current
            let todayCPT = current.dateComponents([.year,.month,.day], from: date)
            let nowCPT = current.dateComponents([.year,.month,.day], from: Date())
            return todayCPT == nowCPT
        }
        var title: String {
            let current = Calendar.current
            let todayCPT = current.dateComponents([.year,.month,.day], from: date)
            let nowCPT = current.dateComponents([.year,.month,.day], from: Date())
            let day = (Calendar.current.dateComponents([.year,.month,.day], from: date).day ?? 1)
            return "\(todayCPT == nowCPT ? "Today, " : "")\(date.getMonthName()) \(day)"
        }
        mutating func prev() -> Date {
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? Date()
            self.date = yesterday
            return yesterday
        }
        mutating func next() -> Date{
            let calendar = Calendar.current
            let tommorow = calendar.date(byAdding: .day, value: 1, to: date) ?? Date()
            self.date = tommorow
            return tommorow
        }
    }
    @ObservableState struct WeekInformation: Equatable,AnalyzeInformationAble {
        var date = Date()
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem> = []
        
        var title: String{
            let current = Calendar.current
            guard let weekDay = current.dateComponents([.weekday], from: date).weekday,
                  let sundayDate:Date = current.date(byAdding: .day, value: -weekDay + 1, to: date),
                  let saturdayDate = current.date(byAdding: .day, value: 6, to: sundayDate) else {
                fatalError("Wow world")
            }
            return "\(sundayDate.getMonthName()) \(sundayDate.numberOfDay()) - \(saturdayDate.getMonthName()) \(saturdayDate.numberOfDay())"
        }
        var isLastDuration: Bool {
            let current = Calendar.current
            let weekDay = current.dateComponents([.weekday], from: date).weekday!
            let sundayDate = current.date(byAdding: .day, value: -weekDay + 1, to: date)!
            let nowWeekDay = current.dateComponents([.weekday], from: Date()).weekday!
            let nowSundayDate = current.date(byAdding: .day, value: -nowWeekDay + 1, to: Date())!
            return current.dateComponents([.year,.month,.day], from: sundayDate) == current.dateComponents([.year,.month,.day], from: nowSundayDate)
        }
        
        var dailyAverage:String {
            let totalDuration = timerRecordList.reduce(0) { $0 + $1.duration }
            let dailyCount = if date.isSameDay(Date()){
                Calendar.current.dateComponents([.weekday], from: date).weekday ?? 1
            }else{
                7
            }
            let dailyAveNum = totalDuration / dailyCount
            return "\(dailyAveNum / 60)h \(dailyAveNum.minuteString)m"
        }
        mutating func prev() -> Date {
            let current = Calendar.current
            let prevWeekDay = current.date(byAdding: .day, value: -7, to: date) ?? Date()
            self.date = prevWeekDay
            return prevWeekDay
        }
        mutating func next() ->Date {
            let current = Calendar.current
            let nextWeekDay = current.date(byAdding: .day, value: 7, to: date) ?? Date()
            self.date = nextWeekDay
            return nextWeekDay
        }
    }
    @ObservableState struct MonthInformation: Equatable,AnalyzeInformationAble {
        var isLastDuration: Bool {
            let current = Calendar.current
            let month = current.dateComponents([.year,.month], from: date)
            let nowMonth = current.dateComponents([.year,.month], from: Date())
            return month == nowMonth
        }
        
        var title: String { date.getMonthName() }
        var date = Date()
        var timerRecordList: IdentifiedArrayOf<TimerRecordItem> = []
        var dailyAverage: String {
            let totalDuration = timerRecordList.reduce(0) { $0 + $1.duration }
            let nowDayCount = if date.isSameDay(Date()){
                Calendar.current.dateComponents([.day], from: date).day ?? 0
            }else{
                date.numberOfDaysInMonth() ?? 0
            }
            let monthAveNum = totalDuration / nowDayCount
            return "\(monthAveNum / 60)h \(monthAveNum.minuteString)m"
        }
        mutating func prev() -> Date{
            let calendar = Calendar.current
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: self.date) ?? Date()
            self.date = prevMonth
            return prevMonth
        }
        mutating func next() -> Date{
            let calendar = Calendar.current
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: self.date) ?? Date()
            self.date = nextMonth
            return nextMonth
        }
    }
}
extension Date{
    func getMonthName()->String{
        let monthNumber = (Calendar.current.dateComponents([.month], from: self).month ?? 1)  - 1
        return Date.getMonthNumberToName(monthNumber)
    }
    
}
