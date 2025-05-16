//
//  TimerRecordRepository+AnalyzeAPIs.swift
//  Dorocat
//
//  Created by Greem on 4/16/25.
//

import Foundation

extension TimerRecordRepository: AnalyzeAPIs {
    
    func deleteAllItems() async {
        do {
            try await self.timerRecordDeleteAll()
            self.analyzeEventContinuation?.yield(.fetch)
        } catch {
            assertionFailure("삭제가 되지 않았음")
        }
    }
    
    var totalFocusTime: Double {
        get async {
             await Double(
                self.findAllItems().map(\.duration).reduce(0, +)
             )
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
                let count = try coreDataService.count(entityKey: .timerRecordEntity)
                return count == 0
            } catch {
                return true
            }
        }
    }
    
    func eventAsyncStream() async -> AsyncStream<AnalyzeEvent> { self.analyzeEvent }
    
    /// 오늘 기록 아이템들 반환
    func get(day: Date) async throws -> [TimerRecordItem] {
        try await get(
            predicateFormat: { "\($0[0]) == %@" },
            args: day.convertToRecordCode()
        )
    }
    
    /// 주간 기록 아이템들 반환
    func get(weekDate: Date) async throws -> [TimerRecordItem] {
        try await get(
            predicateFormat: { "\($0[0]) IN %@" },
            args: getCode(weekDate: weekDate)
        )
    }
    
    /// 월간 기록 아이템들 반환
    func get(monthDate: Date) async throws -> [TimerRecordItem] {
        try await get(
            predicateFormat: { "\($0[0]) IN %@" },
            args: getCode(monthDate: monthDate)
        )
    }
    
    
    /// 아이템 추가 -> 이전에 없던 데이터를 새로 추가하는 것이 확정직이다.
    func append(_ item: TimerRecordItem) async {
        /// 1. 여기 코어데이터에 직접 추가한다.
        await timerItemUpsert(item: item)
        /// 2. 코어 데이터에 추가한 값 ID를 아이 클라우드에 넣는다.
        let dto = CKTimerRecordDTO(item: item)
        await syncedDatabase.appendPendingSave(items: [dto], directlySend: true)
        self.analyzeEventContinuation?.yield(.append)
    }
    
    
    
    func delete(_ item: TimerRecordItem) async {
        try? await self.timerItemDeletes(items: [item])
        let dto = CKTimerRecordDTO(item: item)
        await syncedDatabase.appendPendingDelete(items: [dto])
        self.analyzeEventContinuation?.yield(.fetch)
    }
    
    func update(_ item: TimerRecordItem) async {
        var item = item
        /// 날짜를 최신 날짜로 변경!
        item.userModificationDate = Date()
        await self.timerItemUpsert(item: item)
        
        if self.isICloudSyncEnabled {
            let dto = CKTimerRecordDTO(item: item)
            await self.syncedDatabase.appendPendingSave(items: [dto], directlySend: true)
        }
        self.analyzeEventContinuation?.yield(.fetch)
    }
    
}


fileprivate extension TimerRecordRepository {
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
