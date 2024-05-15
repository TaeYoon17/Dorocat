//
//  DBActor.swift
//  Dorocat
//
//  Created by Developer on 3/18/24.
//

import Foundation

// A simple example of a custom global actor
@globalActor actor DBActor: GlobalActor {
    static var shared = DBActor()
}
