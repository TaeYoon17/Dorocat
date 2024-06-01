//
//  CatSelectViewComponents.swift
//  Dorocat
//
//  Created by Developer on 6/1/24.
//

import SwiftUI
import ComposableArchitecture

extension CatSelectViewComponents{
    struct CatList: View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            HStack(spacing:20) {
                ForEach(CatType.allCases,id:\.self){ catType in
                    CatListItem(catType: catType,isActive: catType == store.catType) {
                        print("이건 뭘까...")
                    }
                }
            }
        }
    }
}
struct CatListItem: View {
    let catType: CatType
    var isActive: Bool = true
    var action: (()->())?
    var body: some View {
        if isActive{
            VStack{
                Button{
                    action?()
                }label: {
                    itemImage(name: catType.imageAssetName(type: .thumbnailLogo))
                }
                Text(catType.rawValue.uppercased()).foregroundStyle(.grey01).font(.paragraph04)
            }
        }else{
            VStack{
                Button{
                    action?()
                }label: {
                    itemImage(name: catType.imageAssetName(type: .thumbnailInActiveLogo))
                }
                Text("untitled").foregroundStyle(.grey01).font(.paragraph04)
            }
        }
    }
    func itemImage(name:String) -> some View{
        Image(name).resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 60,height: 60)
    }
}
