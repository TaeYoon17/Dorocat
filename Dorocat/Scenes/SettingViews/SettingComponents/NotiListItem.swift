//
//  NotiListItem.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

extension SettingViewComponents{
    struct NotiListItem:View {
        let store: StoreOf<SettingFeature>
        var body: some View {
            switch store.notiAuthType{
            case .disabled, .enabled:
                let desc = "Get notified of focus sessions or breaks"
                SettingListItem.Toggler(
                    title: "Notifications",
                    description: desc,
                    isOn: Binding(
                        get: { store.isNotiEnabled },
                        set: {  store.send(.viewAction(.setNotiEnabled($0))) }
                    )
                )
            case .denied:
                let desc = "Get notified of focus sessions or breaks.\nMake sure to enable Dorocat notifications\nin iOS Settings."
                SettingListItem.Toggler(
                    title: "Notifications",
                    description: desc,
                    isOn: Binding(
                        get: { store.isNotiAuthorized },
                        set: { store.send(.viewAction(.setNotiAuthorized($0))) }
                    )
                )
            }
        }
    }
}
