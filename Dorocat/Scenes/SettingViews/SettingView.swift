//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
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
                                ProListItemView{ store.send(.openPurchase) }.padding(.bottom,16)
                                SettingViewComponents.NotiListItem(store: store)
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
                                VStack(spacing:0) {
                                    Button {
                                        print("hello world")
                                    } label: {
                                        Image(.settingCat).resizable().scaledToFit().frame(width: 100, height: 100)
                                    }
                                    HStack(spacing:8){
                                        Link(destination: URL(string: "https://chip-goose-fa5.notion.site/Dorocat-Terms-7e6e5404ae984bde8963f25d12eb5144?pvs=74")!){
                                            Text("Terms of Service").font(.paragraph03(.bold)).foregroundStyle(.grey02)
                                        }
                                        Text("·").font(.paragraph02(.bold)).foregroundStyle(.doroWhite)
                                        Link(destination: URL(string: "https://chip-goose-fa5.notion.site/Dorocat-Privacy-Policy-ad164a6289994922a39c4ba1e69a7621")!) {
                                            Text("Privacy Policy").font(.paragraph03(.bold)).foregroundStyle(.grey02)
                                        }
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
            }.scrollIndicators(.hidden)
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

