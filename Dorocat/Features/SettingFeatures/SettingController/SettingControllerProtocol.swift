//
//  SettingController.swift
//  Dorocat
//
//  Created by Greem on 4/12/25.
//

import Foundation
import ComposableArchitecture


protocol SettingControllerProtocol {
    
    /// 각 기능마다 뷰 액션 처리를 통합시키기
    func makeReducer(
        state: inout SettingFeature.State,
        act: SettingFeature.ViewActionType
    ) -> Effect<SettingFeature.Action>
    
    /// 노티 토글러 액션
    func notiEnableToggle(
        state: inout SettingFeature.State,
        isEnabled: Bool
    ) -> Effect<SettingFeature.Action>
    
    /// 노티 인증 토글 -> 토글 액션을 하나로 줄일 필요가 있다.
    func notiAuthorizedToggle(
        state: inout SettingFeature.State,
        isAuthorized: Bool
    ) -> Effect<SettingFeature.Action>
    
    /// 햅틱 토글
    func hapticsToggle(
        state: inout SettingFeature.State,
        isOn: Bool
    ) -> Effect<SettingFeature.Action>
    
    /// 환불 토글
    func refundPresentToggle(
        state: inout SettingFeature.State,
        isOn: Bool
    ) -> Effect<SettingFeature.Action>
    
    /// 아이클라우드 동기화 토글
    func iCloudSyncToggle(
        state: inout SettingFeature.State,
        isOn: Bool
    ) -> Effect<SettingFeature.Action>
    
    func openIcloudSetting(
        state: inout SettingFeature.State
    ) -> Effect<SettingFeature.Action>
    
    /// 구매 버튼 탭
    func openPurchaseTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action>
    
    /// 피드백 버튼 탭
    func feedbackItemTapped(state: inout SettingFeature.State) -> Effect<SettingFeature.Action>
    
}

extension SettingControllerProtocol {
    func makeReducer(
        state: inout SettingFeature.State,
        act: SettingFeature.ViewActionType
    ) -> Effect<SettingFeature.Action> {
        switch act {
        case .setNotiEnabled(let isOn):
            self.notiEnableToggle(state: &state, isEnabled: isOn)
        case .setNotiAuthorized(let isOn):
            self.notiAuthorizedToggle(state: &state, isAuthorized: isOn)
        case .setHapticEnabled(let isOn):
            self.hapticsToggle(state: &state, isOn: isOn)
        case .setRefundPresent(let isOn):
            self.refundPresentToggle(state: &state, isOn: isOn)
        case .setIcloudSync(let isOn):
            self.iCloudSyncToggle(state: &state, isOn: isOn)
        case .openPurchase:
            self.openPurchaseTapped(state: &state)
        case .feedbackItemTapped:
            self.feedbackItemTapped(state: &state)
        case .openIcloudSetting:
            self.openIcloudSetting(state: &state)
        }
    }
}
