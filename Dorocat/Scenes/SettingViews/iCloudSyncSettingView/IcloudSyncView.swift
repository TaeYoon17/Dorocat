//
//  IcloudSyncView.swift
//  Dorocat
//
//  Created by Greem on 4/17/25.
//

import SwiftUI
import ComposableArchitecture


enum IcloudSyncComponents { }
struct IcloudSyncView: View {
    
    @Environment(\.dismiss) var dismiss
    @Bindable var store: StoreOf<ICloudSyncFeature>
    
    var body: some View {
        ZStack {
            DefaultBG().ignoresSafeArea(.all)
            VStack {
                IcloudSyncComponents.NavigationBar(
                    leftAction: {
                        dismiss()
                    },
                    centerTitle: "iCloud Settings"
                )
                ScrollView {
                    VStack {
                        Rectangle().foregroundStyle(Color.clear).frame(height: 16)
                        IcloudSyncComponents.UseIcloudSyncListToggler(
                            title: "Use iCloud",
                            isOn: Binding (
                                get: { store.isSyncEnabled },
                                set: { store.send(.viewAction(.setIsSyncEnabled($0))) }
                            )
                        )
                        if store.isSyncEnabled {
                            Rectangle().foregroundStyle(Color.clear).frame(height: 16)
                            VStack(spacing: 6) {
                                HStack {
                                    Text("Detail Settings")
                                    Spacer()
                                }
                                .font(.paragraph04)
                                .foregroundStyle(Color.doroWhite)
                                .padding(.horizontal, 16)
                                VStack(spacing: 8) {
                                    IcloudSyncComponents.UseAutomaticallySyncListToggler(
                                        title: "Sync Automatically",
                                        description: "Auto-sync your data across devices using iCloud.",
                                        isOn: Binding(
                                            get: { store.isAutomaticSyncEnabled },
                                            set: { store.send(.viewAction(.setIsAutomaticSyncEnabled($0))) })
                                    )
                                    IcloudSyncComponents.RefreshSyncListButton(
                                        title: "Latest sync",
                                        description: "1 minues ago...",
                                        isLoading: store.isLoading
                                    ) {
                                        store.send(.viewAction(.refreshTapped))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal,16)
        }
        .onAppear() {
            store.send(.onAppear)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationTitle("iCloud Setting")
        .toolbarTitleDisplayMode(.inline)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    let _store = Store(
        initialState: ICloudSyncFeature.State(),
        reducer: { ICloudSyncFeature() }
    )
    @Bindable var store = _store
    NavigationStack {
        IcloudSyncView(store: store)
    }
}



