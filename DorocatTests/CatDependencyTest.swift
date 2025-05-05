//
//  Test.swift
//  DorocatTests
//
//  Created by Greem on 5/5/25.
//

import XCTest
@testable import Dorocat
import ComposableArchitecture

@MainActor
final class CatDependencyTests: XCTestCase {
    func testCatSelectFeature() async {
        let store = TestStore(initialState: CatSelectFeature.State()) {
            CatSelectFeature()
        } withDependencies: { dependencies in
            // 테스트용 의존성 설정
            dependencies.cat = CatClient(defaults: MockUserDefaultsService())
        }
        
        // 초기 상태 테스트
        XCTAssertEqual(store.state.catType, .doro)
        
        // 고양이 타입 변경 테스트
        await store.send(.setCatType(.pomo)) {
            $0.catType = .pomo
        }
        
        // 선택된 고양이 타입 변경 테스트
        await store.send(.setSelectedCatType(.muya)) {
            $0.tappedCatType = .muya
        }
    }
}
