//
//  CustomCircleView.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct PageIndicatorView<T: Equatable & Identifiable>: View{
    let itemCount:[T]
    var selectedIndex: T
    var body: some View{
        HStack(spacing:5,content: {
            ForEach(itemCount){ idx in
                Group{
                    if idx == selectedIndex{
                        Circle().fill(.white)
                    }else{
                        Circle().fill(.grey02)
                    }
                }.frame(width:4,height:4)
            }
        })
    }
}
