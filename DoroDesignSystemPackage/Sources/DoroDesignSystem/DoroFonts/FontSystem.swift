//
//  File.swift
//  DoroDesignSystem
//
//  Created by Greem on 10/8/24.
//

import Foundation

public enum FontSystem{
    case header01
    case header02
    case header03
    case header04
    case button
    case paragraph02(_ weight:DoroFontWeight)
    case paragraph03(_ weight:DoroFontWeight)
    case paragraph04
    var size:CGFloat{
        switch self{
        case .header01: 86
        case .header02: 56
        case .header03: 36
        case .header04: 24
        case .button: 19
        case .paragraph02:16
        case .paragraph03: 14
        case .paragraph04:13
        }
    }
}
