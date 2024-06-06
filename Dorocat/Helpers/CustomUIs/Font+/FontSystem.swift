//
//  FontSystem.swift
//  Dorocat
//
//  Created by Developer on 4/27/24.
//

import Foundation
enum FontSystem{
    case header01
    case header02
    case header03
    case header04
    case button
    case paragraph02(_ weight:FontWeight)
    case paragraph03(_ weight:FontWeight)
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
    var lineHeight: CGFloat{
        switch self {
        case .header01: -1
        case .header02: -1
        case .header03: 48
        case .header04: 40
        case .button: -1
        case .paragraph02: 24
        case .paragraph03: 20
        case .paragraph04: 18
        }
    }
}
