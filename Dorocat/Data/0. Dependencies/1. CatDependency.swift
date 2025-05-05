//
//  CatDependencyInteractor.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
import ComposableArchitecture
import UIKit
import Combine
/// EventStream을 이용해서 고양이 타입이 바뀐 경우 전체 전파할 필요가 있음...
/// or 최상위 영역에서 고양이 타입을 관리하는 방법...
enum CatEvent { case updated(CatType) }

protocol CatDependency {
    var selectedCat: CatType { get async }
    func catEventStream() async -> AsyncStream<CatEvent>
    func updateCatType(_ item: CatType) async
}


fileprivate enum CatClientKey: DependencyKey {
    static let liveValue: CatDependency = CatClient()
    static let testValue: CatDependency = CatClient(
        defaults: MockUserDefaultsService()
    )
}
extension DependencyValues {
    var cat: CatDependency {
        get { self[CatClientKey.self] }
        set { self[CatClientKey.self] = newValue }
    }
}
