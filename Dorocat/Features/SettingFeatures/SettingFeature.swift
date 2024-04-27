//
//  SettingFeature.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import Foundation
import ComposableArchitecture

@Reducer struct SettingFeature{
    enum NotificationStateType{
        case unAuthorized
        case enabled
        case disabled
    }
    @ObservableState struct State: Equatable{
        var notiType = NotificationStateType.unAuthorized
        var isSound = false
        var isInit = false
        @Presents var purchaseSheet: SettingPurchaseFeature.State?
    }
    enum Action:Equatable{
        case setSound(Bool)
        case setNotiType(NotificationStateType)
        case purchaseSheet(PresentationAction<SettingPurchaseFeature.Action>)
    case initAction
        case openPurchase
    }
    
    var body: some ReducerOf<Self>{
        Reduce{ state,action in
            switch action{
            case .initAction:
                if !state.isInit{
                    state.isInit = true
                    return .none
                }
                return .none
            case .setSound(let sound):
                print("wow world!!")
                state.isSound = sound
                return .none
            case .purchaseSheet: return .none
            case .openPurchase:
                state.purchaseSheet = .init()
                return .run{ send in
                    await send(.purchaseSheet(.presented(.initAction)))
                }
            case .setNotiType(let notiType):
                state.notiType = notiType
                return .none
            }
        }
        .ifLet(\.$purchaseSheet, action: \.purchaseSheet){
            SettingPurchaseFeature()
        }
    }
}
