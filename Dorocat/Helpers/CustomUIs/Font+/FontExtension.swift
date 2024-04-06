//
//  FontExtension.swift
//  Dorocat
//
//  Created by Developer on 3/24/24.
//

import SwiftUI

extension Font{
    static var header01:Self { .custom("Rubik-Regular", size: 86) }
    static var header02: Self { .custom("Rubik-Regular", size: 56) }
    static var header03: Self { .custom("Rubik-Regular", size: 36) }
    static var header04: Self { .custom("Rubik-Regular", size: 24) }
    static var button: Self { .custom("Rubik-Medium", size: 18) }
    static func paragraph02(_ weight: FontWeight = .regular) -> Self {
        return switch weight{
        case .bold: Font.custom("Rubik-Medium", size: 16)
        case .regular: Font.custom("Rubik-Regular", size: 16)
        }
    }
    static func paragraph03(_ weight: FontWeight = .regular) -> Self {
        return switch weight{
        case .bold: Font.custom("Rubik-Medium", size: 14)
        case .regular: Font.custom("Rubik-Regular", size: 14)
        }
    }
    static var paragraph04: Self {
        .custom("Rubik-Regular", size: 12)
    }
}
enum FontWeight{
    case regular
    case bold
}
