//
//  CircularProgressView.swift
//  Dorocat
//
//  Created by Developer on 4/13/24.
//

import SwiftUI
struct CircularProgress:View{
    var progress:CGFloat
    let lineWidth: CGFloat
    let backShape: any ShapeStyle
    let frontShapes: [any ShapeStyle]
    var body: some View{
        ZStack(content: {
            Circle()
                .stroke(AnyShapeStyle(backShape),style:  StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            ZStack(content: {
                ForEach(frontShapes.indices,id:\.self){ idx in
                    let frontShape = frontShapes[idx]
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(AnyShapeStyle(frontShape),style:  StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.init(degrees: -90))
                }
            })
            
        })
    }
}
