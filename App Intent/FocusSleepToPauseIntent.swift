//
//  FocusSleepToPauseIntent.swift
//  Dorocat
//
//  Created by Developer on 5/18/24.
//

import Foundation
import AppIntents
import ActivityKit

struct FocusSleepToPauseIntent: LiveActivityIntent{
    static var title: LocalizedStringResource = "FocusSleepToPauseIntent"
    static var description = IntentDescription("Change TimerStatus")
    
    public init() { }
    
    func perform() async throws -> some IntentResult {
        // Code to perform the update goes here
        print("FocusSleepToPauseIntent 실행!!")
        ActivityIntentManager.focusSleepToPause()
        return .result()
    }
}
