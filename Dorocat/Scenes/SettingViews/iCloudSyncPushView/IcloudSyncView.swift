//
//  IcloudSyncView.swift
//  Dorocat
//
//  Created by Greem on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

struct IcloudSyncView: View {
    
    @Bindable var store: StoreOf<ICloudSyncFeature>
    
    var body: some View {
        Text("IcloudSyncView")
    }
}
