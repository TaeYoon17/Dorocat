//
//  AnalyzeView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct AnalyzeView: View {
    @Bindable var store: StoreOf<AnalyzeFeature>
    var body: some View {
        ZStack{
            Image(.defaultBg).resizable(resizingMode: .tile)
            ScrollView {
                VStack{
                    Rectangle().fill(.clear).frame(height:40)
                    LazyVStack(alignment: .center, pinnedViews: [.sectionHeaders], content: {
                        Section {
                            VStack(spacing:16) {
                                switch store.durationType{
                                case .day:AnalyzeDurationView.Day(store: store)
                                case .month: AnalyzeDurationView.Month(store: store)
                                case .week: AnalyzeDurationView.Week(store: store)
                                }
                                LazyVStack(spacing:8) {
                                    ForEach(store.timerRecordList){ item in
                                        AnalyzeListItemView(durationDateType: store.durationType, timerListItem: item)
                                    }
                                }.frame(maxHeight: .infinity)
                            }.padding(.horizontal, 16)
                        } header: {
                            DurationPickerView(selectedDuration: $store.durationType.sending(\.selectDuration))
                                .padding(.vertical,8)
                                .background(DefaultBG())
                        }
                    })
                    Rectangle().fill(.clear).frame(height:40)
                }
            }
            .onAppear {
                store.send(.initAnalyzeFeature)
            }
        }.toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    AnalyzeView(store: Store(initialState: AnalyzeFeature.State(), reducer: {
        AnalyzeFeature()
    }))
}
