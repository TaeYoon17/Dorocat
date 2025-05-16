//
//  UseAutomaticallySyncToggler.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import SwiftUI
extension IcloudSyncComponents {
    struct UseAutomaticallySyncListToggler: View {
        let title: String
        let description: String
        @Binding var isOn: Bool
        var body: some View {
            SettingListItem.Toggler(
                title: title,
                description: description,
                isOn: $isOn
            )
        }
    }
}

#Preview {
    IcloudSyncComponents.UseAutomaticallySyncListToggler(
        title: "Test",
        description: "Hello world",
        isOn: .constant(false)
    )
}
