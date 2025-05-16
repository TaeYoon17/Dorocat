//
//  DefaultBG.swift
//  Dorocat
//
//  Created by Greem on 5/4/25.
//

import Foundation
import SwiftUI

struct DefaultBG: View {
    var body: some View {
        ZStack{
            Color.grey04
            Image(.defaultBg).resizable(resizingMode: .tile)
        }.ignoresSafeArea(.all,edges: .all)
    }
}
