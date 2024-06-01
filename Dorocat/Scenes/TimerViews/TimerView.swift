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
        VStack(spacing:0,content: {
            Spacer()
            switch store.timerStatus{
            case .standBy,.focus,.pause,.breakTime,.sleep:
                VStack(spacing:0) {
                    // Focus 모드시 고양이가 Session 버튼을 가림!!
                    TimerViewComponents.DoroCat(store:store)
                    TimerViewComponents.Timer.NumberField(store: store).frame(height: 102)
                    Rectangle().fill(.clear).frame(height: 29)
                }
            case .completed:
                VStack(spacing:0) {
                    VStack(alignment:.center,spacing:8) {
                        Text("Well done!").font(.header03).foregroundStyle(.doroWhite)
                        Text("You've completed successfully\nLet's stretch together.").font(.paragraph02()).foregroundStyle(.doroWhite)
                            .multilineTextAlignment(.center).lineSpacing(4)
                    }.padding(.bottom,-21)
                    TimerViewComponents.DoroCat(store:store).frame(maxWidth: 375, maxHeight: 375)
                        .padding(.bottom,8)
                    TimerViewComponents.TotalFocusTimeView(store: store)
                }
            case .breakStandBy:
                VStack(spacing:0) {
                    VStack(spacing:8 ,content: {
                        Text("Great!").font(.header03)
                        Text("You've completed this session").font(.paragraph02())
                    }).foregroundStyle(.doroWhite)
                    .padding(.bottom,-65)
                    TimerViewComponents.DoroCat(store:store)
                        .padding(.bottom,8)
                    Rectangle().fill(.clear).frame(height: 140)
                }
            }
            VStack(spacing:0) {
                TimerViewComponents.TriggerBtn(store: store).frame(height:60)
                Rectangle().fill(.clear).frame(height: 97)
            }
        }).frame(maxWidth: .infinity)
            .ignoresSafeArea(.container,edges: .bottom)
            .timerViewModifiers(store: store)
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore).presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $store.scope(state: \.timerSession, action: \.timerSession)) { timerSessionStore in
                TimerSessionView(store: timerSessionStore).presentationCornerRadius(24)
            }
            .sheet(item: $store.scope(state: \.catSelect, action: \.catSelect)) { catSelectStore in
                CatSelectView(store: catSelectStore)
            }
    }
}

fileprivate extension View{
    func timerViewModifiers(store: StoreOf<TimerFeature>) -> some View{
        self.modifier(TimerViewModifiers.Reset(store: store))
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
