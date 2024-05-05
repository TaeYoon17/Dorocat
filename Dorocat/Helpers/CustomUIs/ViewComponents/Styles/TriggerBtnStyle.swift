//
//  TriggerBtnStyle.swift
//  Dorocat
//
//  Created by Developer on 4/4/24.
//

import SwiftUI
extension Button{
    func triggerStyle(status: TriggerBtnStyle.TriggerType,willTap: (()->())? = nil) -> some View{
        self.buttonStyle(TriggerBtnStyle(status: status,willTap: willTap))
    }
}
extension TriggerBtnStyle{
    enum TriggerType{
        case start
        case complete
        case goBreak
        case getStarted
        case stopBreak
        case pause
    }
}
struct TriggerBtnStyle:ButtonStyle{
    var status: TriggerType
    var willTap:(()->())?
    func makeBody(configuration: Configuration) -> some View {
        Group{
            switch status{
            case .start: startStyle(configuration: configuration)
            case .complete: completeStyle(configuration: configuration)
            case .goBreak: goBreakStyle(configuration: configuration)
            case .getStarted: getStartedStyle(configuration: configuration)
            case .pause: pauseStyle(configuration: configuration)
            case .stopBreak: stopBreakStyle(configuration: configuration)
            }
        }
        .overlay(alignment: .center, content: {
            configuration.label.font(.button)
                .foregroundStyle(configuration.isPressed ? .grey02 :.doroWhite)
                .animation(nil, value: configuration.isPressed)
        })
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if oldValue == false && newValue == true{
                willTap?()
            }
        }
    }
}
//MARK: -- Start
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func startStyle(configuration: Configuration)-> some View{
        Image(!configuration.isPressed ? .start : .startActive).background(.red)
    }
}
//MARK: -- Complete
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func completeStyle(configuration: Configuration)-> some View{
        if !configuration.isPressed{
            Image(.complete).frame(width: 144, height: 64)
        }else{
            Image(.completeActive).frame(width: 144,height: 64)
        }
    }
}
//MARK: -- GoBreak
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func goBreakStyle(configuration: Configuration)-> some View{
        if !configuration.isPressed{
            Image(.break).frame(width: 111,height: 64)
        }else{
            Image(.breakActive).frame(width: 111,height: 64)
        }
    }
}
//MARK: -- GetStarted
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func getStartedStyle(configuration: Configuration)-> some View{
        if !configuration.isPressed{
            Image(.getStarted).frame(width: 161,height:64)
        }else{
            Image(.getStartedActive).frame(width: 161,height:64)
        }
    }
}
//MARK: -- Pause
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func pauseStyle(configuration: Configuration)-> some View{
        if !configuration.isPressed{
            Image(.pause).frame(width: 105,height:64)
        }else{
            Image(.pauseActive).frame(width: 105,height:64)
        }
    }
}
//MARK: -- StopBreak
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func stopBreakStyle(configuration: Configuration)-> some View{
        if !configuration.isPressed{
            Image(.stopBreak).frame(width: 140,height:64)
        }else{
            Image(.stopBreakActive).frame(width: 140,height:64)
        }
    }
}
//            ZStack{
//                RoundedRectangle(cornerRadius: 31)
//                    .fill(Color(red: 0.07, green: 0.07, blue: 0.07)).frame(width: 105,height:64)
//                RoundedRectangle(cornerRadius: 30)
//                    .fill(Color(red: 0.13, green: 0.13, blue: 0.13))
//                    .frame(width: 101,height:60)
//                    .background(
//                        Color.black.opacity(0.5)
//                            .shadow(.inner(radius: 8,y:4))
//                    ).blur(radius: 8)
//                configuration.label.foregroundStyle(.grey02).font(.button)
//            }.clipShape(RoundedRectangle(cornerRadius: 30))
/*
 configuration.label
 .foregroundStyle(.doroWhite)
 .font(.button)
 .padding(.vertical,19.5)
 .padding(.horizontal,28)
 .modifier(ScaleModifier(scale: scale))
 .background(content: {
 Capsule().stroke(lineWidth: 1).fill(.grey02)
 .overlay {
 Capsule().fill(.clear)
 .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 6)
 }
 })
 .padding(.bottom,2)
 .overlay{
 Capsule().stroke(lineWidth: 2).fill(.black)
 .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 8)
 .offset(y:-2)
 }
 .modifier(ScaleModifier(scale: scale))
 */
