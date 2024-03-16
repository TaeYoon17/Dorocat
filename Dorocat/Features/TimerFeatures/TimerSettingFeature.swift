//
//  TimerSettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer struct TimerSettingFeature{
    @ObservableState struct State: Equatable{
        var time:Int = 0
    }
    enum Action{ // 키패드 접근을 어떻게 할 것인지... 
    }
    
}
