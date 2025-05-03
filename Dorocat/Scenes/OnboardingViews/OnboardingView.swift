//
//  OnboardingViews.swift
//  Dorocat
//
//  Created by Developer on 4/10/24.
//

import SwiftUI
import DoroDesignSystem
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<DorocatFeature>
    var body: some View {
            ZStack{
                DefaultBG()
                    VStack(spacing:0) {
                        Rectangle().fill(.clear).frame(width: 375,height: 375)
                        Text("Meow...").font(.header03).foregroundStyle(Color.doroWhite)
                            .frame(height: 48)
                        Text("I'll help you focus and stay on track")
                            .font(.paragraph02()).foregroundStyle(Color.doroWhite)
                            .padding(.top,9)
                    }.offset(y:-78 + 35)
                Image(store.catType.imageAssetName(type: .onboardingIcon)).frame(width: 375,height: 375)
                    .offset(y:-78)
                    
            }.overlay(alignment: .bottom) {
                triggerBtn.padding(.bottom,97)
            }
            .ignoresSafeArea(.container,edges: .bottom)
            .background(Color.grey04)
    }
    var triggerBtn: some View{
        Button("Get Started"){
            store.send(.onBoardingTapped)
        }.triggerStyle(status: .getStarted) {
            store.send(.onBoardingWillTap)
        }
    }
}

