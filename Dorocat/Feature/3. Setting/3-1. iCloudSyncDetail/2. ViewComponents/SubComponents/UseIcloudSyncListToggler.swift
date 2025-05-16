//
//  UseIcloudSyncToggler.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import SwiftUI
import ComposableArchitecture
import DoroDesignSystem

extension IcloudSyncComponents {
    struct UseIcloudSyncListToggler: View {
        let title: String
        @Binding var isOn: Bool
        
        var body: some View {
            HStack{
                Text(title)
                    .font(.paragraph02(.bold))
                    .foregroundStyle(Color.doroWhite)
                    .fontCoordinator()
                Spacer()
                DoroTogglerView(
                    isOn: $isOn,
                    toggleSize: .large
                )
                .offset(y: 4)
                .frame(width: 60, height: 40)
            }
            .frame(height: 76)
            .padding(.leading,24)
            .padding(.trailing,16)
            .background(Color.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
