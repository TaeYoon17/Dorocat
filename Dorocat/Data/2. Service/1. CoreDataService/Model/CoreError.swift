//
//  CoreError.swift
//  Dorocat
//
//  Created by Greem on 5/6/25.
//

import Foundation

enum CoreError: String, Error {
    case invalidEntity = "등록되지 않은 엔티티입니다."
    case noneFetchResult = "일치하는 데이터가 없습니다."
}
