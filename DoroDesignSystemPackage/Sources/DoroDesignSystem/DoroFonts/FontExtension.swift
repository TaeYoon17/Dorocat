//
//  File.swift
//  DoroDesignSystem
//
//  Created by Greem on 10/8/24.
//

import SwiftUI

@MainActor public extension Font{
    static let fontName:FontName = .darumadropOne
    
    static var header01:Self { fontName.getFont(fontSystem: .header01) }
    static var header02: Self { fontName.getFont(fontSystem: .header02) }
    static var header03: Self { fontName.getFont(fontSystem: .header03) }
    static var header04: Self { fontName.getFont(fontSystem: .header04) }
    static var button: Self { fontName.getFont(fontSystem: .button) }
    
    static func paragraph02(_ weight: DoroFontWeight = .regular) -> Self {
        fontName.getFont(fontSystem: .paragraph02(weight))
    }
    static func paragraph03(_ weight: DoroFontWeight = .regular) -> Self {
        fontName.getFont(fontSystem: .paragraph03(weight))
    }
    
    static var paragraph04: Self {
        fontName.getFont(fontSystem: .paragraph04)
    }
    static func custom(name: String,size: CGFloat) -> Self {
        .custom(name, size: size)
    }
}
@MainActor public extension UIFont{
    static let fontName:FontName = .darumadropOne
    
    static var header01:UIFont { fontName.getUIFont(fontSystem: .header01) }
    static var header02: UIFont { fontName.getUIFont(fontSystem: .header02) }
    static var header03: UIFont { fontName.getUIFont(fontSystem: .header03) }
    static var header04: UIFont { fontName.getUIFont(fontSystem: .header04) }
    static var button: UIFont { fontName.getUIFont(fontSystem: .button) }
    
    static func paragraph02(_ weight: DoroFontWeight = .regular) -> UIFont {
        fontName.getUIFont(fontSystem: .paragraph02(weight))
    }
    static func paragraph03(_ weight: DoroFontWeight = .regular) -> UIFont {
        fontName.getUIFont(fontSystem: .paragraph03(weight))
    }
    
    static var paragraph04: UIFont {
        fontName.getUIFont(fontSystem: .paragraph04)
    }
}
