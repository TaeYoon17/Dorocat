//
//  ViewActionTypes.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation

extension SettingFeature {
    
    enum ViewActionType: Equatable {
        case setNotiAuthorized(Bool)
        case setNotiEnabled(Bool)
        case setHapticEnabled(Bool)
        
        case setRefundPresent(Bool)
        
        case setIcloudSync(Bool)
        
        case openIcloudSetting
        
        case openPurchase
        
        case feedbackItemTapped
    }
    
}
