//
//  AnalyzeListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import DoroDesignSystem

struct AnalyzeListItemView:View{
    let durationDateType: DurationType
    let timerListItem:TimerRecordItem
    var body: some View{
        HStack {
            HStack {
                Image(.haptic).resizable().frame(width: 20,height:20).opacity(0.6)
                HStack(spacing:6) {
                    Text("\(timerListItem.duration)m").font(.paragraph03()).foregroundStyle(Color.doroWhite)
                        .fontCoordinator()
                    Text("\(timerListItem.session.name)").font(.paragraph03()).foregroundStyle(Color.grey02)
                        .fontCoordinator()
                }
            }
            Spacer()
            Text(convertTimerText).font(.paragraph03()).foregroundStyle(Color.grey02).fontCoordinator()
        }
        .padding(.horizontal,20)
        .frame(height: 60)
        .background(Color.grey03)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    var convertTimerText:String{
        switch durationDateType {
        case .day:
            return timerListItem.createdAt.dayFormat
        case .week,.month:
            return timerListItem.createdAt.weekAndMonthFormat
        }
    }
}
fileprivate extension Date{
    var dayFormat:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(languageCode: .english, script: .armenian, languageRegion: .southKorea)
        return dateFormatter.string(from: self)
    }
    var weekAndMonthFormat:String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(languageCode: .english, script: .armenian, languageRegion: .southKorea)
        return dateFormatter.string(from: self)
    }
}
