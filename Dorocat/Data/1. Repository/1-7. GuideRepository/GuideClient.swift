//
//  GuideClient.swift
//  Dorocat
//
//  Created by Developer on 6/6/24.
//

import Foundation
actor GuideClient: GuideProtocol {
    
    var goLeft: Bool {
        get{ UserDefaults.standard.bool(forKey: "goLeft") }
        set{ UserDefaults.standard.setValue(newValue, forKey: "goLeft") }
    }
    
    var goRight: Bool {
        get{ UserDefaults.standard.bool(forKey: "goRight") }
        set{ UserDefaults.standard.setValue(newValue, forKey: "goRight") }
    }
    
    var onBoarding: Bool {
        get{ UserDefaults.standard.bool(forKey: "onBoarding") }
        set{UserDefaults.standard.setValue(newValue, forKey: "onBoarding")}
    }
    
    var standByGuide: Bool {
        get{UserDefaults.standard.bool(forKey: "standByGuide")}
        set{UserDefaults.standard.setValue(newValue, forKey: "standByGuide")}
    }
    
    var startGuide: Bool {
        get{ UserDefaults.standard.bool(forKey: "startGuide") }
        set{UserDefaults.standard.setValue(newValue, forKey: "startGuide")}
    }
    
    func set(guide: Guides) async {
        self.goLeft = guide.goLeftFinished
        self.goRight = guide.goRightFinished
        self.onBoarding = guide.onBoardingFinished
        self.standByGuide = guide.standByGuide
        self.startGuide = guide.startGuide
    }
    
    func get() async -> Guides {
        Guides(
            onBoardingFinished: onBoarding,
            goLeftFinished: goLeft,
            goRightFinished: goRight,
            standByGuide: standByGuide,
            startGuide: startGuide
        )
    }
}
