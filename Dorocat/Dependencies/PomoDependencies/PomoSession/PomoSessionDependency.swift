//
//  PomoSessionType.swift
//  Dorocat
//
//  Created by Developer on 5/11/24.
//

import Foundation
import Combine
import ComposableArchitecture

protocol SessionStoreProtocol{
    var allSessions:[SessionItem]{ get async }
    func updateSessions(_ item:[SessionItem]) async throws
}
enum SessionEvent{
    case sessionDeleted([SessionItem])
    case sessionAppended([SessionItem])
}
final actor PomoSessionClient{
    let essentialItemsID: [SessionItem.ID] = ["Read","Study","Focus","Work"].map{SessionItem(name: $0).id}
    let defaultSession: SessionItem.ID = "Read"
    var items:[SessionItem]{ get async { await store.allSessions } }
    var selectedItem:SessionItem{
        get async {
            guard let sessionData = UserDefaults.standard.data(forKey: "SelectedSession") else {return .init(name: defaultSession)}
            let item = try! JSONDecoder().decode(SessionItem.self, from: sessionData)
            return item
        }
    }
    private var store: SessionStoreProtocol!
    let event = PassthroughSubject<SessionEvent,Never>()
    static let shared = PomoSessionClient()
    private init(){ }
    func initAction() async throws{
        if self.store != nil {return}
        do{
//            self.store = try await RealmSessionStore(essentialItems: essentialItemsID, defaultSessionKey: defaultSession)
            self.store = try await CoreDataSessionStore(essentialItems: essentialItemsID, defaultSessionKey: defaultSession)
        }catch{
            throw SessionErrorType.sessionStoreInitFailed
        }
    }
    func getSession(id:SessionItem.ID) async throws -> SessionItem{
        guard let item = await self.items.first(where: {$0.id == id}) else{
            return await self.items.first{$0.id == defaultSession}!
        }
        return item
    }
    func setSelectedSession(_ session:SessionItem) async{
        let item = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(item, forKey: "SelectedSession")
    }
    func getSnapShot() async -> Snapshot{
        await Snapshot(allSessions: store.allSessions, defaultSession: defaultSession,essentialSessions: essentialItemsID.map{SessionItem(name: $0)})
    }
    func applySnapshot(snapshot:Snapshot) async {
        try! await store.updateSessions(snapshot.allSessions)
        event.send(.sessionAppended(snapshot.appendedSessions))
        event.send(.sessionDeleted(snapshot.deletedSessions))
    }
}
fileprivate enum PomoSessionClientKey: DependencyKey{
    static let liveValue: PomoSessionClient = PomoSessionClient.shared
}
extension DependencyValues{
    var pomoSession: PomoSessionClient{
        get{self[PomoSessionClientKey.self]}
        set{self[PomoSessionClientKey.self] = newValue}
    }
}
