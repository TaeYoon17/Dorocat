//
//  SettingView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture
struct SettingView: View {
    @Perception.Bindable var store: StoreOf<SettingFeature>
    @State private var isOn: Bool = false
    var body: some View {
        WithPerceptionTracking{
            NavigationStack {
                ZStack{
                    DefaultBG()
                    ScrollView {
                        Rectangle().fill(.clear).frame(height:30)
                        LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders], content: {
                            Section {
                                VStack(spacing:0) {
                                    VStack(spacing:8){
                                        ProListItemView().padding(.bottom,16)
                                        SettingListItem.Toggler(title: "Notifications",
                                                                description: "Get notified of focus sessions or breaks", isOn: $isOn)
                                        SettingListItem.Toggler(title: "Sound", isOn: $isOn)
                                        SettingListItem.Toggler(title: "Haptics", isOn: $isOn)
                                        SettingListItem.Linker(title: "Your Rating Matters") {
                                            print("hello world")
                                        }
                                        SettingListItem.Linker(title: "Send Feedback") {
                                            print("hello world")
                                        }
                                    }
                                    VStack{
                                        VStack {
                                            Image(.tempCat).resizable().scaledToFit().frame(width: 100, height: 100)
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
                }
                .toolbar(.hidden, for: .navigationBar)
            }
                .tint(.black)
                    .foregroundStyle(.black)
                    .toolbar(.hidden, for: .navigationBar)
                    .background(.grey04)
        }
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}

