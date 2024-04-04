//
//  AnalyzeListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import Foundation
import SwiftUI

struct AnalyzeListItemView:View{
    var body: some View{
        HStack {
            HStack {
                Image(.haptic).resizable().frame(width: 20,height:20)
                Text("25m").font(.paragraph03()).foregroundStyle(.white)
            }
            Spacer()
            Text("3:53PM").font(.paragraph03()).foregroundStyle(.grey02)
        }
        .padding(.horizontal,20)
        .frame(height: 60)
        .background(.grey03)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
