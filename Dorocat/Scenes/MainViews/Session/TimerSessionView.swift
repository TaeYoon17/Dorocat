//
//  TimerSessionView.swift
//  Dorocat
//
//  Created by Developer on 5/9/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct TimerSessionView: View {
    @Bindable var store: StoreOf<TimerSessionFeature>
    var body: some View {
        VStack(spacing:0,content: {
            Text("Select Session").font(.header04).foregroundStyle(Color.doroWhite)
                .padding(.bottom,12)
            Spacer()
        
            VStack(spacing:12) {
                ForEach(store.sessions){ item in
                    SessionBtn(name: item.name,
                               isSelected: item.id == store.selectedSession.id) {
                        store.send(.sessionTapped(item))
                    }
                }
            }
            Spacer()
        })
        .clipShape(.rect(topLeadingRadius: 24, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 24, style: .circular))
        .padding(.top,40).padding(.bottom,26)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
    @ViewBuilder func SessionBtn(name: String,isSelected:Bool,action:@escaping ()->()) -> some View{
        Button{
            action()
        }label: {
            ZStack{
                Text(name).font(.button)
            }.frame(width: 140,height: 60)
                .foregroundStyle(isSelected ? Color.doroBlack : Color.grey01)
                .background(isSelected ? Color.doroWhite: Color.grey03)
                .clipShape(Capsule())
        }.frame(width: 140,height: 60)
    }
    @ViewBuilder var tempSelectBtn: some View{
        Button{
            print("하이하이")
        }label: {
            Text("Focus")
                .font(.button)
                .padding(.horizontal,48.5)
                .padding(.vertical,19)
                .foregroundStyle(Color.doroBlack)
                .background(Color.doroWhite)
                .clipShape(Capsule())
        }.frame(width: 140,height: 60)
    }
    var hereBtn: some View{
        Button{
            print("하이하이")
        }label: {
            Text("Work")
                .font(.button)
                .padding(.horizontal,48.5)
                .padding(.vertical,19)
                .foregroundStyle(Color.grey01)
                .background(Color.grey03)
                .clipShape(Capsule())
        }.frame(width: 140,height: 60)
    }
}
