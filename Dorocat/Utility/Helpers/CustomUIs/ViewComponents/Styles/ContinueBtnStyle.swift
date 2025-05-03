//
//  ContinueBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/27/24.
//

import SwiftUI

extension Button{
    func continueBtnStyle(willTap:(()->())? = nil) -> some View{
        self.buttonStyle(ContinueBtnStyle(willTap: willTap))
    }
}
struct ContinueBtnStyle: ButtonStyle{
    var willTap:(()->())?
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.button)
            .padding(.horizontal,28)
            .padding(.vertical,19.5)
            .background(.doroPink)
            .foregroundStyle(.grey04)
            .clipShape(Capsule())
            .scaleEffect(x: !configuration.isPressed ? 1.0 : 0.9,y: !configuration.isPressed ? 1.0 : 0.9)
            .animation(.interactiveSpring,value:configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue == false && newValue == true{
                    willTap?()
                }
            }
    }
}
