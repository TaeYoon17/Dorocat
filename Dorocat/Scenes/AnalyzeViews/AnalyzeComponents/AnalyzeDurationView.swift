//
//  AnalyzeDurationView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
enum AnalyzeDurationView{
    struct Day:View{
        let store: StoreOf<AnalyzeFeature>
        var body: some View{
            VStack(spacing:38) {
                HStack {
                    Button{ store.send(.leftArrowTapped) }label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("Today, Mar 22").font(.paragraph03()).foregroundStyle(.grey00)
                    Spacer()
                    Button{ store.send(.rightArrowTapped) }label: {
                        Image(systemName: "chevron.right")
                    }
                }.padding(.horizontal,4).tint(.grey00)
                HStack(content: {
                    VStack(alignment:.leading,spacing:4) {
                        Text("Total Time").font(.paragraph04).foregroundStyle(.grey02)
                        Text(store.totalTime)
                            .font(.header03)
                            .foregroundStyle(.doroWhite)
                    }
                    Spacer()
                }).padding(.bottom,4)
            }
            .padding(.vertical,30)
            .padding(.horizontal,24)
            .background(.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    struct Week:View {
        var body: some View {
            Text("H")
        }
    }
    struct Month: View{
        var body: some View{
            Text("M")
        }
    }
}
