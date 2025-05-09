import Testing
import Foundation
@testable import Dorocat
import ComposableArchitecture

struct CoreDataServiceTest {
    
    let testItem = TimerRecordItem(
        id: .init(),
        recordCode: "하이요",
        createdAt: .now,
        duration: 12,
        session: .defaultItem(),
        modificationDate: .now
    )
    let dummyItems: [TimerRecordItem] = [
        TimerRecordItem(
            id: .init(),
            recordCode: "더미1",
            createdAt: .now,
            duration: 25,
            session: .defaultItem(),
            modificationDate: .now
        ),
        TimerRecordItem(
            id: .init(),
            recordCode: "더미2", 
            createdAt: .now,
            duration: 30,
            session: .defaultItem(),
            modificationDate: .now
        ),
        TimerRecordItem(
            id: .init(),
            recordCode: "더미3",
            createdAt: .now,
            duration: 45,
            session: .defaultItem(),
            modificationDate: .now
        )
    ]
    
    /// 데이터를 넣는게 잘 되는지 확인한다...
    @Test func upsertItemMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        // 1. 데이터를 넣는다
        await analyzeRepository.timerItemUpsert(item: testItem)
        // 2. 데이터를 가져온다.
        if let item = await analyzeRepository.findItemByID(testItem.id) {
            #expect(item == testItem)
        } else {
            #expect(false, "데이터 조회에 실패했습니다")
        }
    }
}

//MARK: -- Create
extension CoreDataServiceTest {
    /// ID를 이용해 값을 찾는게 잘 되는지 확인하려 합니다...
    /// CoreDataService로 변경한 findByItem 함수가 잘 되는지 확인한다.
    @Test func findByItemMigrationTest() async throws {
        /// 1. 기존 AnalyzeRepository에 값을 넣고 그 값을 가져온다.
        let analyzeRepository = await TimerRecordRepository()
        let coreDataService = await CoreDataService()

        await analyzeRepository.update(testItem)
        async let analyzedItem = analyzeRepository.findItemByID(testItem.id)
        /// CoreData에서 구현한 findByItem에서 AnalyzeRepository에서 가져온 값과 같은지 비교한다.
        async let coreDataItemResult = coreDataService.findItemByID(
            testItem.id.uuidString,
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity
        )

        switch await coreDataItemResult {
        case .success(let success):
            #expect(await analyzedItem == success, "중복값 삽입이 잘 되는가")
        case .failure:
            #expect(false, "데이터 조회에 실패했습니다")
        }

        await analyzeRepository.delete(testItem)
    }
    
    @Test func fetchAllItemMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        try? await analyzeRepository.timerRecordDeleteAll()
        await analyzeRepository.delete(testItem)
        for dummyItem in dummyItems {
            await analyzeRepository.timerItemUpsert(item: dummyItem)
        }
        for dummyItem in dummyItems {
            await analyzeRepository.timerItemUpsert(item: dummyItem)
        }
        
        let targetItems = await analyzeRepository.findAllItems()
        print(targetItems)
        #expect(targetItems.count == dummyItems.count)
        #expect(Set(targetItems.map(\.id)) == Set(dummyItems.map(\.id)), "id가 같은지 확인한다.")
    }
    
    @Test func fetchItemsMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        try? await analyzeRepository.timerRecordDeleteAll()
        await analyzeRepository.timerItemUpsert(item: dummyItems[0])
        await analyzeRepository.timerItemUpsert(item: dummyItems[1])
        
        let targetItems = try await analyzeRepository.findItemsByID([dummyItems[0],dummyItems[1]].map(\.id))
        #expect(targetItems == [dummyItems[0],dummyItems[1]])
    }
    
    @Test
    func getCounts() async throws {
        
        let coreDataService = await CoreDataService()
        _ = await coreDataService.deleteAllItem(entityKey: .timerRecordEntity)
        _ = await coreDataService.upsertItem(item: self.testItem, id: self.testItem.id.uuidString, entityKey: .timerRecordEntity)
        let findValues = try await coreDataService.findWithCondition(
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity,
            attributes: [\.recordCode, \.duration],
            args: ["하이요","방가요"], self.testItem.duration
        ) { "\($0[0]) IN %@ AND \($0[1]) <= %d" }
        print(findValues.count)
        #expect(testItem == findValues.first)
    }
}

//MARK: -- Delete
extension CoreDataServiceTest {
    @Test func deleteItemMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        try await self.upsertItemMigrationTest()
        try await self.fetchAllItemMigrationTest()
        let coreDataService = await CoreDataService()
        try? await analyzeRepository.timerRecordDeleteAll()
        
        await analyzeRepository.timerItemUpsert(item: dummyItems[0])
        await analyzeRepository.timerItemUpsert(item: dummyItems[1])
        
        switch await coreDataService.deleteItemByID(dummyItems[0].id.uuidString, entityKey: .timerRecordEntity) {
        case .success(_): break
        case .failure(_):
            #expect(Bool(false), "fetchAllItems error")
        }
        
        let fetchAllItems = await coreDataService.findAllItems(
            type: TimerRecordItem.self,
            entityKey: .timerRecordEntity
        )
        switch fetchAllItems{
        case .success(let items):
            #expect(items.count == 1)
        case .failure(_):
            #expect(Bool(false), "fetchAllItems error")
        }
    }
    
    @Test func deleteAllItemMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        let coreDataService = await CoreDataService()
        try await self.upsertItemMigrationTest()
        try await self.fetchAllItemMigrationTest()
        
        try? await analyzeRepository.timerRecordDeleteAll()
        var fetchAllItems = await analyzeRepository.findAllItems()
        #expect(fetchAllItems.count == 0)
        await analyzeRepository.timerItemUpsert(item: dummyItems[0])
        await analyzeRepository.timerItemUpsert(item: dummyItems[1])
        fetchAllItems = await analyzeRepository.findAllItems()
        #expect(fetchAllItems.count == 2)
        
        switch await coreDataService.deleteAllItem(entityKey: .timerRecordEntity) {
        case .success(_): break
        case .failure(_): #expect(Bool(false), "deleteAllItems error")
        }
        var fetchAllItemsAfterDeleteAll = await analyzeRepository.findAllItems()
        #expect(fetchAllItemsAfterDeleteAll.count == 0)
        await analyzeRepository.timerItemUpsert(item: dummyItems[0])
        await analyzeRepository.timerItemUpsert(item: dummyItems[1])
        try await analyzeRepository.timerRecordDeleteAll()
        fetchAllItemsAfterDeleteAll = await analyzeRepository.findAllItems()
        #expect(fetchAllItemsAfterDeleteAll.count == 0)
    }
    
    @Test func deleteItemsMigrationTest() async throws {
        let analyzeRepository = await TimerRecordRepository()
        let coreDataService = await CoreDataService()
        let dummies = [dummyItems[0],dummyItems[1]]
        try await self.upsertItemMigrationTest()
        try await self.fetchAllItemMigrationTest()
        
        try? await analyzeRepository.timerRecordDeleteAll()
        for dummy in dummies {
            await analyzeRepository.timerItemUpsert(item: dummy)
        }
        
        switch await coreDataService.deleteItemsById(dummies.map(\.id.uuidString), entityKey: .timerRecordEntity) {
        case .success(_): break
        case .failure(_): #expect(Bool(false), "deleteItemsById error")
        }
        var fetchAllItemsAfterDeleteAll = await analyzeRepository.findAllItems()
        #expect(fetchAllItemsAfterDeleteAll.count == 0)
        for dummy in dummies {
            await analyzeRepository.timerItemUpsert(item: dummy)
        }
        try await analyzeRepository.timerItemDeletes(items: [dummies[0]])
        fetchAllItemsAfterDeleteAll = await analyzeRepository.findAllItems()
        #expect(fetchAllItemsAfterDeleteAll.count == 1)
    }
}
