//
//  File.swift
//  DoroDesignSystem
//
//  Created by Greem on 10/7/24.
//

import SwiftUI

extension Color{
    static var doroBlack:Color{ Color(hex: "#121212") }
    static var doroPink:Color{ Color(hex: "#FFB190") }
    static var doroWhite:Color{ Color(hex: "#D2D2D2") }
    static var grey00:Color{ Color(hex:"#A9A7A7") }
    static var grey01:Color{ Color(hex:"#6F6F6F") }
    static var grey02:Color{ Color(hex:"#6C6C6C") }
    static var grey03:Color{ Color(hex:"#2C2C2C") }
    static var grey04:Color{ Color(hex:"#222222") }
}

extension UIColor{
    static var doroBlack: UIColor{ UIColor(Color.doroBlack) }
    static var doroPink: UIColor{ UIColor(Color.doroPink) }
    static var doroWhite: UIColor{ UIColor(Color.doroWhite) }
    static var grey00: UIColor{ UIColor(Color.grey00) }
    static var grey01: UIColor{ UIColor(Color.grey01) }
    static var grey02: UIColor{ UIColor(Color.grey02) }
    static var grey03: UIColor{ UIColor(Color.grey03) }
    static var grey04: UIColor{ UIColor(Color.grey04) }
}
