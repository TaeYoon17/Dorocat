//
//  TimerCPT+Guides.swift
//  Dorocat
//
//  Created by Developer on 6/12/24.
//

import SwiftUI
import ComposableArchitecture

extension TimerViewComponents{
    enum Guide{
        struct GoLeft:View{
            var body: some View{
                Image(.leftGuide).resizable()
                    .scaledToFit()
                    .frame(height:314)
                    .overlay(alignment: .leading) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.leading,4)
                    }
            }
        }
        struct GoRight: View {
            var body: some View {
                Image(.rightGuide).resizable()
                    .scaledToFit()
                    .frame(height: 314)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16,height: 16)
                            .foregroundStyle(.grey01)
                            .padding(.trailing,4)
                    }
            }
        }
        struct StandBy:View{
            var body: some View{
                Text("Let the cat snooze and get started!")
                    .foregroundStyle(.doroWhite)
                    .font(.paragraph03())
                    .padding(.horizontal,20)
                    .padding(.vertical,14)
            }
        }
        struct Focus: View{
            var body: some View{
                Text("Cat's asleep!")
                    .foregroundStyle(.doroWhite)
                    .font(.paragraph03())
                    .padding(.horizontal,20)
                    .padding(.vertical,14)
            }
        }
    }
}
