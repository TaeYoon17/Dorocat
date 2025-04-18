//
//  AnalyzeCoreDataClient+AnalyzeAPIs.swift
//  Dorocat
//
//  Created by Greem on 4/16/25.
//

import Foundation
import CoreData

//MARK: -- CoreData - CRUD
extension AnalyzeCoreDataClient: AnalyzeAPIs {
    var totalFocusTime: Double {
        get async {
            await coreDataService.managedObjectContext.perform { [weak self] in
                guard let self else {return 0}
                let request = TimerRecordItemEntity.fetchRequest()
                request.entity = self.entityDescription
                do {
                    let results = try coreDataService.managedObjectContext.fetch(request)
                    return results.reduce(0, { $0 + Double($1.duration) })
                } catch {
                    assertionFailure("전체 시간 변환 실패 \(error)")
                    return 0
                }
            }
        }
    }
    
    func initAction() async throws {
        await syncedDatabase.setAutomaticallySync(isOn: false)
        try await syncedDatabase.fetchChanges()
    }
    
    func eventAsyncStream() async -> AsyncStream<AnalyzeEvent> { self.analyzeEvent }
    
    private func get(date: Date, predicate: NSPredicate) async throws -> [TimerRecordItem] {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = entityDescription
            request.predicate = predicate
            request.sortDescriptors = [ TimerRecordItemEntity.dateSortDescriptor ]
            let results = try coreDataService.managedObjectContext.fetch(request)
            return results.map { $0.convertToItem }
        }
    }
    
    /// 오늘 기록 아이템들 반환
    func get(day: Date) async throws -> [TimerRecordItem] {
        let predicate = NSPredicate(format: "recordCode == %@", day.convertToRecordCode())
        return try await get(date: day, predicate: predicate)
    }
    
    /// 주간 기록 아이템들 반환
    func get(weekDate: Date) async throws -> [TimerRecordItem] {
        let predicate = NSPredicate(format: "recordCode IN %@", getCode(weekDate: weekDate))
        return try await get(date: weekDate, predicate: predicate)
    }
    
    /// 월간 기록 아이템들 반환
    func get(monthDate: Date) async throws -> [TimerRecordItem] {
        let dateCodes = getCode(monthDate: monthDate)
        let predicate = NSPredicate(format: "recordCode IN %@", dateCodes)
        return try await get(date: monthDate, predicate: predicate)
    }
    
    
    
    /// 아이템 추가 -> 이전에 없던 데이터를 새로 추가하는 것이 확정직이다.
    func append(_ item: TimerRecordItem) async {
        /// 1. 여기 코어데이터에 직접 추가한다.
        await coredataAppend(item: item)
        /// 2. 코어 데이터에 추가한 값 ID를 아이 클라우드에 넣는다.
        await syncedDatabase.appendPendingSave(items: [item])
        self.analyzeEventContinuation?.yield(.append)
    }
    
    func refresh() async {
        // 싱크 자체를 할 것인지 확인한다. if isSyncEnabled {
//            try? await syncedDatabase.fetchChanges()
//        }
    }
    
    func setSyncEnable(_ isOn: Bool) async {
        if isOn { /// 이제 싱크를 할 것이다.
            
        } else { /// 이제 싱크를 안 할 것이다.
            /// 자동 싱크를 끈다.
            await syncedDatabase.setAutomaticallySync(isOn: false)
            /// 마지막으로 직접 fetch한다. -> 끝!!
            // syncedDatabase.fetchCloudData(isSyncEnable: Bool)
            // 이 클라이언트에서 refresh 작업은 작동할 수 없다
        }
        
    }
    
    
}


fileprivate extension AnalyzeCoreDataClient {
    /// date타입을 CoreData에 저장한 코드로 변환
    func getCode(weekDate date:Date) -> [String] {
        guard let weekDay = Calendar.current.dateComponents([.weekday], from: date).weekday,
              let sundayDate = Calendar.current.date(byAdding: .day, value: -weekDay + 1, to: date) else {
            assertionFailure(#function)
            return []
        }
        let weekDates = (0...6).map {
            Calendar.current.date(
                byAdding: .day,
                value: $0,
                to: sundayDate)!
                .convertToRecordCode()
        }
        return weekDates
    }
    
    /// date타입을 CoreData에 저장한 코드로 변환
    func getCode(monthDate date: Date)->[String]{
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year,.month], from: date))
        guard let startDate else {
            assertionFailure(#function)
            return []
        }
        let endDate = calendar.date(byAdding: DateComponents(month:1,day:-1), to: startDate)
        guard let endDate else {
            assertionFailure(#function)
            return []
        }
        var currentDate = startDate
        var dateCodes: [String] = []
        while currentDate <= endDate {
            dateCodes.append(currentDate.convertToRecordCode())
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dateCodes
    }
}
