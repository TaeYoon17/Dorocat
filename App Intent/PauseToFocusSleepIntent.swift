//
//  PauseToFocusSleepIntent.swift
//  Dorocat
//
//  Created by Developer on 5/19/24.
//

import Foundation
import AppIntents
import ActivityKit

struct PauseToFocusSleepIntent: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "PauseToFocusSleepIntent"
    static var description = IntentDescription("Change TimerStatus")
    
    public init() { }
    
    func perform() async throws -> some IntentResult {
        // Code to perform the update goes here
        print("PauseToFocusSleepIntent 실행!!")
        ActivityIntentManager.pauseToFocusSleep()
        return .result()
    }
}
