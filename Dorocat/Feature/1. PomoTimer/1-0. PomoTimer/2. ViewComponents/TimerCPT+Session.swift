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
        let store: StoreOf<MainFeature>
        var body: some View {
            switch store.timerProgressEntity.status{
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
                if store.timerSettingEntity.isPomoMode{
                    Text("\(store.timerProgressEntity.session.name) \(store.cycleNote)")
                        .foregroundStyle(.grey01).font(.button)
                }else{
                    textItem
                }
            default: textItem
            }
        }
        var textItem: some View{
            Text(store.timerProgressEntity.session.name)
                .foregroundStyle(Color.grey01)
                .font(.button)
                .fontCoordinator()
        }
    }
}
