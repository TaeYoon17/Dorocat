//
//  InitialDependency.swift
//  Dorocat
//
//  Created by Developer on 4/30/24.
//

import Foundation
import Combine
import ComposableArchitecture
protocol InitialProtocol {
    var isUsed: Bool { get async } // 앱을 처음 켜는지 확인시켜줌
    func offInitial() async // 앱을 처음 켜고 나서 isUsed를 끄는 메서드
    func eventStream() async ->AsyncStream<()> // isUsed가 꺼진 후 실행하는 메서드
}
actor InitialClient: InitialProtocol {
    static let shared = InitialClient()
    private init(){}
    private let usedPassthroughSubject = PassthroughSubject<(),Never>()
    var isUsed: Bool{ UserDefaults.standard.bool(forKey: "IsUsed") }
    func offInitial() {
        UserDefaults.standard.set(true, forKey: "IsUsed")
        usedPassthroughSubject.send(())
    }
    func eventStream()->AsyncStream<()>{
        .init{ [weak self] continutaion in
            guard let self else {
                continutaion.finish()
                return
            }
            let cancellable = self.usedPassthroughSubject.sink { _ in
                continutaion.yield()
            }
            continutaion.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
fileprivate enum InitialClientKey: DependencyKey{
    static let liveValue: InitialProtocol = InitialClient.shared
}
extension DependencyValues{
    var initial: InitialProtocol{
        get{self[InitialClientKey.self]}
        set{self[InitialClientKey.self] = newValue}
    }
}
