//
//  UserDefaultsServicing.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation

protocol UserDefaultsServicing {
    func loadData<T: Codable>(type: T.Type, key: UserDefaultsConstants.Keys) -> Result<T, Error>
    func saveData<T: Codable>(value: T, key: UserDefaultsConstants.Keys)
}
