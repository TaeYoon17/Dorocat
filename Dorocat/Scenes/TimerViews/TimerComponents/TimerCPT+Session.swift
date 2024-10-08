//
//  TimerCPT+Session.swift
//  Dorocat
//
//  Created by Developer on 6/12/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

extension TimerViewComponents{
    struct FocusSessionButton:View {
        let store: StoreOf<TimerFeature>
        var body: some View {
            switch store.timerStatus{
            case .breakStandBy,.focusStandBy,.completed:
                EmptyView()
            case .breakTime:
                Text("Break Time").foregroundStyle(Color.grey01).font(.button)
            case .standBy:
                Button { store.send(.viewAction(.sessionTapped)) } label: {
                    HStack(alignment:.center,spacing:0){
                        textItem
                        Image(.sessionDisclosure).padding(.leading,3)
                    }
                }
            case .focus:
                if store.timerInformation.isPomoMode{
                    Text("\(store.selectedSession.name) \(store.cycleNote)").foregroundStyle(.grey01).font(.button)
                }else{
                    textItem
                }
            default: textItem
            }
        }
        var textItem: some View{
            Text(store.selectedSession.name).foregroundStyle(Color.grey01).font(.button).fontCoordinator()
        }
    }
}
