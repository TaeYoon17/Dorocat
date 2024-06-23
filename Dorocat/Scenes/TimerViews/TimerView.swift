//
//  TimerView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct TimerView: View {
    @Bindable var store: StoreOf<TimerFeature>
    @Environment(\.scenePhase) var phase
    var body: some View {
        ZStack{
            DefaultBG()
            switch store.timerStatus{
            case .standBy,.focus,.pause,.breakTime,.sleep:
                ZStack {
                    // Focus 모드시 고양이가 Session 버튼을 가림!!
                    VStack(spacing:0) { // 타이머 숫자 조금 더 올림
                        Rectangle().fill(.clear).frame(width: 375,height: 375)
                        TimerViewComponents.Timer.NumberField(store: store).frame(height: 102).offset(y: -8)
                    }.offset(y:-78 + 50)
                    TimerViewComponents.DoroCat(store:store).offset(y:-78)
                }
            case .completed:
                ZStack{
                    VStack(alignment:.center,spacing:0) {
                        Text("Well done!").font(.header03).foregroundStyle(.doroWhite)
                        Text("You've completed successfully\nLet's stretch together.").font(.paragraph02()).foregroundStyle(.doroWhite)
                            .multilineTextAlignment(.center).lineSpacing(4)
                        Rectangle().fill(.clear).frame(width: 375,height: 375)
                    }.offset(y:-78)
                    TimerViewComponents.DoroCat(store:store).offset(y:-11)
                    VStack(spacing:0) {
                        Rectangle().fill(.clear).frame(width: 375,height: 375)
                        TimerViewComponents.TotalFocusTimeView(store: store)
                    }.offset(y:11)
                }
            case .breakStandBy:
                ZStack{
                    VStack(spacing:0,content: {
                        Text("Great!").font(.header03)
                        Text("You've completed this session").font(.paragraph02())
                        Rectangle().fill(.clear).frame(width: 375,height: 375)
                    }).foregroundStyle(.doroWhite)
                        .offset(y: -78)
                    TimerViewComponents.DoroCat(store:store).offset(y:-78)
                }
            }
        }
        .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom, content: {
                VStack(spacing:0) {
                    TimerViewComponents.TriggerBtn(store: store).frame(height:60)
                    Rectangle().fill(.clear).frame(height: 97)
                }
            })
            .ignoresSafeArea(.container,edges: .bottom)
            .timerViewModifiers(store: store)
            .preferredColorScheme(.dark)
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore).presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $store.scope(state: \.catSelect, action: \.catSelect)) { catSelectStore in
                CatSelectView(store: catSelectStore)
            }
            
            .environment(\.colorScheme, .dark)
    }
}

fileprivate extension View{
    func timerViewModifiers(store: StoreOf<TimerFeature>) -> some View{
        self
//            .modifier(TimerViewModifiers.Reset(store: store))
            .modifier(TimerViewModifiers.Session(store: store))
            .modifier(TimerViewModifiers.Guide.Focus(store: store))
            .modifier(TimerViewModifiers.Guide.StandBy(store: store))
            .modifier(TimerViewModifiers.Guide.GoLeft(store: store))
            .modifier(TimerViewModifiers.Guide.GoRight(store: store))
            .modifier(TimerViewModifiers.Init(store: store))
    }
}
#Preview {
    TimerView(store: Store(initialState: TimerFeature.State(), reducer: {
        TimerFeature()
    }))
}
