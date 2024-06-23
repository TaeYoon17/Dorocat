//
//  CatSelectStyle.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import SwiftUI
enum CatSelectStyle{
    struct ItemView: View{
        let name:String
        let imageThumbnail:String
        let isActive:Bool
        let isLocked:Bool
        var action:(()->())? = nil
        var body: some View{
            if isLocked{
                VStack{
                    ZStack{
                        itemImage(name: imageThumbnail)
                        Image(.themeLock).resizable().aspectRatio(1, contentMode: .fit).frame(width: 16,height: 16)
                    }
                    Text(name).foregroundStyle(.grey01).font(.paragraph04)
                }
            }else{
                VStack{
                    Button{
//                        print("처음 고른 로고 선택")
                        action?()
                    }label: {
                        itemImage(name: imageThumbnail)
                    }
                    Text(name).foregroundStyle(.grey01).font(.paragraph04)
                }
            }
            
        }
        @ViewBuilder func itemImage(name:String) -> some View{
            Image(name).resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 60,height: 60)
                .opacity(isActive ? 1: 0.333)
        }
    }
}
