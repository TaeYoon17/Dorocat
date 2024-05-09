//
//  UIFontExtension.swift
//  Dorocat
//
//  Created by Developer on 4/27/24.
//

import Foundation
import UIKit

extension UIFont{
    static let fontName:FontName = .darumadropOne
    
    static var header01:UIFont { fontName.getUIFont(fontSystem: .header01) }
    static var header02: UIFont { fontName.getUIFont(fontSystem: .header02) }
    static var header03: UIFont { fontName.getUIFont(fontSystem: .header03) }
    static var header04: UIFont { fontName.getUIFont(fontSystem: .header04) }
    static var button: UIFont { fontName.getUIFont(fontSystem: .button) }
    static func paragraph02(_ weight: FontWeight = .regular) -> UIFont {
        fontName.getUIFont(fontSystem: .paragraph02(weight))
    }
    static func paragraph03(_ weight: FontWeight = .regular) -> UIFont {
        fontName.getUIFont(fontSystem: .paragraph03(weight))
    }
    static var paragraph04: UIFont {
        fontName.getUIFont(fontSystem: .paragraph04)
    }
}
