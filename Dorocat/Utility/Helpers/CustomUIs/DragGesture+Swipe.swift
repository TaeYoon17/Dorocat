//
//  Swiper.swift
//  Dorocat
//
//  Created by Developer on 4/5/24.
//
//MARK: -- 드래그 제스처를 이용해 스와이프 방향을 감지하게 도와주는 모디파이어
import Foundation
import SwiftUI
enum Direction {
   case none
   case swipeLeft
   case swipeRight
   case swipeUp
   case swipeDown
}
struct Swipe: ViewModifier {
   @GestureState private var dragDirection: Direction = .none
   @State private var lastDragPosition: DragGesture.Value?
   @State var position = Direction.none
   var action: (Direction) -> Void
   func body(content: Content) -> some View {
       content
           .gesture(DragGesture().onChanged { value in
               lastDragPosition = value
           }.onEnded { value in
               if lastDragPosition != nil {
                   if (lastDragPosition?.location.x)! < value.location.x {
                       withAnimation() {
                           action(.swipeRight)
                       }
                   }else if (lastDragPosition?.location.x)! > value.location.x {
                       withAnimation() {
                           action(.swipeLeft)
                       }
                   }
               }
           })
   }
}

