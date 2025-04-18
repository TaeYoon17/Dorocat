//
//  IcloudSyncView.swift
//  Dorocat
//
//  Created by Greem on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

struct IcloudSyncView: View {
    
    @Bindable var store: StoreOf<ICloudSyncFeature>
    
    var body: some View {
        ZStack {
            DefaultBG().ignoresSafeArea(.all)
            ScrollView {
                LazyVStack {
                    SettingListItem.Toggler(
                        title: "Use iCloud Sync",
                        isOn: .constant(false)
                    )
                    Text("Last Sync: 8 seconds ago")
                    Section {
                        
                        SettingListItem.Toggler(
                            title: "Use Automatically Sync",
                            isOn: .constant(false)
                        )
                    } header: {
                        Text("세부 설정")
                    }
                }
            }
            .padding(.horizontal,16)
        }.toolbarTitleDisplayMode(.inline)
    }
}
