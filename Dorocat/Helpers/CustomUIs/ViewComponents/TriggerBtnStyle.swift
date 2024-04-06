//
//  TriggerBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/4/24.
//

import SwiftUI

extension Button{
    var triggerStyle: some View{
        self.buttonStyle(TriggerBtnStyle())
    }
}
fileprivate struct TriggerBtnStyle:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        if !configuration.isPressed{
            configuration.label
                .foregroundStyle(.doroWhite)
                .font(.button)
                .padding(.vertical,19.5)
                .padding(.horizontal,28)
                .background(content: {
                    Capsule().stroke(lineWidth: 1).fill(.grey02)
                        .overlay {
                            Capsule().fill(.clear)
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 6)
                        }
                })
                .padding(.bottom,2)
                .overlay{
                    Capsule().stroke(lineWidth: 2).fill(.black)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 8)
                        .offset(y:-2)
                }
        }else{
            configuration.label.foregroundStyle(.grey02)
                .font(.button)
                .padding(.vertical,19.5)
                .padding(.horizontal,28)
                .background(
                    .black.gradient.shadow(.inner(radius: 4,y:8))
                )
                .overlay(content: {
                    Capsule()
                        .stroke(lineWidth: 1)
                        .fill(.black.opacity(0.4))
                })
                .clipShape(Capsule())
                .padding(.bottom,2)
                .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}
