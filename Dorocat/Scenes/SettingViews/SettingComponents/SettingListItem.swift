//
//  SettingListItem.swift
//  Dorocat
//
//  Created by Developer on 4/3/24.
//

import SwiftUI
import ComposableArchitecture
enum SettingListItem{
    struct Toggler: View{
        let title:String
        var description: String? = nil
        @Binding var isOn: Bool
        var body: some View{
            HStack(content: {
                VStack(alignment:.leading) {
                    Text(title)
                        .font(.paragraph02())
                        .foregroundStyle(.white)
                    if let description{
                        Text(description)
                            .font(.paragraph04)
                            .foregroundStyle(.grey02)
                    }
                }
                Spacer()
                Toggle("", isOn: $isOn).frame(width: 27)
                    .padding(.trailing,17)
            })
            .frame(height: 68)
            .padding(.leading,23)
            .padding(.trailing,17)
            .background(.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    struct Linker: View{
        let title:String
        var description: String? = nil
        var action:()->()
        var body: some View{
            Button(action: {
                action()
            }, label: {
                HStack(content: {
                    VStack {
                        Text(title).font(.paragraph02()).foregroundStyle(.white)
                        if let description{
                            Text(description)
                                .font(.paragraph04)
                                .foregroundStyle(.grey02)
                        }
                    }
                    Spacer()
                    Image(.disclosure).resizable().frame(width: 12,height: 12)
                        .padding(.trailing,21)
                })
                .frame(height: 68)
                .padding(.leading,23)
                .background(.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            })
        }
    }
}
#Preview {                       
    VStack {
        SettingListItem.Toggler(title: "Notifications",
                                description: "Get notified of focus sessions or breaks", isOn: .constant(false))
        SettingListItem.Linker(title: "Send Feedback") {
            print("hello world")
        }
    }
    
}
