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
                if store.isProUser{
                    ProCatList(store: store)
                }else{
                    StandartCatList(store: store)
                }
            }
        }
    }
}
extension CatSelectViewComponents{
    struct ProCatList: View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            ForEach(CatType.allCases,id:\.self){ catType in
                if catType.isAssetExist{
                    if catType == store.tappedCatType{
                        CatSelectStyle.ItemView(name: catType.rawValue.capitalized, imageThumbnail: catType.imageAssetName(type: .thumbnailLogo), isLocked: false){
                            store.send(.action(.itemTapped(catType)))
                        }
                    }else{
                        CatSelectStyle.ItemView(name: catType.rawValue.capitalized, imageThumbnail: catType.imageAssetName(type: .thumbnailInActiveLogo), isLocked: false){
                            store.send(.action(.itemTapped(catType)))
                        }
                    }
                }else{
                    CatSelectStyle.ItemView(name: "untitled",
                                            imageThumbnail: store.tappedCatType.imageAssetName(type: .thumbnailInActiveLogo),
                                            isLocked: true)
                }
            }
        }
    }
    struct StandartCatList:View {
        let store: StoreOf<CatSelectFeature>
        var body: some View {
            ForEach(CatType.allCases,id:\.self){ catType in
                if catType == store.tappedCatType{
                    CatSelectStyle.ItemView(name: catType.rawValue.capitalized, imageThumbnail: catType.imageAssetName(type: .thumbnailLogo), isLocked: false){
                        print("도로 선택!!")
                    }
                }else{
                    CatSelectStyle.ItemView(name: catType.isAssetExist ? catType.rawValue.capitalized : "untitled", imageThumbnail: catType.isAssetExist ? catType.imageAssetName(type: .thumbnailInActiveLogo) : store.tappedCatType.imageAssetName(type: .thumbnailInActiveLogo), isLocked: true)
                }
            }
        }
    }
}
struct CatListItem: View {
    let catType: CatType
    let selectedCatType:CatType
    var isActive: Bool = true
    var action: (()->())?
    var body: some View {
        if selectedCatType == catType{
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

}
fileprivate func itemImage(name:String) -> some View{
    Image(name).resizable()
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 60,height: 60)
}
