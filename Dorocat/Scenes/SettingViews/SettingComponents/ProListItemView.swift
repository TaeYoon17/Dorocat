//
//  ProListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
struct ProListItemView: View {
    var body: some View {
        VStack(spacing:10){
            HStack{
                HStack(spacing:6,content: {
                    Text("Dorocat")
                        .font(.paragraph02(.bold))
                        .foregroundStyle(.white)
                    Text("Purrs")
                        .frame(height:20)
                        .font(.paragraph03(.bold))
                        .foregroundStyle(.grey03)
                        .padding(.vertical,2)
                        .padding(.horizontal,6)
                        .background(.plus)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                })
                Spacer()
                Button(action: {
                    print("Hello world")
                }, label: {
                    Text("Learn More")
                        .font(.paragraph03(.bold))
                        .frame(height: 20)
                        .foregroundStyle(.white)
                        .padding(.vertical,12)
                        .padding(.horizontal,16)
                        .background(.black)
                        .clipShape(Capsule())
                })
            }
            .frame(height: 76)
            .padding(.leading,24)
            .padding(.trailing,16)
            .background(.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Button(action: {
                print("Hello world")
            }, label: {
                Text("Remove ads and unlock all future features.").font(.paragraph04).foregroundStyle(.grey02)
            })
        }
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}
