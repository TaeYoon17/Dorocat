//
//  ResetBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import SwiftUI

extension Button{
    func resetStyle() -> some View{
        self.buttonStyle(ResetBtnStyle())
    }
}
struct ResetBtnStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.button)
            .font(.button)
            .foregroundStyle(.doroWhite)
            .padding(.horizontal,20)
            .padding(.vertical,13.5)
            .background(.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(x: !configuration.isPressed ? 1.0 : 0.9,y: !configuration.isPressed ? 1.0 : 0.9)
            .animation(.interactiveSpring,value:configuration.isPressed)
    }
}
