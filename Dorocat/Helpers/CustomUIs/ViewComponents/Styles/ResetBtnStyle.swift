//
//  ResetBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import SwiftUI

extension Button{
    func resetStyle(willTap: (()->())? = nil) -> some View{
        self.buttonStyle(ResetBtnStyle(willTap: willTap))
    }
}
struct ResetBtnStyle: ButtonStyle{
    var willTap:(()->())?
    func makeBody(configuration: Configuration) -> some View {
        Image(!configuration.isPressed ? .reset : .resetActive).resizable().scaledToFit().frame(height: 60)
            .shadow(color: !configuration.isPressed ? .black.opacity(0.2) : .clear, radius: 4, y: 8)
            .overlay(alignment: .center, content: {
                configuration.label.font(.button)
                    .foregroundStyle(configuration.isPressed ? .grey02 :.doroWhite)
                    .animation(nil, value: configuration.isPressed)
                    .offset(y:-2) // 여기 올림
            })
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue == false && newValue == true{
                    willTap?()
                }
            }
    }
}
