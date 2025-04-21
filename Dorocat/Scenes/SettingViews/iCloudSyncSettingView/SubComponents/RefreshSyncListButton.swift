//
//  RefreshSyncButton.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import SwiftUI
import ComposableArchitecture
import DoroDesignSystem


extension IcloudSyncComponents {
    struct RefreshSyncListButton: View {
        let title: String
        let description: String
        let action: () -> ()
        var body: some View {
            HStack(content: {
                Text("Last Synced Date").font(.paragraph02()).foregroundStyle(Color.doroWhite).fontCoordinator()
                Spacer()
                HStack {
                    Text("1 minutes ago...")
                        .font(.paragraph04)
                        .foregroundStyle(Color.grey02)
                        .fontCoordinator().fontCoordinator()
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .fontWeight(.heavy)
                            .foregroundStyle(Color.doroBlack)
                            .padding(4)
                            .background(content: {
                                Circle().fill(Color.doroWhite)
                            })
                            .padding(.trailing,17)
                    }
                }
            })
            .frame(height: 68)
            .padding(.leading,23)
            .background(Color.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    IcloudSyncComponents.RefreshSyncListButton(
        title: "Last Sync",
        description: "1 munites ago...",
        action: {
            print("Hello world!!")
        })
}
