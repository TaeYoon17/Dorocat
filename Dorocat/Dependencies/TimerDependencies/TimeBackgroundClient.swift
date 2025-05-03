//
//  TimeBackgroundDependency.swift
//  Dorocat
//
//  Created by Developer on 3/29/24.
//

import Foundation
import ComposableArchitecture

actor TimeBackgroundClient:TimeBackgroundProtocol{
    var date: Date?{
        let interval = UserDefaults.standard.double(forKey: "timerBackground")
        return interval < 0 ? nil : Date(timeIntervalSince1970: interval)
    }
    var timerStatus: TimerStatus{
        let timerBackStatus = UserDefaults.standard.string(forKey: "timerBackStatus") ?? ""
        return TimerStatus.create(name: timerBackStatus)
    }
    func set(date:Date) async{
        let interval = date.timeIntervalSince1970
        UserDefaults.standard.set(interval,forKey: "timerBackground")
    }
    func set(timerStatus:TimerStatus) async{
        UserDefaults.standard.set(timerStatus.name, forKey: "timerBackStatus")
    }
}
