//
//  SessionError.swift
//  Dorocat
//
//  Created by Developer on 5/11/24.
//

import Foundation

enum SessionErrorType: String,Error{
    case addFailed_isExistItem
    
    case deleteFailed_isEssentialItem
    
    case isUpdatingSessionType
    
    enum Memory:Error {
        case updateEssentialFailed
        case updateCustomFailed
    }
    case sessionStoreInitFailed
}
