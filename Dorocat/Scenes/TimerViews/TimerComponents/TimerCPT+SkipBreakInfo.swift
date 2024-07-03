//
//  TimerCPT+SkipBreakInfo.swift
//  Dorocat
//
//  Created by Greem on 7/3/24.
//

import SwiftUI
import ComposableArchitecture

extension TimerViewComponents{
    struct SkipInfo: View{
        var body: some View{
            Text("Break Time Skipped!!")
                .foregroundStyle(.doroWhite)
                .font(.paragraph03())
                .padding(.horizontal,20)
                .padding(.vertical,14)
        }
    }
}
