//
//  DoneBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/20/24.
//

import SwiftUI
import DoroDesignSystem

extension Button{
    func doneStyle(vertical:CGFloat = 19.5,horizontal:CGFloat = 28) -> some View{
        self.buttonStyle(DoneBtnStyle(vertical: vertical, horizontal: horizontal))
    }
}
struct DoneBtnStyle: ButtonStyle{
    let vertical:CGFloat
    let horizontal:CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.button)
            .fontCoordinator()
            .padding(.vertical,vertical)
            .padding(.horizontal,horizontal)
            .foregroundStyle(Color.doroBlack)
            .background(Color.doroWhite)
            .clipShape(Capsule())
            .scaleEffect(x: !configuration.isPressed ? 1.0 : 0.9,y: !configuration.isPressed ? 1.0 : 0.9)
            .animation(.interactiveSpring,value:configuration.isPressed)
    }
}
