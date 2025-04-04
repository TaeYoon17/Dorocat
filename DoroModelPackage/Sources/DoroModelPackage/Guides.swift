//
//  Guides.swift
//  Dorocat
//
//  Created by Developer on 4/26/24.
//

import Foundation

struct Guides:Equatable {
    var onBoarding:Bool = false // 온보딩 첫 화면 가이드
    var goLeft:Bool = false // 타이머 뷰에서 왼쪽으로 스와이프를 알려주는 화면 가이드
    var goRight: Bool = false // 타이머 뷰에서 오른쪽으로 스와이프를 알려주는 화면 가이드
    var standByGuide: Bool = false // 타이머 뷰에서 처음 화면을 들어올 때, 시간 설정 버튼을 알려주는 화면 가이드
    var startGuide:Bool = false // 타이머 Focus를 처음 시작했을 때를 알려주는 화면 가이드
}
