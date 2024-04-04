//
//  AnalyzeDurationView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI

enum AnalyzeDurationView{
    
    struct Day:View{
        var body: some View{
            VStack(spacing:38) {
                HStack {
                    Button{
                        
                    }label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("Today, Mar 22").font(.paragraph03()).foregroundStyle(.grey00)
                    Spacer()
                    Button{
                    
                    }label: {
                        Image(systemName: "chevron.right")
                    }
                }.padding(.horizontal,4)
                    .tint(.grey00)
                HStack(content: {
                    VStack(alignment:.leading,spacing:4) {
                        Text("Total Time").font(.paragraph04).foregroundStyle(.grey02)
                        Text("2h 40m")
                            .font(.header02)
                            .foregroundStyle(.white)
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
