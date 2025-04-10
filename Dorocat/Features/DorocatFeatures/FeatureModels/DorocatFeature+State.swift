//
//  DorocatFeature+State.swift
//  Dorocat
//
//  Created by Developer on 5/18/24.
//

import Foundation
import ComposableArchitecture
extension DorocatFeature{
    @ObservableState struct State: Equatable{
        var pageSelection: PageType = .timer
        var appState = AppStateType.active
        var guideState = Guides()
        var isAppLaunched = false
        var showPageIndicator = true
        var catType:CatType = .doro
        var isProUser: Bool = false
        //MARK: -- 하위 뷰의 State 들...
        var anylzeState = AnalyzeFeature.State()
        var timerState = MainFeature.State()
        var settingState = SettingFeature.State()
    }
}
