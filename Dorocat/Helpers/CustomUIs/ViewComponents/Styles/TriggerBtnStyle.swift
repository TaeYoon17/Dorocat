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
        }.frame(status: status)
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
fileprivate extension View{
    func frame(status:TriggerBtnStyle.TriggerType)-> some View{
        switch status{
        case .start: self.frame(width: 105,height: 64)
        case .complete: self.frame(width: 144,height: 64)
        case .goBreak: self.frame(width: 111,height: 64)
        case .getStarted: self.frame(width: 161,height: 64)
        case .pause: self.frame(width: 105,height: 64)
        case .stopBreak: self.frame(width: 140,height: 64)
        }
    }
}
//MARK: -- Start
fileprivate extension TriggerBtnStyle{
    @ViewBuilder func startStyle(configuration: Configuration)-> some View{
        Image(!configuration.isPressed ? .trigger : .triggerActive).resizable().frame(width: 105,height:64)
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
            Image(.trigger).frame(width: 111,height: 64)
        }else{
            Image(.triggerActive).frame(width: 111,height: 64)
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

