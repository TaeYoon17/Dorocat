//
//  StoreKitExampleCode.swift
//  Dorocat
//
//  Created by Developer on 4/26/24.
//

import Foundation
import StoreKit
import Combine

enum PurchaseError: Error {
    case noneProItem
    case pending
    case failed
    case cancelled
}

enum PurchaseEvent {
    case userProUpdated(Bool)
}

final class PurchaseManager:StoreDependency {
    private static let label:String = "com.tistory.arpple.Dorocat.ProVersion"
    var isProUser: Bool{ UserDefaults.standard.bool(forKey: Self.label) }
    var refundTransactionID: Transaction.ID = 0
    static let shared = PurchaseManager()
    // 원래 product ID들을 이미 알고 있어야한다.
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs:Set<String> = Set<String>()
    private var productsLoaded = false
    private let event: PassthroughSubject<PurchaseEvent,Never> = .init()
    private var updatesTask: Task<Void, Never>? = nil
    
    private init() { // 싱글톤으로 구현
        Task{ await updatePurchasedProducts() }
        startObservingTransactionUpdates()
    }
    
    // product ID를 통해서 상품의 정보를 가져오기
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: [PurchaseManager.label])
        self.productsLoaded = true
    }
    
    // 상품 구매하기
    private func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case let .success(.verified(transaction)):
            successTransaction(transaction: transaction)
            await transaction.finish()
        case let .success(.unverified(_, error)):
            // 구매를 성공했으나, verified 실패
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or // approval from Ask to Buy
            throw PurchaseError.pending
        case .userCancelled: break
        @unknown default: break
        }
    }
    func purchase() async throws{
        guard let product = products.first else {throw PurchaseError.noneProItem}
        try await purchase(product)
    }
    // 구매한 상품들에 대한 업데이트 - 환불 대응하기
    func updatePurchasedProducts() async {
        // transaction: 고객이 앱에서 제품을 구매한 것을 나타내는 정보입니다.
        var isExistTransaction = false
        for await result in Transaction.currentEntitlements {
            print("한번은 있었다!!")
            isExistTransaction = true
            // 거래 중 확인된 내역들
            guard case .verified(let transaction) = result else { continue }
            // 거래의 취소날짜가 없는 경우 -> 구매한 내역에 추가
            if transaction.revocationDate == nil {
                self.successTransaction(transaction: transaction)
            } else {
                // 거래가 취소된 경우
                self.failTransaction(transaction: transaction)
            }
        }
        if !isExistTransaction {
            resetTransaction()
        }
    }
    
    func eventAsyncStream() async -> AsyncStream<PurchaseEvent> {
        .init { [weak self] continuation in
            guard let self else {continuation.finish(); return}
            let cancellable = self.event.sink { continuation.yield($0) }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    func restore() async -> Bool{
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return self.isProUser
        }catch{
            return false
        }
    }
}

//MARK: -- 옵저빙 관련 로직 처리
extension PurchaseManager{
    func startObservingTransactionUpdates() {
        updatesTask = Task(priority: .background) { [weak self] in
            for await verificatioResults in Transaction.updates {
                print("인증 결과",verificatioResults)
                switch verificatioResults{
                case .verified(let transaction):
                    if transaction.revocationDate != nil{
                        self?.failTransaction(transaction: transaction)
                    }else{
                        self?.successTransaction(transaction: transaction)
                    }
                case .unverified(_,_):break
                }
                await self?.updatePurchasedProducts()
            }
        }
    }
    func stopObservingTransactionUpdates() {
        updatesTask?.cancel()
        updatesTask = nil
    }
}
// MARK: -- Transaction 결과에 대한 로직 처리
fileprivate extension PurchaseManager{
    func successTransaction(transaction: Transaction){
        self.purchasedProductIDs.insert(transaction.productID)
        self.refundTransactionID = transaction.id
        let value = self.purchasedProductIDs.contains(Self.label)
        UserDefaults.standard.setValue(value, forKey: Self.label)
        event.send(.userProUpdated(value))
    }
    func failTransaction(transaction:Transaction){
        self.purchasedProductIDs.remove(transaction.productID)
//        self.purchasedProductIDs.removeAll()
        let value = self.purchasedProductIDs.contains(Self.label)
        UserDefaults.standard.setValue(value, forKey: Self.label)
        event.send(.userProUpdated(value))
    }
    func resetTransaction(){
        self.purchasedProductIDs.removeAll()
        UserDefaults.standard.setValue(false, forKey: Self.label)
        event.send(.userProUpdated(false))
    }
}
