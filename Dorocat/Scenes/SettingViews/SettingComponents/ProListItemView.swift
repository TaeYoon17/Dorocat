//
//  ProListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
struct ProListItemView: View {
    var action: ()->()
    var body: some View {
        VStack(spacing:10){
            HStack{
                HStack(spacing:6,content: {
                    Text("Dorocat")
                        .font(.paragraph02(.bold))
                        .foregroundStyle(.doroWhite)
                        .fontCoordinator()
                    Text("Purrs")
                        .frame(height:20)
                        .font(.paragraph02(.bold))
                        .foregroundStyle(.doroPink).fontCoordinator()
                })
                Spacer()
                Button(action: {
                    action()
                }, label: {
                    Text("Learn More")
                        .font(.paragraph03(.bold))
                        .fontCoordinator()
                        .frame(height: 20)
                        .foregroundStyle(.doroWhite)
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
//            Text("Remove ads and unlock all future features.").font(.paragraph04).foregroundStyle(.grey02)
        }
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}
