//
//  SettingBottom.swift
//  Dorocat
//
//  Created by Developer on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

extension SettingViewComponents{
    struct Bottom:View {
        let store: StoreOf<SettingFeature>
        var body: some View {
            VStack(spacing:0) {
                Image(store.catType.imageAssetName(type: .settingInfoLogo)).resizable().scaledToFit().frame(width: 100, height: 100).onTapGesture {
                    
                }
                HStack(spacing:8){
                    Link(destination: URL(string: "https://chip-goose-fa5.notion.site/Dorocat-Terms-7e6e5404ae984bde8963f25d12eb5144?pvs=74")!){
                        Text("Terms of Service").font(.paragraph03(.bold)).foregroundStyle(.grey02)
                    }
                    Text("·").font(.paragraph02(.bold)).foregroundStyle(.doroWhite)
                    Link(destination: URL(string: "https://chip-goose-fa5.notion.site/Dorocat-Privacy-Policy-ad164a6289994922a39c4ba1e69a7621")!) {
                        Text("Privacy Policy").font(.paragraph03(.bold)).foregroundStyle(.grey02)
                    }
                }
            }
        }
    }
}
