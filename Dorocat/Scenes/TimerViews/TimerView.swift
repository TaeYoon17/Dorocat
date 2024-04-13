//
//  TimerView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct TimerView: View {
    @Perception.Bindable var store: StoreOf<TimerFeature>
    @Environment(\.scenePhase) var phase
    var body: some View {
        WithPerceptionTracking{
            VStack(content: {
                Spacer()
                if store.timerStatus == .completed{
                    VStack(alignment:.center,spacing:8) {
                        Text("Well done!").font(.header03).foregroundStyle(.doroWhite)
                        Text("You've completed successfully\nLet's stretch together.").font(.paragraph02()).foregroundStyle(.doroWhite)
                            .multilineTextAlignment(.center).lineSpacing(4)
                    }
                }
                if store.timerInformation.isPomoMode{
                    Text(store.cycleNote).font(.title2).bold().background(.blue)
                }
                TimerViewComponents.DoroCat(store:store)
                if store.timerStatus == .focus{
                    TimerViewComponents.Timer.CircleField(store:store)
                }
                Spacer()
                switch store.timerStatus{
                case .standBy,.focus,.pause,.breakTime:
                    TimerViewComponents.Timer.NumberField(store: store)
                case .completed,.breakStandBy: EmptyView()
                }
                TimerViewComponents.TriggerBtn(store: store)
            }).frame(maxWidth: .infinity)
            .timerViewModifiers(store: store)
            .sheet(item: $store.scope(state: \.timerSetting, action: \.timerSetting)) { timerSettingStore in
                TimerSettingView(store: timerSettingStore).presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
fileprivate extension View{
    func timerViewModifiers(store: StoreOf<TimerFeature>) -> some View{
        self.modifier(TimerViewModifiers.Reset(store: store))
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
