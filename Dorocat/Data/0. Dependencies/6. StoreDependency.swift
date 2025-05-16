//
//  StoreDependency.swift
//  Dorocat
//
//  Created by Developer on 4/26/24.
//

import Foundation
import ComposableArchitecture
import StoreKit
import StoreKitTest

protocol StoreDependency {
    var isProUser:Bool{ get }
    var products: [Product] {get} // 상품들이 무엇인지 나타내는 프로토콜
    var purchasedProductIDs:Set<String> { get }
    var refundTransactionID: Transaction.ID {get}
    func loadProducts() async throws
    func purchase() async throws
    func updatePurchasedProducts() async
    func eventAsyncStream() async -> AsyncStream<PurchaseEvent>
    func restore() async -> Bool
}

fileprivate enum StoreClientKey: DependencyKey {
    static let liveValue: StoreDependency = PurchaseManager.shared
}

extension DependencyValues {
    var store: StoreDependency {
        get{ self[StoreClientKey.self] }
        set{ self[StoreClientKey.self] = newValue }
    }
}
public extension StoreKit.Transaction {
    var isRevoked: Bool {
        // The revocation date is never in the future.
        revocationDate != nil
    }
}
