//
//  DorocatApp.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
@main
struct DorocatApp: App {
    var body: some Scene {
        WindowGroup {
            WithPerceptionTracking {   
                DoroMainView(store: Store(initialState: DorocatFeature.State(),
                                          reducer: {
                    DorocatFeature()
                })).onAppear(){
                    for fontFamily in UIFont.familyNames {
                        for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
                            if fontName.contains("Rubik"){
                                print(fontName)
                            }
                        }
                    }
                }
            }
        }
    }
}
