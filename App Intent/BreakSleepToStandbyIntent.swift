//
//  BreakSleepToStandbyIntent.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
import AppIntents
import ActivityKit

struct BreakSleepToStandbyIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "BreakSleepToStandbyIntent"
    static var description = IntentDescription("Change TimerStatus")
    
    public init() { }
    
    func perform() async throws -> some IntentResult {
        // Code to perform the update goes here
        print("BreakSleepToStandbyIntent 실행!!")
        ActivityIntentManager.breakSleepToStandBy()
        return .result()
    }
}

