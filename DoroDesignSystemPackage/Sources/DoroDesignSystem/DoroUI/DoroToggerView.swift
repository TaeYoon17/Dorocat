// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
public struct DoroTogglerView: View {
    public enum ToggleSize{
        case small
        case medium
    }
   @Binding var isOn: Bool
    let toggleSize: ToggleSize
    public init(isOn: Binding<Bool>,toggleSize: ToggleSize) {
       self._isOn = isOn
        self.toggleSize = toggleSize
   }
   public var body: some View {
       GeometryReader { reader in
           ZStack(alignment: .center){
               HStack(spacing:0) {
                   switch toggleSize {
                   case .medium:
                       Rectangle().fill(.clear).frame(width: 2)
                   case .small:
                       Rectangle().fill(.clear).frame(width: 5)
                   }
                   if isOn { Spacer() }
                   Group{
                       switch toggleSize {
                       case .small:
                           toggleButton.clipShape(Circle()).padding(.vertical,3).padding(.horizontal,2)
                       case .medium:
                           toggleButton.clipShape(Circle()).padding(.vertical,4).padding(.horizontal,4.5)
                       }
                   }
                   //MARK: -- 설정에서 사용한 패딩 값들
                   .frame(width: reader.frame(in: .global).height)
                   .onTapGesture { withAnimation { isOn.toggle() } }
                   .swipe(action: { direction in
                       if direction == .swipeLeft {
                           withAnimation() { isOn = true }
                       }else if direction == .swipeRight {
                           withAnimation() { isOn = false }
                       }
                   })
                   if !isOn {
                       Spacer()
                   }
                   switch toggleSize {
                   case .medium:
                       Rectangle().fill(.clear).frame(width: 2)
                   case .small:
                       Rectangle().fill(.clear).frame(width: 5)
                   }
               }
               .background{bgImage}
               .clipShape(Capsule())
               .frame(width: 50, height: 26)
           }
           .frame(width: 60, height: 30)//control the frame or remove it and add it to ToggleView
       }
   }
    var bgImage: some View{
        Image(isOn ? .togglerActive : .toggler).resizable().scaledToFit()
    }
    var toggleButton: some View{
        Image(isOn ? .knobOn : .knobOff).resizable().scaledToFit()
    }
}
// MARK: -- 기존에 사용하는 커스텀 토글러...
struct CustomTogglerView<BackContent: View,CircleContent: View>: View {
   @Binding var isOn: Bool
   var backGround: BackContent
   var toggleButton: CircleContent?
   init(isOn: Binding<Bool>,
        @ViewBuilder backGround: @escaping () -> BackContent,
        @ViewBuilder button: @escaping () -> CircleContent? = {nil}) {
       self._isOn = isOn
       self.backGround = backGround()
       self.toggleButton = button()
   }
   var body: some View {
       GeometryReader { reader in
           HStack(spacing:0) {
               Rectangle().fill(.clear).frame(width: 5)
               if isOn {
                   Spacer()
               }
               VStack {
                   if let toggleButton = toggleButton {
                       toggleButton.clipShape(Circle())
                   }else {
                       Circle().fill(Color.white)
                   }
               }
               .padding(.vertical,3)
               .padding(.horizontal,2)
               .frame(width: reader.frame(in: .global).height)
               .onTapGesture {
                   withAnimation {
                       isOn.toggle()
                   }
               }
               .swipe(action: { direction in
                   if direction == .swipeLeft {
                       withAnimation() {
                           isOn = true
                       }
                   }else if direction == .swipeRight {
                       withAnimation() {
                           isOn = false
                       }
                   }
               })
               if !isOn {
                   Spacer()
               }
               Rectangle().fill(.clear).frame(width: 5)
           }
           .background{backGround}
           .clipShape(Capsule())
           .frame(width: 50, height: 26)
       }
   }
}
