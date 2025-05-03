//
//  NumberPickerView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import UIKit

struct NumberPickerView:UIViewRepresentable{
    @Binding var number:Int
    let range:Range<Int>
    func makeCoordinator() -> PickerCoordinator {
        PickerCoordinator(number:$number,range: range)
    }
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let pickerView = UIPickerView(frame:.zero)
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        context.coordinator.pickerView = pickerView
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: view.topAnchor,constant: -10),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 10),
        ])
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            pickerView.subviews[1].backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    final class PickerCoordinator:NSObject,UIPickerViewDelegate,UIPickerViewDataSource{
        weak var pickerView: UIPickerView!{
            didSet{
                guard let pickerView,let idx = numberIndexes[number] else {return}
                DispatchQueue.main.async{
                    print("가져오기... \(idx)")
                    pickerView.selectRow(idx, inComponent: 0, animated: false)
                }
            }
        }
        private var numberIndexes:[Int:Int] = [:]
        private var numbers:[Int] = []
        @Binding var number:Int
        init(number:Binding<Int>,range:Range<Int>) {
            self._number = number
            for (idx,num) in range.enumerated(){
                numberIndexes[num] = idx
                numbers.append(num)
            }
        }
        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            numbers.count
        }
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            24
         }
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var pickerLabel = view as? UILabel;
            if (pickerLabel == nil){
                pickerLabel = UILabel()
                pickerLabel?.font = .paragraph02(.bold)
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.textColor = UIColor.doroWhite
            pickerLabel?.text = "\(numbers[row])"
            return pickerLabel!
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.number = numbers[row]
        }
    }
}
