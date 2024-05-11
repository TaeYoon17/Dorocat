import UIKit
import Combine
struct SessionItem:Identifiable,Codable,Hashable{
    var id:String { name }
    var name: String
}
protocol SessionStoreProtocol{
    var allSessions:[SessionItem] { get }
    func updateSessions(_ item:[SessionItem])
}
enum SessionEvent{
    case sessionDeleted([SessionItem])
    case sessionAppended([SessionItem])
}
enum SessionErrorType: Error{
    case addFailed_isExistItem
    case deleteFailed_isEssentialItem
    case isUpdatingSessionType
}
final class SessionManager{
    let essentialItemsID: [SessionItem.ID] = ["Focus","Work","Study","Read"].map{SessionItem(name: $0).id}
    let defaultSession: SessionItem.ID = "Focus"
    var items:[SessionItem]{ store.allSessions }
    private lazy var store: SessionStoreProtocol = {
        let store = UserDefaultsSessionStore(essentialItems: essentialItemsID)
        return store
    }()
    let event = PassthroughSubject<SessionEvent,Never>()
    static let shared = SessionManager()
    private init(){}
    func getSnapShot() -> Snapshot{
        Snapshot(allSessions: store.allSessions, defaultSession: defaultSession)
    }
    func applySnapshot(snapshot:Snapshot){
        store.updateSessions(snapshot.allSessions)
        event.send(.sessionAppended(snapshot.appendedSessions))
        event.send(.sessionDeleted(snapshot.deletedSessions))
    }
}
extension SessionManager{
    struct Snapshot{
        var allSessions: [SessionItem]
        var defaultSession: SessionItem.ID
        private(set) var appendedSessions:[SessionItem] = []
        private(set) var deletedSessions:[SessionItem] = []
        mutating func add(name: String) throws {
            let item = SessionItem(name: name)
            allSessions.append(item)
            appendedSessions.append(item)
        }
        mutating func delete(name: String) throws {
            allSessions.removeAll(where: {$0.name == name})
            deletedSessions.append(SessionItem(name: name))
        }
        func contain(name: String) -> Bool {
            allSessions.contains(where: {$0.name == name})
        }
    }
}

final class UserDefaultsSessionStore:SessionStoreProtocol{
    private let defaultsKeyName:String = "SessionTypes"
    private(set) var allSessions:[SessionItem]{
        get{
            guard let sessionTypesData = UserDefaults.standard.data(forKey: defaultsKeyName) else { fatalError("세션 타입이 존재하지 않음")}
            let items = try! JSONDecoder().decode([SessionItem].self, from: sessionTypesData)
            return items
        }
        set{
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: defaultsKeyName)
        }
    }
    private let essentialItems: [SessionItem.ID]
    init(essentialItems: [SessionItem.ID]){
        self.essentialItems = essentialItems
        updateSessions(allSessions)
    }
    func updateSessions(_ updatedItems: [SessionItem]) {
        var items = essentialItems.map{SessionItem(name: $0)}
        let uniqueSessions = Set(updatedItems).subtracting(items)
        items.append(contentsOf: uniqueSessions)
        allSessions = items
    }
}
