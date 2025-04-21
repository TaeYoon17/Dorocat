//
//  ICloudSyncController>Action.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import Foundation
import ComposableArchitecture

import CloudKit

extension ICloudSyncFeature {
    struct ActionReducer: ICloudSyncControllerProtocol {
        @Dependency(\.analyzeAPIClients) var analyzeAPIClient
        
        /// 로딩 애니메이션을 돌아가게 하면서 analyzeAPIClient에 refresh 요청을 하는 것!!
        func refreshTapped(
            state: inout ICloudSyncFeature.State
        ) -> Effect<ICloudSyncFeature.Action> {
            if !state.isLoading {
                state.isLoading = true
                return .run { _ in
                    await analyzeAPIClient.refresh()
                }
            }
            return .none
        }
        
        /// 자동 동기화가 켜진것을 알려주는 것!
        func isAutomaticSyncEnabled(
            state: inout ICloudSyncFeature.State,
            isEnabled: Bool
        ) -> Effect<ICloudSyncFeature.Action> {
            state.isAutomaticSyncEnabled = isEnabled
            return .run { _ in
                await analyzeAPIClient.setAutomaticSync(isEnabled)
            }
        }
        
        /// 싱크를 켜고 그에 따른 변화를 기다린다!!
        func isSyncEnabled(
            state: inout ICloudSyncFeature.State,
            isEnabled: Bool
        ) -> Effect<ICloudSyncFeature.Action> {
            .run { send in
                let status = await analyzeAPIClient.setICloudAccountState(isEnabled)
                await send(.iCloudStatusRouter(status), animation: .default)
            }
        }
    }
}
