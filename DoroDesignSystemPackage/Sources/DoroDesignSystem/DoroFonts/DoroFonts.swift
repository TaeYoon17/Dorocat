//
//  File.swift
//  DoroDesignSystem
//
//  Created by Greem on 10/7/24.
//

import SwiftUI


protocol FontProvider{
    func getFont(fontSystem:FontSystem) -> Font
    func getUIFont(fontSystem: FontSystem) -> UIFont
}
public enum DoroFontWeight{
    case regular
    case bold
}

public enum CustomFonts {
    @MainActor public static func registerCustomFonts() {
        guard let montURL = Bundle.designSystem.url(forResource: "DarumadropOne-Regular.ttf", withExtension: nil) else {
            fatalError("Can't load, DarumadropOne-Regular")
        }
        CTFontManagerRegisterFontsForURL(montURL as CFURL, .process, nil)
        for f in RubikWeight.allCases{
            let font = "Rubik-\(f.name).ttf"
            guard let url = Bundle.designSystem.url(forResource: font, withExtension: nil) else {
                fatalError("Can't load it \(font)")
                return
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
public enum RubikWeight:CaseIterable{
    case regular
    case black
    case bold
    case extraBold
    case light
    case medium
    case semibold
    var name:String{
        switch self{
        case .regular:"Regular"
        case .black: "Black"
        case .bold: "Bold"
        case .extraBold: "ExtraBold"
        case .light: "Light"
        case .medium: "Medium"
        case .semibold: "SemiBold"
        }
    }
    var textStyle:Font.Weight{
        switch self{
        case .regular: .regular
        case .black: .black
        case .bold: .bold
        case .extraBold: .heavy
        case .light:.ultraLight
        case .medium:.medium
        case .semibold:.semibold
        }
    }
}
