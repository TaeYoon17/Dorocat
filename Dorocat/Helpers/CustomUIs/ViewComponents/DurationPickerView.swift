//
//  DurationPickerView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import Foundation
import SwiftUI
enum DurationType:String,CaseIterable,Identifiable{
    var id: String{ self.rawValue }
    case day
    case week
    case month
    var name:String{
        switch self{
        case .day:"Day"
        case .month:"Month"
        case .week:"Week"
        }
    }
}

struct DurationPickerView: View{
    @Binding var selectedDuration: DurationType
    var body: some View{
        ScrollView(.horizontal) {
            HStack(spacing:0) {
                ForEach(DurationType.allCases){ type in
                    Button(action: {
                        selectedDuration = type
                    }, label: {
                        Text(type.name)
                            .font(.paragraph02())
                            .padding(.vertical,8)
                            .padding(.horizontal,16)
                            .foregroundStyle(type == selectedDuration ? .doroWhite : .grey01)
                            .background(type == selectedDuration ? .black : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    })
                }
                Spacer()
            }.frame(height:40)
        }.padding(.leading,20)
    }
}
