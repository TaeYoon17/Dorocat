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
        @Bindable var store: StoreOf<TimerFeature>
        var body: some View{
            Button(action: {
            }, label: {
                Group{
                    switch store.timerStatus{
                    case .completed:
                        LottieView(fileName: store.catType.lottieAssetName(type: .done)
                                   , loopMode: .autoReverse).frame(width: size,height: size)
                    case .breakStandBy,.focusStandBy:
                        LottieView(fileName: store.catType.lottieAssetName(type: .done)
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
                }
            }).buttonStyle(CatButtonStyle{
                Task{
                    try await Task.sleep(for: .seconds(0.25))
                    _ = await MainActor.run {
                        store.send(.viewAction(.catTapped))
                    }
                }
            })
        }
        var size: CGFloat{
            switch store.timerStatus{
                //            case .focus,.breakTime,.sleep,.pause: 240
            default: 375
            }
        }
    }
}
fileprivate struct CatButtonStyle:ButtonStyle{
    var willTap:(()->())?
    func makeBody(configuration: Configuration) -> some View {
        let translateChagne:CGFloat = configuration.isPressed ? 0.90 : 1
        configuration.label.scaleEffect(x:translateChagne,y:translateChagne).animation(.spring(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue == false && newValue == true{
                    willTap?()
                }
            }
    }
    
}
