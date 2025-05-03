//
//  iCloudStatusTypeDTO.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation

enum iCloudStatusTypeDTO: Equatable {
    case shouldICloudSignIn
    case startICloudSync
    case stopICloudSync
    case errorOccured(type: ErrorAlertMessageType)
    
    enum ErrorAlertMessageType: String, Identifiable {
        var id: String { self.rawValue }
        case restricted = "icloud.restricted"
        case tryThisLater = "icloud.tryThisLater"
        case unknown = "icloud.unknown"
    }
    
}
