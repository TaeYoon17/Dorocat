//
//  UserDefaultsSessionStore.swift
//  Dorocat
//
//  Created by Developer on 5/11/24.
//

import Foundation
final class UserDefaultsSessionStore:SessionStoreProtocol{
    private let defaultsKeyName:String = "SessionTypes"
    private(set) var allSessions:[SessionItem]{
        get{
            guard let sessionTypesData = UserDefaults.standard.data(forKey: defaultsKeyName) else {
                return []
            }
            let items = try! JSONDecoder().decode([SessionItem].self, from: sessionTypesData)
            return items
        }
        set{
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: defaultsKeyName)
        }
    }
    private let essentialItems: [SessionItem.ID]
    init(essentialItems: [SessionItem.ID]) {
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
