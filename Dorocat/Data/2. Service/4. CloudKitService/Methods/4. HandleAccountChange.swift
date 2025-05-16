//
//  4. Accoun.swift
//  Dorocat
//
//  Created by Greem on 5/14/25.
//

import Foundation
import CloudKit
import os.log

extension CloudKitService {
    /// 로그인 시, 가장 최신에 로그인 한 아이클라우드 계정에 대한 정보를 담아놓는다.
    /// 기존 계정으로 재로그인 시: 현재 로컬에 있는 데이터와 동기화한다.
    /// 다른 계정으로 로그인 시: 완전히 새로운 계정의 데이터로 바꾼다.
    ///     추후에 사용자가 기존 작업을 버릴지 말지 선택하게 한다.
    /// 추가 대응방법: 기간 및 작업 별 백업을 만들어 동기화 할 수 있게 만든다.
    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) {
        
        // 로그아웃 시 해당 기존 데이터들은 내비려 둔다.
        // 계정을 바꾸거나 새로 로그인 시, 기존 로컬 데이터에 값이 있다면 이들을 덮어 씌울 것인지 모두 삭제하고 연동작업을 진행할 것인지 물어본다.
        /// 여기 연동 작업을 요청하는 delegate 넘기기
        Task {
            await self.syncHandlers.values.asyncForEach {
                let userDTO:UserAccountStatusDTO = switch event.changeType {
                case .signIn, .switchAccounts: .signIn
                case .signOut: .signOut
                @unknown default: .signOut
                }
                await $0?.handleAccountStatusChange(userDTO)
            }
        }
    }
}
