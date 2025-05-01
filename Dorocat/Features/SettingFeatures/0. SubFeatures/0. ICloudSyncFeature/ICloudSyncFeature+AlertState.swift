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
    
    static var openAutoSyncEnable: Self {
        AlertState(
            title: {
                TextState("Enable Automatic Sync?")
            },
            actions: {
                ButtonState(role: .none, action: .send(.enableAutomaticSync(true))) {
                    TextState("Enable")
                }
                ButtonState(role: .cancel, action: .send(.enableAutomaticSync(false))) {
                    TextState("Disable")
                }
            },
            message: {
                TextState("Turning on automatic sync ensures changes are saved and updated seamlessly.")
            }
        )
    }
}
