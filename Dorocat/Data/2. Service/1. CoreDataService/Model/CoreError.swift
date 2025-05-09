//
//  CoreError.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation

enum CoreError: Error {
    case invalidEntity
    case noneFetchResult
    case invalidAttribute(String)
    var rawValue: String {
        switch self {
        case .invalidAttribute(let value): "모델 파라미터 \(value)가 Entity Attribute에 일치하지 않습니다."
        case .invalidEntity: "등록되지 않은 엔티티입니다."
        case .noneFetchResult: "일치하는 데이터가 없습니다."
        }
    }
}
