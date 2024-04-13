//
//  AsyncForEach.swift
//  Dorocat
//
//  Created by Developer on 4/13/24.
//

import Foundation

extension Sequence{
    func asyncForEach(_ transform: (Element) async throws -> ()) async rethrows{
        for element in self{
            try await transform(element)
        }
    }
}
