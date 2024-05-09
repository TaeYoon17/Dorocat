//
//  FontManager.swift
//  Dorocat
//
//  Created by Developer on 4/27/24.
//

import SwiftUI
import UIKit
enum FontName:String,FontProvider{
    case darumadropOne
    case rubik
    func getFont(fontSystem: FontSystem) -> Font {
        guard let font = DoroFontManager.shared.fontItems[self]?.getFont(fontSystem: fontSystem) else {
            fatalError("여기 폰트 없음!!")
        }
        return font
    }
    
    func getUIFont(fontSystem: FontSystem) -> UIFont {
        guard let font = DoroFontManager.shared.fontItems[self]?.getUIFont(fontSystem: fontSystem) else{
            fatalError("여기 폰트 없음!!")
        }
        return font
    }
}
fileprivate final class DoroFontManager{
    static let shared = DoroFontManager()
    private(set) lazy var fontItems: [FontName: FontProvider] = [:]
    private init(){
        fontItems = [
            .darumadropOne: DarumadropOne(),
            .rubik: Rubik()
        ]
    }
    
    
}
extension DoroFontManager{
    struct Rubik:FontProvider{
        let regular = "Rubik-Regular"
        let medium = "Rubik-Medium"
        func getFont(fontSystem: FontSystem) -> Font {
            return switch fontSystem{
            case .header01,.header02,.header03,.header04: .custom(regular, size: fontSystem.size)
            case .button: .custom(medium, size: fontSystem.size)
            case .paragraph02(let weight),.paragraph03(let weight):
                switch weight{
                case .bold: Font.custom(medium, size: fontSystem.size)
                case .regular: Font.custom(regular, size: fontSystem.size)
                }
            case .paragraph04: .custom(regular, size: fontSystem.size)
            }
        }
        func getUIFont(fontSystem: FontSystem) -> UIFont {
            return switch fontSystem{
            case .header01,.header02,.header03,.header04: UIFont(name: regular, size: fontSystem.size)!
            case .button: UIFont(name: regular, size: fontSystem.size)!
            case .paragraph02(let weight),.paragraph03(let weight):
                switch weight{
                case .bold: UIFont(name:medium, size: fontSystem.size)!
                case .regular: UIFont(name:regular, size: fontSystem.size)!
                }
            case .paragraph04: UIFont(name:regular, size: fontSystem.size)!
            }
        }
    }
}
extension DoroFontManager{
    struct DarumadropOne:FontProvider{
        let regular = "DarumadropOne-Regular"
        func getUIFont(fontSystem: FontSystem) -> UIFont {
            
            return UIFont(name:regular, size: fontSystem.size)!
        }
        func getFont(fontSystem: FontSystem)->Font{
            return .custom(regular, size: fontSystem.size)
        }
    }
}
