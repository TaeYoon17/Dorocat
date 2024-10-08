//
//  ProListItemView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct ProListItemView: View {
    var action: ()->()
    var body: some View {
        VStack(spacing:10){
            HStack{
                HStack(spacing:6,content: {
                    Text("Dorocat")
                        .font(.paragraph02(.bold))
                        .foregroundStyle(Color.doroWhite)
                        .fontCoordinator()
                    Text("Purrs")
                        .frame(height:20)
                        .font(.paragraph02(.bold))
                        .foregroundStyle(Color.doroPink).fontCoordinator()
                })
                Spacer()
                Button(action: {
                    action()
                }, label: {
                    Text("Learn More")
                        .font(.paragraph03(.bold))
                        .fontCoordinator()
                        .frame(height: 20)
                        .foregroundStyle(Color.doroWhite)
                        .padding(.vertical,12)
                        .padding(.horizontal,16)
                        .background(Color.doroBlack)
                        .clipShape(Capsule())
                })
            }
            .frame(height: 76)
            .padding(.leading,24)
            .padding(.trailing,16)
            .background(Color.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
    }))
}
