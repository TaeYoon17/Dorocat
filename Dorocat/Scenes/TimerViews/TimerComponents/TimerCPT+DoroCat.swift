//
//  TimerCPT+Cat.swift
//  Dorocat
//
//  Created by Developer on 6/12/24.
//

import SwiftUI
import ComposableArchitecture

extension TimerViewComponents{
    struct DoroCat:View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Group{
                switch store.timerStatus{
                case .completed:
                    LottieView(fileName: store.catType.lottieAssetName(type: .done)
                               , loopMode: .autoReverse).frame(width: size,height: size)
                case .breakStandBy:
                    LottieView(fileName: store.catType.lottieAssetName(type: .great)
                               , loopMode: .autoReverse)
                    .frame(width: size,height: size)
                case .focus,.breakTime,.sleep,.pause:
                    LottieView(fileName: store.catType.lottieAssetName(type: .sleeping)
                               , loopMode: .autoReverse)
                    .frame(width: size,height: size)
                case .standBy:
                    LottieView(fileName: store.catType.lottieAssetName(type: .basic), loopMode: .autoReverse)
                        .frame(width: size,height: size)
                }
            }.onTapGesture {
                store.send(.viewAction(.catTapped))
            }
        }
        var size: CGFloat{
            switch store.timerStatus{
                //            case .focus,.breakTime,.sleep,.pause: 240
            default: 375
            }
        }
    }
}
