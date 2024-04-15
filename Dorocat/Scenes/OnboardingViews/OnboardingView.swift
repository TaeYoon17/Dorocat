//
//  OnboardingViews.swift
//  Dorocat
//
//  Created by Developer on 4/10/24.
//

import SwiftUI
import ComposableArchitecture
struct OnboardingView: View {
    let store: StoreOf<DorocatFeature>
    var body: some View {
        
            ZStack{
                Image(.defaultBg).resizable(resizingMode: .tile)
                VStack(spacing:0) {
                    VStack(spacing:0) {
                        Image(.cat).frame(width: 304,height: 304)
                        Text("Meow...").font(.header03).foregroundStyle(.doroWhite)
                            .frame(height: 48)
                        Text("I'll help you focus and stay on track")
                            .font(.paragraph02()).foregroundStyle(.doroWhite)
                            .padding(.top,9)
                    }
                    
                }
            }.overlay(alignment: .bottom) {
                triggerBtn.padding(.bottom,97)
            }
            .background(.grey04)
    }
    var triggerBtn: some View{
        Button("Get Started"){
            store.send(.onBoardingTapped)
        }.triggerStyle(scale: .flexed)
    }
}

