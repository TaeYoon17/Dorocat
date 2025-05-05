//
//  CatRepository.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation
import ComposableArchitecture



final class CatClient: CatDependency {
    private let defaults: any UserDefaultsServicing
    var selectedCat: CatType {
        get async {
            let result = defaults.loadData(type: CatType.self, key: .catTypeSelect)
            switch result {
            case .success(let success):
                return success
            case .failure:
                return .doro
            }
        }
    }
    
    init(defaults: UserDefaultsServicing = UserDefaultsService()) {
        self.defaults = defaults
    }
    
    private var catEventContinuation: AsyncStream<CatEvent>.Continuation!
    
    private lazy var event = AsyncStream<CatEvent> { [weak self] continuation in
        self!.catEventContinuation = continuation
    }
    
    func catEventStream() async -> AsyncStream<CatEvent> {
        self.event
    }
    
    func updateCatType(_ item: CatType) async {
        defaults.saveData(value: item, key: .catTypeSelect)
        catEventContinuation.yield(.updated(item))
    }
}
