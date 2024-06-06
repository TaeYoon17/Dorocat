//
//  TimerSessionFeature.swift
//  Dorocat
//
//  Created by Developer on 5/9/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TimerSessionFeature{
    @ObservableState struct State: Equatable{
        var selectedSession:SessionItem = .init(name: "")
        var sessions:[SessionItem] = []
    }
    @Dependency(\.pomoSession) var session
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.haptic) var haptic
    enum Action:Equatable{ // 키패드 접근을 어떻게 할 것인지...
        case delegate(Delegate)
        case setSelectedSession(SessionItem)
        case allSessions([SessionItem])
        case sessionTapped(SessionItem)
        enum Delegate: Equatable{
            case cancel
            case setSelectSession(SessionItem)
        }
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            case .setSelectedSession(let typeName):
                state.selectedSession = typeName
                return .run { send in
                    let items = await session.items
                    await send(.allSessions(items))
                }.merge(with: .run(operation: { send in
                    await haptic.impact(style: .soft)
                }))
            case .allSessions(let sessions):
                state.sessions = sessions
                return .none
            case .sessionTapped(let session):
                state.selectedSession = session
                return .run { send in
                    await self.session.setSelectedSession(session)
                    await send(.delegate(.setSelectSession(session)))
                    await dismiss()
                }.merge(with: .run(operation: { send in
                    await haptic.impact(style: .soft)
                }))
            }
        }
    }
}
