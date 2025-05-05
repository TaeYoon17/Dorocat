



class MockUserDefaultsService: UserDefaultsServicing {
    private var data: [String: Any] = [:]

    func loadData<T: Codable>(type: T.Type, key: UserDefaultsConstants.Keys) -> Result<T, Error> {
        guard let result = data[key.rawValue] as? T else {
            return .failure(UserDefaultsError.keyNotFound(key: key.rawValue))
        }
        return .success(result)
    }

    func saveData<T: Codable>(value: T, key: UserDefaultsConstants.Keys) {
        self.data[key.rawValue] = value
    }
}
