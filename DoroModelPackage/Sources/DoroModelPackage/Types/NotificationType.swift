//
//  File.swift
//  DoroModelPackage
//
//  Created by Greem on 10/7/24.
//

import Foundation
public enum NotificationType:Identifiable,Hashable,Equatable{
    public var id:String{
        switch self{
        case .complete: return "complete"
        case .breakTimeToFocus: return "breakTimeToFocus"
        case .sessionComplete: return "sessionComplete"
        }
    }
    /// 1. 포모도로 타이머일 경우, 모든 사이클이 다 끝남
    /// 2. 일반 타이머일 경우, 타이머가 끝남
    case complete
    /// 1. 포모도로 타이머일 경우, 하나의 사이클이 끝남
    case sessionComplete(breakMinutes:Int)
    /// 1. 포모도로 타이머일 경우, breakTime이 끝난 후, 포커스 모드가 시작하는 경우
    case breakTimeToFocus(focusMinutes:Int)
}
