
import SwiftUI

public enum CatSelectStyle{
    struct ItemView: View{
        let name:String
        let imageThumbnail:String
        let isActive:Bool
        let isLocked:Bool
        var action:(()->())? = nil
        var body: some View{
            VStack{
                Button{
                    action?()
                }label: {
                    ZStack{
                        itemImage(name: imageThumbnail)
                        if isLocked{
                            Image(.themeLock).resizable().aspectRatio(1, contentMode: .fit).frame(width: 16,height: 16)
                        }
                    }
                }
                Text(name).foregroundStyle(Color.grey01).font(.paragraph04)
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
