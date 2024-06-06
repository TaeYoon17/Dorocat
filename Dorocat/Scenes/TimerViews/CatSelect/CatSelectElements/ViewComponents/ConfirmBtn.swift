//
//  ConfirmBtn.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import ComposableArchitecture
extension CatSelectViewComponents{
    struct ConfirmBtn: View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            Button {
                store.send(.action(.doneTapped))
            } label: {
                Text("Confirm")
            }.doneStyle(vertical: 19, horizontal: 39.5)
        }
    }
}
