//
//  DoroNumberPad.swift
//  Dorocat
//
//  Created by Developer on 4/5/24.
//

import Foundation
import SwiftUI
struct TempView: View{
    @State private var text = ""
    @FocusState var showKeyboard: Bool
    var body: some View{
        VStack {
            Image(.doroThumbnailLogo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100,height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            Spacer()
            DoroNumberPad(text: $text)
                .frame(maxWidth: .infinity).frame(height:300)
        }.ignoresSafeArea(.container,edges: .bottom)
    }
}
struct DoroNumberPad:View{
    @Binding var text:String
    var body: some View{
        VStack(content: {
            LazyVGrid(columns: Array(repeating: .init(.flexible(),spacing:6.66), count: 3),spacing: 7, content: {
                ForEach(1...9,id:\.self){ idx in
                    keyboardButtonView(.text("\(idx)"), onTap: {
                        text += "\(idx)"
                    })
                }
                keyboardButtonView(.text("C",.clear)) {
                    text = ""
                }
                keyboardButtonView(.text("0")) {
                    text += "0"
                }
                keyboardButtonView(.image("delete.backward")) {
                    _ = text.popLast()
                }
            }).padding(.horizontal,15).padding(.vertical,5)
        })
        .background{
            Rectangle().fill(.grey04).ignoresSafeArea()
        }
    }
    @ViewBuilder func keyboardButtonView(_ value:KeyboardValue, onTap: @escaping ()->()) -> some View{
        Button(action: onTap, label: {
            ZStack{
                switch value{
                case .text(let str, _ ):
                    Text(str).font(.header04)
                        .foregroundStyle(.white)
                case .image(let image, _ ):
                    Image(systemName: image)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: .infinity)
                .padding(.vertical,12)
                .background{ value.color }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
            
        })
    }
}


enum KeyboardValue: Equatable {
    enum BGType {
        case clear
        case exist
        var color: Color {
            switch self {
            case .clear: Color.clear
            case .exist: Color.grey03
            }
        }
    }
    case text(String, BGType = .exist)
    case image(String, BGType = .clear)
    var color: Color{
        switch self{
        case .image(_, let type): return type.color
        case .text(_, let type): return type.color
        }
    }
}
extension View{
    @ViewBuilder func inputView<Content: View>(@ViewBuilder content: @escaping ()->Content) -> some View{
        self.background{
            SetTFKeyboard(keyboardContent: content())
        }
    }
}

fileprivate struct SetTFKeyboard<Content:View>: UIViewRepresentable{
    var keyboardContent: Content
    @State private var hostingController: UIHostingController<Content>?
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async{
            if let textFieldContainerView = uiView.superview?.superview{
                if let textField = textFieldContainerView.findTextField{
                    // input이 이미 정리되어 있다면, 콘텐츠 업데이트
                    if textField.inputView == nil{
                        hostingController = UIHostingController(rootView: keyboardContent)
                        hostingController?.view.frame = .init(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
                        // UIHostingController를 통해 스유 뷰를 UIKit으로 바꿔서 띄우기
                        textField.inputView = hostingController?.view
                    }else{
                        // 호스팅 콘텐츠 변경
                        hostingController?.rootView = keyboardContent
                    }
                    print(textField)
                }else{
                    print("Fail to find textfield")
                }
            }
        }
    }
}

/// Extracting TextField From the Subviews
fileprivate extension UIView{
    var allSubViews: [UIView] {
        return subviews.flatMap { view in
            var arr:[UIView] = [view]
            arr.append(contentsOf: view.subviews)
            return arr
        }
    }
    var findTextField: UITextField?{
        if let textField = allSubViews.first(where: { view in
            view is UITextField
        }) as? UITextField{ return textField }
        return nil
    }
}

#Preview {
    TempView()
}
