//
//  TimerFeature+State.swift
//  Dorocat
//
//  Created by Developer on 3/28/24.
//

import Foundation
import ComposableArchitecture
extension MainFeature{
    @ObservableState struct State: Equatable{
        var guideInformation = Guides()
        var appState = DorocatFeature.AppStateType.active
        var isAppLaunched:Bool = false
        
        var catType: CatType = .doro  
        
        var timerProgressEntity = TimerProgressEntity()
        var timerSettingEntity = TimerSettingEntity() // 앱에서 설정한 정보...

        // BreakTime Skip할 때 Trigger View를 Trigger 시키는 값
        var isSkipped:Bool = false
        var isProUser:Bool = false

        
        @Presents var timerSetting: TimerSettingFeature.State?
        @Presents var timerSession: TimerSessionFeature.State?
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
        @Presents var catSelect: CatSelectFeature.State?
        @Presents var resetDialog: ConfirmationDialogState<Action>?
        
    }
}



struct TimerProgressEntity:Equatable {
    var startDate: Date = .init()
    var cycle: Int = 0
    var count: Int = 0
    var status: TimerStatus = .standBy
    var session: SessionItem = .init(name: "Focus")
}
struct DoroStateEntity {
    var progressEntity = TimerProgressEntity()
    var settingEntity = TimerSettingEntity()
}
