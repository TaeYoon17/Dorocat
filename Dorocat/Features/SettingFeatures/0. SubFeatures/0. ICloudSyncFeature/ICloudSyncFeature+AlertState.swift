//
//  ICloudSyncFeature+AlertState.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

extension AlertState where Action == ICloudSyncFeature.Action.Alert {
    
    static func openErrorAlert(title: String, message: String) -> Self {
        AlertState(
            title: { TextState(title) },
            actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            },
            message: {
                TextState(message)
            }
        )
    }
    
    static var openSignIn: Self {
        AlertState(
            title: {
                TextState("Can not support iCloud sync")
            },
            actions: {
                ButtonState(role: .none, action: .send(.showICloudSettings)) {
                    TextState("Open iCloud settings")
                }
                ButtonState(role: .cancel) {
                    TextState("Do it later")
                }
            },
            message: {
                TextState("You should sign in your iCloud account.")
            }
        )
    }
}
