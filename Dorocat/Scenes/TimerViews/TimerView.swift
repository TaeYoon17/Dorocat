//
//  TimerView.swift
//  Dorocat
//
//  Created by Developer on 3/15/24.
//

import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    var body: some View {
        WithPerceptionTracking{
            Text("Timer View!")
        }
    }
}

#Preview {
    TimerView()
}
