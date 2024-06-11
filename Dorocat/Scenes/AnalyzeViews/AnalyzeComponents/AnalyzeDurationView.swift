//
//  AnalyzeDurationView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
extension DurationType{
    var averageTitle: String{
        return switch self{
        case .day: ""
        case .week: "Weekly Average"
        case .month: "Montly Average"
        }
    }
}
enum AnalyzeDurationView{
    struct Day:View{
        let store: StoreOf<AnalyzeFeature>
        var body: some View{
            VStack(spacing:38) {
                DurationSignView(title: store.dayInfo.title, isLastSign: store.dayInfo.isLastDuration) {
                    store.send(.viewAction(.signLeftTapped))
                } rightTapped: {
                    store.send(.viewAction(.signRightTapped))
                }
                TotalFocusTimeView(totalTime: store.dayInfo.totalTime)
                    .animation(nil,value: store.dayInfo.totalTime)
            }.modifier(DurationModifier())
        }
    }
    struct Week:View {
        let store: StoreOf<AnalyzeFeature>
        var body: some View {
            VStack(spacing:38) {
                DurationSignView(title: store.weekInfo.title, isLastSign: store.weekInfo.isLastDuration) {
                    store.send(.viewAction(.signLeftTapped))
                } rightTapped: {
                    store.send(.viewAction(.signRightTapped))
                }
                VStack(spacing:12) {
                    TotalFocusTimeView(totalTime: store.weekInfo.totalTime)
                        .animation(nil,value: store.weekInfo.totalTime)
                    DailyAverageView(title: store.durationType.averageTitle, dailyAverage: store.weekInfo.dailyAverage)
                        .animation(nil,value: store.weekInfo.dailyAverage)
                }
            }.modifier(DurationModifier())
        }
    }
    struct Month: View{
        let store: StoreOf<AnalyzeFeature>
        var body: some View{
            VStack(spacing:38) {
                DurationSignView(title: store.monthInfo.title, isLastSign: store.monthInfo.isLastDuration) {
                    store.send(.viewAction(.signLeftTapped))
                } rightTapped: {
                    store.send(.viewAction(.signRightTapped))
                }
                VStack(spacing:12) {
                    TotalFocusTimeView(totalTime: store.monthInfo.totalTime)
                        .animation(nil,value: store.monthInfo.totalTime)
                    DailyAverageView(title: store.durationType.averageTitle, dailyAverage: store.monthInfo.dailyAverage)
                        .animation(nil,value: store.monthInfo.dailyAverage)
                }
            }.modifier(DurationModifier())
        }
    }
}

fileprivate extension AnalyzeDurationView{
    struct DurationSignView: View{
        let title:String
        let isLastSign:Bool
        var leftTapped:()->()
        var rightTapped:()->()
        var body: some View{
            HStack {
                Button{ leftTapped()}label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(title).font(.paragraph03()).foregroundStyle(.grey00).fontCoordinator()
                Spacer()
                Button{ rightTapped() }label: {
                    Image(systemName: "chevron.right")
                }.disabled(isLastSign)
            }.padding(.horizontal,4).tint(.grey00)
        }
    }
    struct TotalFocusTimeView: View{
        
        let totalTime:String
        var body: some View{
            HStack(content: {
                VStack(alignment:.leading,spacing:-4) {
                    Text("Total Time").font(.paragraph04).foregroundStyle(.grey02)
                    Text(totalTime)
                        .font(.header03)
                        .foregroundStyle(.doroWhite)
                }
                Spacer()
            }).padding(.bottom,4)
        }
    }
    struct DailyAverageView: View{
        let title:String
        let dailyAverage: String
        
        var body: some View{
            HStack(content: {
                VStack(alignment:.leading,spacing:-4) {
                    Text(title).font(.paragraph04).foregroundStyle(.grey02)
                    Text(dailyAverage)
                        .font(.header03).fontCoordinator()
                        .foregroundStyle(.doroWhite)
                }
                Spacer()
            }).padding(.bottom,4)
        }
    }
    struct DurationModifier: ViewModifier{
        func body(content: Content) -> some View {
            content.padding(.vertical,30)
                .padding(.horizontal,24)
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
