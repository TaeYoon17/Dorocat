//
//  iCloudStatusType.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation

extension SettingFeature {
    
    enum iCloudStatusType: Equatable {
        case openICloudSignIn
        case startICloudSync
        case stopICloudSync
        case openErrorAlert(message: ErrorAlertMessageType)
        
        enum ErrorAlertMessageType: String, Identifiable {
            var id: String { self.rawValue }
            case restricted = "icloud.restricted"
            case tryThisLater = "icloud.tryThisLater"
            case unknown = "icloud.unknown"
        }
    }
    
}
