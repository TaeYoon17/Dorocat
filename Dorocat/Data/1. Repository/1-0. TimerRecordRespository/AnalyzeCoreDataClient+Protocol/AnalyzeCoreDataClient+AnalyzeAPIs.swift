//
//  AnalyzeCoreDataClient+AnalyzeAPIs.swift
//  Dorocat
//
//  Created by Greem on 4/16/25.
//

import Foundation
import CoreData
enum Constants {
    static let lastSyncedDate = "lastSyncedDate"
}

extension AnalyzeCoreDataClient: AnalyzeAPIs {
    
    func deleteAllItems() async {
        do {
            try await self.timerRecordDeleteAll()
            print("모든 삭제 성공")
            self.analyzeEventContinuation?.yield(.fetch)
        } catch {
            print("삭제 에러", error)
        }
    }
    
    var totalFocusTime: Double {
        get async {
            await coreDataService.managedObjectContext.perform { [weak self] in
                guard let self else {return 0}
                let request = TimerRecordItemEntity.fetchRequest()
                request.entity = coreDataService.getEntityDescription(key: .timerRecordEntity)
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
        if isInit { return }
        await syncedDatabase.setAutomaticallySync(isOn: isAutomaticallySyncEnabled)
        /// iCloud를 연결하지 않으면 에러를 방출한다.
        await syncedDatabase.appendSyncHandler(key: .timerItem, value: self)
        isInit = true
    }
    
    var isEmptyTimerItem: Bool {
        get async {
            do {
                let request = TimerRecordItemEntity.fetchRequest()
                let count = try coreDataService.managedObjectContext.count(for: request)
                return count == 0
            } catch {
                return true
            }
        }
    }
    
    func eventAsyncStream() async -> AsyncStream<AnalyzeEvent> { self.analyzeEvent }
    
    private func get(date: Date, predicate: NSPredicate) async throws -> [TimerRecordItem] {
        try await coreDataService.managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            let request = TimerRecordItemEntity.fetchRequest()
            request.entity = coreDataService.getEntityDescription(key: .timerRecordEntity)
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
        await timerItemUpsert(item: item)
        /// 2. 코어 데이터에 추가한 값 ID를 아이 클라우드에 넣는다.
        await syncedDatabase.appendPendingSave(items: [item], directlySend: true)
        self.analyzeEventContinuation?.yield(.append)
    }
    
    
    
    func delete(_ item: TimerRecordItem) async {
        try? await self.timerItemDeletes(items: [item])
        await syncedDatabase.appendPendingDelete(items: [item])
        self.analyzeEventContinuation?.yield(.fetch)
    }
    
    func update(_ item: TimerRecordItem) async {
        var item = item
        /// 날짜를 최신 날짜로 변경!
        item.userModificationDate = Date()
        await self.timerItemUpsert(item: item)
        
        if self.isICloudSyncEnabled {
            await self.syncedDatabase.appendPendingSave(items: [item], directlySend: true)
        }
        self.analyzeEventContinuation?.yield(.fetch)
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
