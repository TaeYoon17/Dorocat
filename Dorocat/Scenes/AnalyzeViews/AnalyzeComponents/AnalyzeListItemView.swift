//
//  AnalyzeListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import Foundation
import SwiftUI

struct AnalyzeListItemView:View{
    let durationDateType: DurationType
    let timerListItem:TimerRecordItem
    var body: some View{
        HStack {
            HStack {
                Image(.haptic).resizable().frame(width: 20,height:20)
                Text("\(timerListItem.duration)m").font(.paragraph03()).foregroundStyle(.doroWhite)
            }
            Spacer()
            Text(convertTimerText).font(.paragraph03()).foregroundStyle(.grey02)
        }
        .padding(.horizontal,20)
        .frame(height: 60)
        .background(.grey03)
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
        return dateFormatter.string(from: self)
    }
    var weekAndMonthFormat:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self)
    }
}
