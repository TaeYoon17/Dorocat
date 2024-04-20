//
//  DoneBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import SwiftUI
extension Button{
    func doneStyle() -> some View{
        self.buttonStyle(DoneBtnStyle())
    }
}
struct DoneBtnStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.button)
            .padding(.vertical,19.5)
            .padding(.horizontal,28)
            .foregroundStyle(.black)
            .background(.doroWhite)
            .clipShape(Capsule())
            .scaleEffect(x: !configuration.isPressed ? 1.0 : 0.9,y: !configuration.isPressed ? 1.0 : 0.9)
            .animation(.interactiveSpring,value:configuration.isPressed)
    }
}
