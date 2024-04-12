//
//  AnalyzeView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift
struct AnalyzeView: View {
    @Perception.Bindable var store: StoreOf<AnalyzeFeature>
    var body: some View {
        WithPerceptionTracking {
            ZStack{
                Image(.defaultBg).resizable(resizingMode: .tile)
                ScrollView {
                    VStack{
                        Rectangle().fill(.clear).frame(height:40)
                        LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders], content: {
                            Section {
                                VStack(spacing:16) {
                                    AnalyzeDurationView.Day(store: store)
                                    VStack(spacing:8) {
                                        ForEach(store.timerRecordList){ item in
                                            AnalyzeListItemView(durationDateType: .day, timerListItem: item)
                                        }
                                    }
                                }.padding(.horizontal, 16)
                            } header: {
                                DurationPickerView(selectedDuration: $store.durationType.sending(\.setDurationType))
                                        .padding(.vertical,8)
                                        .background(DefaultBG())
                            }
                        })
                        Rectangle().fill(.clear).frame(height:40)
                    }
                }.onAppear {
                    store.send(.initAnalyzeFeature)
                }
            }.toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    AnalyzeView(store: Store(initialState: AnalyzeFeature.State(), reducer: {
        AnalyzeFeature()
    }))
}
