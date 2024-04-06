//
//  TriggerBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/4/24.
//

import SwiftUI

extension Button{
    func triggerStyle(scale: TriggerBtnStyle.ButtonScale) -> some View{
        self.buttonStyle(TriggerBtnStyle(scale: scale))
    }
}
struct TriggerBtnStyle:ButtonStyle{
    enum ButtonScale{
        case fixed(CGFloat)
        case flexed
    }
    var scale: ButtonScale
    func makeBody(configuration: Configuration) -> some View {
        if !configuration.isPressed{
            configuration.label
                .foregroundStyle(.doroWhite)
                .font(.button)
                .padding(.vertical,19.5)
                .padding(.horizontal,28)
                .modifier(ScaleModifier(scale: scale))
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
                .modifier(ScaleModifier(scale: scale))
        }else{
            configuration.label.foregroundStyle(.grey02)
                .font(.button)
                .padding(.vertical,19.5)
                .padding(.horizontal,28)
                .modifier(ScaleModifier(scale: scale))
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
                
        }
    }
    fileprivate struct ScaleModifier: ViewModifier{
        var scale: ButtonScale
        func body(content: Content) -> some View {
            switch scale{
            case .fixed(let width):
                content.frame(width: CGFloat(width))
            case .flexed: content
            }
        }
    }
}
