//
//  NavigationBar.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import SwiftUI

extension IcloudSyncComponents {

    struct NavigationBar: View {
        let leftAction: () -> ()
        let centerTitle: String
        
        var body: some View {
            HStack {
                Button {
                    leftAction()
                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(.cheLeft)
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                        Text("Back")
                    }
                    .font(.paragraph02(.bold))
                    .foregroundStyle(Color.grey02)
                }
                Spacer()
            }.overlay(alignment: .center) {
                Text(centerTitle) //"iCloud Setting"
                    .font(.button)
                    .foregroundStyle(Color.doroWhite)
            }
        }
    }
}

#Preview {
    IcloudSyncComponents.NavigationBar(
        leftAction: {
            print("wow world!!")
        },
        centerTitle: "hello")
}
