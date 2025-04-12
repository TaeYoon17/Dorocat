//
//  SettingFeatures+AlertState.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture

extension AlertState where Action == SettingFeature.Action.Alert {
    
    static func openErrorAlert(message:String) -> Self {
        AlertState(
            title: { TextState("Can't now iCloud sync") },
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
    
    static var mailFeedbackNotAvailable: Self {
        AlertState(
            title: {
                TextState("Can't open the Mail app.")
            },
            actions: {
                ButtonState(role: .cancel) {
                    TextState("Confirm")
                }
            },
            message: {
                TextState("Download Mail app from the App Store.")
            }
        )
    }
}
