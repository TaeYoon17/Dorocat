//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import DoroDesignSystem
import StoreKit
import ComposableArchitecture

enum SettingViewComponents { }
struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>
    @State private var isOn: Bool = false
    var body: some View {
        ZStack{
            DefaultBG()
            ScrollView {
                Rectangle().fill(.clear).frame(height:30)
                LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders], content: {
                    Section {
                        VStack(spacing:0) {
                            VStack(spacing:8) {
                                if !store.isProUser {
                                    ProListItemView {
                                        store.send(.viewAction(.openPurchase))
                                    }
                                    .padding(.bottom,16)
                                }
                                /// NavigationLink의 장점 - 루트 reducer에서 하위 뷰와의 연결이 되어서 관리가 가능함
                                    SettingListItem.Linker(
                                        title: "iCloud Sync",
                                        description: "It's no Synced"
                                    ) {
                                        store.send(.viewAction(.openIcloudSetting))
                                    }
                                SettingViewComponents.NotiListItem(store: store)
                                SettingListItem.Toggler(
                                    title: "Haptics",
                                    isOn: Binding(
                                        get: { store.isHapticEnabled },
                                        set: { store.send(.viewAction(.setHapticEnabled($0))) }
                                    )
                                )
                                SettingViewComponents.WriteReviewLink(title: "Your Rating Matters")
                                SettingListItem.Linker(title: "Send Feedback") {
                                    store.send(.viewAction(.feedbackItemTapped))
                                }
                            }
                            SettingViewComponents.Bottom(store: store)
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
            .scrollIndicators(.hidden)
            .refundRequestSheet(
                    for: store.refundTransactionID,
                    isPresented:
                        Binding(
                            get: { store.isRefundPresent },
                            set: { store.send(.viewAction(.setRefundPresent($0))) }
                        ),
                    onDismiss: { res in
                        switch res {
                        case .success(let status):
                            print(status)
                        case .failure(let error):
                            print("res error",error)
                        }
                    }
                )
                .sheet(item: $store.scope(state: \.purchaseSheet, action: \.purchaseSheet)) { settingPurchaseStore in
                    PurchaseSheet(store: settingPurchaseStore)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(item: $store.scope(state: \.feedbackSheet, action: \.feedbackSheet)) { sheetStore in
                    FeedbackSheet(store: sheetStore)
                        .ignoresSafeArea(.container,edges:.bottom)
                        .presentationDetents([.large])
                        .tint(.doroWhite)
                        .presentationDragIndicator(.visible)
                }
                .alert($store.scope(state: \.alert, action: \.alert))
        }
        .onAppear() { store.send(.launchAction) }
        .tint(.doroBlack)
        .foregroundStyle(Color.doroBlack)
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.grey04)
        
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}

