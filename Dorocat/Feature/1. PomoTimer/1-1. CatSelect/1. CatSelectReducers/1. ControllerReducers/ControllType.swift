//
//  ControllType.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import Foundation
import ComposableArchitecture

extension CatSelectFeature{
    enum ControllType: Equatable {
        case itemTapped(CatType)
        case doneTapped
    }
}
