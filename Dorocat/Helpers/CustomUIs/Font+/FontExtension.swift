//
//  FontExtension.swift
//  Dorocat
//
//  Created by Developer on 3/24/24.
//

import SwiftUI
import UIKit
protocol FontProvider{
    func getFont(fontSystem:FontSystem) -> Font
    func getUIFont(fontSystem:FontSystem) -> UIFont
}
enum FontWeight{
    case regular
    case bold
}

extension Font{
    static let fontName:FontName = .darumadropOne
    static var header01:Self { fontName.getFont(fontSystem: .header01) }
    static var header02: Self { fontName.getFont(fontSystem: .header02) }
    static var header03: Self { fontName.getFont(fontSystem: .header03) }
    static var header04: Self { fontName.getFont(fontSystem: .header04) }
    static var button: Self { fontName.getFont(fontSystem: .button) }
    static func paragraph02(_ weight: FontWeight = .regular) -> Self {
        fontName.getFont(fontSystem: .paragraph02(weight))
    }
    static func paragraph03(_ weight: FontWeight = .regular) -> Self {
        fontName.getFont(fontSystem: .paragraph03(weight))
    }
    static var paragraph04: Self {
        fontName.getFont(fontSystem: .paragraph04)
    }
}

