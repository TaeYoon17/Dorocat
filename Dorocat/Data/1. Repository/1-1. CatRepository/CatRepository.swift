//
//  CatRepository.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation
import ComposableArchitecture

final class CatClient: CatDependency {
    @Dependency(\.doroStateDefaults) private var doroStateDefaults
    
    var selectedCat: CatType {
        get async {
            await doroStateDefaults.getCatType()
        }
    }
    
    private var catEventContinuation: AsyncStream<CatEvent>.Continuation!
    private lazy var event = AsyncStream<CatEvent> { [weak self] continuation in
        self!.catEventContinuation = continuation
    }
    
    func catEventStream() async -> AsyncStream<CatEvent> {
        self.event
    }
    func updateCatType(_ item: CatType) async{
        await doroStateDefaults.setCatType(item)
        catEventContinuation.yield(.updated(item))
    }
}
