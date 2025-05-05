//
//  UserDefaultsService.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation

struct UserDefaultsService: UserDefaultsServicing {
    // 저장
    func save<T>(value: T, key: UserDefaultsConstants.Keys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func saveData<T: Codable>(value: T, key: UserDefaultsConstants.Keys) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }
    func loadData<T:Codable>(type: T.Type, key: UserDefaultsConstants.Keys) -> Result<T, Error> {
        if let data = UserDefaults.standard.data(forKey: key.rawValue),
           let result = try? JSONDecoder().decode(type, from: data) {
            return .success(result)
        } else {
            return .failure(UserDefaultsError.keyNotFound(key: key.rawValue))
        }
    }
    
    // 불러오기
    func load<T>(type: T.Type, key: UserDefaultsConstants.Keys) -> Result<T, Error> {
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? T {
            return .success(data)
        } else {
            return .failure(UserDefaultsError.keyNotFound(key: key.rawValue))
        }
    }
    
    // 삭제
    func remove(key: UserDefaultsConstants.Keys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
