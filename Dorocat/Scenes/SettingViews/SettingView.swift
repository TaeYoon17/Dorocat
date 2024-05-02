//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>
    @State private var isOn: Bool = false
//    @State private var presentPurchaseSheet:Bool = false
    var body: some View {
//        NavigationStack {
            ZStack{
                DefaultBG()
                ScrollView {
                    Rectangle().fill(.clear).frame(height:30)
                    LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders], content: {
                        Section {
                            VStack(spacing:0) {
                                VStack(spacing:8){
                                    ProListItemView{ store.send(.openPurchase) }.padding(.bottom,16)
                                    switch store.notiAuthType{
                                    case .disabled, .enabled:
                                        let desc = "Get notified of focus sessions or breaks"
                                        SettingListItem.Toggler(title: "Notifications",
                                                                description: desc,
                                                                isOn: $store.isNotiEnabled.sending(\.setNotiEnabled))
                                    case .unAuthorized:
                                        let desc = "Get notified of focus sessions or breaks.\nMake sure to enable Dorocat notifications\nin iOS Settings."
                                        SettingListItem.Toggler(title: "Notifications",
                                                                description: desc,
                                                                isOn: $store.isNotiAuthorized.sending(\.setNotiAuthorized))
                                    }
                                    SettingListItem.Toggler(title: "Sound", isOn: $store.isSoundEnabled.sending(\.setSoundEnabled))
                                    SettingListItem.Toggler(title: "Haptics", isOn: $store.isHapticEnabled.sending(\.setHapticEnabled))
                                    SettingListItem.Linker(title: "Your Rating Matters") {
                                        store.send(.ratingItemTapped)
                                    }
                                    SettingListItem.Linker(title: "Send Feedback") {
                                        store.send(.feedbackItemTapped)
                                    }
                                }
                                VStack{
                                    VStack {
                                        Image(.settingCat).resizable().scaledToFit().frame(width: 100, height: 100)
                                        Text("Restore Purchases").font(.paragraph03(.bold)).foregroundStyle(.grey01)
                                        Button {
                                            print("Hello world")
                                        } label: {
                                            VStack{
                                                Text("Terms & Privacy\n1.6.0 (2)")
                                            }.font(.paragraph04)
                                                .foregroundStyle(.grey02)
                                        }
                                    }
                                }
                            }
                            .padding(.top,8)
                            .padding(.horizontal,16)
                        } header: {
                            SettingTitleView()
                                .padding(.top,4)
                                .padding(.horizontal,16)
                                .padding(.bottom,8)
                                .background(DefaultBG())
                        }
                    })
                }
                .sheet(item: $store.scope(state: \.purchaseSheet, action: \.purchaseSheet)) { settingPurchaseStore in
                    PurchaseSheet(store: settingPurchaseStore).presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .onAppear(){
                store.send(.launchAction)
            }
//        }
        .tint(.black)
        .foregroundStyle(.black)
        .toolbar(.hidden, for: .navigationBar)
        .background(.grey04)
        
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}

