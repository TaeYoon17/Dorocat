//
//  AnalyzeRepository.swift
//  Dorocat
//
//  Created by Developer on 4/8/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@DBActor final class TimerRecordRepository: TableRepository<TimerRecordItemTable>{
    
    func getByDay(date:Date) -> Results<TimerRecordItemTable>{
        self.getTasks.where { table in
            table.recordCode.equals(date.convertToRecordCode())
        }
    }
    func getByWeeks(date:Date) -> Results<TimerRecordItemTable>{
        guard let weekDay = Calendar.current.dateComponents([.weekday], from: date).weekday,
              let sundayDate = Calendar.current.date(byAdding: .day, value: -weekDay + 1, to: date) else{
            fatalError("날짜가 존재하지 않음")
        }
        let weekDates = (0...6).map{
            Calendar.current.date(byAdding: .day, value: $0, to: sundayDate)!.convertToRecordCode()
        }
        return self.getTasks.where { table in
            table.recordCode.in(weekDates)
        }
    }
    func getByMonth(date:Date) -> Results<TimerRecordItemTable>{
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: calendar.dateComponents([.year,.month], from: date)),
              let endDate = calendar.date(byAdding: DateComponents(month:1,day:-1), to: startDate) else{
            fatalError("달의 날짜")
        }
        var currentDate = startDate
        var dateCodes: [String] = []
        while currentDate <= endDate {
            dateCodes.append(currentDate.convertToRecordCode())
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return self.getTasks.where { table in
            table.recordCode.in(dateCodes)
        }
    }
    func append(_ item:TimerRecordItemTable) async {
        await self.create(item: item)
    }
    var totalDuration: Double{
        self.getTasks.reduce(0) { partialResult, table in
            partialResult + Double(table.duration)
        }
    }
}
