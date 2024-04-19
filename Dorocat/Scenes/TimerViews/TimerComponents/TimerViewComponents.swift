//
//  TimerViewComponents.swift
//  Dorocat
//
//  Created by Developer on 4/6/24.
//

import SwiftUI
import ComposableArchitecture

enum TimerViewComponents{
    struct TriggerBtn: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
                let text = switch store.timerStatus{
                case .breakTime: "Stop Break"
                case .completed: "Complete"
                case .standBy: "Start"
                case .focus:"Pause"
                case .pause(.focusPause): "Start"
                case .breakStandBy: "Break"
                default: ""
                }
                Button(text){
                    store.send(.viewAction(.triggerTapped))
                }.triggerStyle(scale: btnScale)
        }
        var btnScale:TriggerBtnStyle.ButtonScale{
            switch store.timerStatus{
            case .breakTime,.completed: .flexed
            default: .fixed(110)
            }
        }
    }
    enum Timer{
        struct NumberField:View{
            let store: StoreOf<TimerFeature>
            var body: some View{
                HStack(content: {
                    Spacer()
                    HStack (alignment: .center,spacing:1){
                        HStack{
                            Spacer()
                            Text(store.timer.prefix(2))
                        }
                        Text(":")
                        HStack {
                            Text(store.timer.suffix(2))
                            Spacer()
                        }
                    }
                    .font(.header01).foregroundStyle(.doroWhite)
                    .onTapGesture {
                        store.send(.viewAction(.timerFieldTapped))
                    }
                    Spacer()
                })
            }
        }
        struct CircleField: View{
            let store: StoreOf<TimerFeature>
            var body: some View{
                CircularProgress(progress: CGFloat(store.progress), lineWidth: 40, backShape: Color.grey03, frontShapes: [Color.doroWhite])
            }
        }
    }
    struct DoroCat:View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Button(action: {
                store.send(.viewAction(.catTapped))
            }, label: {
                switch store.timerStatus{
                case .completed:
                    LottieView(fileName: "WellDone", loopMode: .autoReverse).frame(width: size,height: size)
                case .breakStandBy:
                    LottieView(fileName: "Great", loopMode: .autoReverse)
                        .frame(width: size,height: size)
                case .focus,.breakTime,.pause(.breakPause):
                    CircularProgress(progress: store.progress, lineWidth: 44, backShape: ImagePaint(image: Image(.defaultBg)), frontShapes: [Color.black])
                        .overlay(alignment: .bottom) {
                            LottieView(fileName: "Sleeping", loopMode: .autoReverse).offset(y:4)
                                .frame(width: 190,height:190)
                        }
                        .frame(width: size,height: size).padding(.bottom,36)
                case .standBy,.pause:
                    LottieView(fileName: "Default", loopMode: .autoReverse)
                        .frame(width: size,height: size)
                }
            })
        }
        var size: CGFloat{
            switch store.timerStatus{
            case .focus,.breakTime: 240
            default: 375
            }
        }
    }
    struct ResetButton: View{
        let store: StoreOf<TimerFeature>
        var body: some View{
            Button{
                store.send(.viewAction(.resetTapped))
            }label: {
                Text("Reset")
                    .font(.button)
                    .foregroundStyle(.doroWhite)
                    .padding(.horizontal,20)
                    .padding(.vertical,13.5)
                    .background(.grey03)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
extension TimerViewComponents{
    enum Guide{
        struct GoLeft:View{
            var body: some View{
                Image(.leftGuide).resizable()
                    .scaledToFit()
                    .frame(height:314)
                    .overlay(alignment: .leading) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.leading,4)
                    }
            }
        }
        struct GoRight: View {
            var body: some View {
                Image(.rightGuide).resizable()
                    .scaledToFit()
                    .frame(height: 314)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.trailing,4)
                    }
            }
        }
        struct StandBy:View{
            var body: some View{
                Text("Let the cat snooze and get started!")
                    .foregroundStyle(.grey00)
                    .font(.paragraph03())
                    .padding(.horizontal,20)
                    .padding(.vertical,14)
                    .background(.grey03)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        struct Focus: View{
            var body: some View{
                Text("Cat's asleep!")
                    .foregroundStyle(.grey00)
                    .font(.paragraph03())
                    .padding(.horizontal,20)
                    .padding(.vertical,14)
                    .background(.grey03)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
