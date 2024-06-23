//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import StoreKit
import ComposableArchitecture
enum SettingViewComponents{}
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
                            VStack(spacing:8){
                                if !store.isProUser{
                                    ProListItemView{ store.send(.openPurchase) }.padding(.bottom,16)
                                }
                                SettingViewComponents.NotiListItem(store: store)
//                                SettingListItem.Toggler(title: "Sound", isOn: $store.isSoundEnabled.sending(\.setSoundEnabled))
                                SettingListItem.Toggler(title: "Haptics", isOn: $store.isHapticEnabled.sending(\.setHapticEnabled))
//                                SettingListItem.Linker(title: "Your Rating Matters") {
//                                    store.send(.ratingItemTapped)
//                                }
                                SettingViewComponents.WriteReviewLink(title: "Your Rating Matters")
                                SettingListItem.Linker(title: "Send Feedback") {
                                    store.send(.feedbackItemTapped)
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
            }.scrollIndicators(.hidden)
            .refundRequestSheet(for: store.refundTransactionID, isPresented: Binding(get: {
                    store.isRefundPresent
            }, set: { store.send(.setRefundPresent($0)) }))
            .sheet(item: $store.scope(state: \.purchaseSheet, action: \.purchaseSheet)) { settingPurchaseStore in
                    PurchaseSheet(store: settingPurchaseStore).presentationDetents([.large])
                        .presentationDragIndicator(.visible)
            }
            .sheet(item: $store.scope(state: \.feedbackSheet, action: \.feedbackSheet)) { sheetStore in
                FeedbackSheet(store: sheetStore).ignoresSafeArea(.container,edges:.bottom).presentationDetents([.large]).tint(.doroWhite)
                        .presentationDragIndicator(.visible)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
        .onAppear(){
            store.send(.launchAction)
            print("Setting OnAppear")
        }
        .onDisappear(){
            print("Setting Disappear")
        }
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

