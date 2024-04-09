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
    func append(_ item:TimerRecordItemTable) async {
        await self.create(item: item)
    }
    var totalDuration: Double{
        self.getTasks.reduce(0) { partialResult, table in
            partialResult + Double(table.duration)
        }
    }
}
