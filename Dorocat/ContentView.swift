//
//  ContentView.swift
//  Dorocat
//
//  Created by Developer on 3/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedIdx = 1
    var body: some View {
        TabView(selection: $selectedIdx) {
            Text("Hello World").background(.red)
                .tag(0)
            Text("Hello World").background(.blue)
                .tag(1)
            Text("Hello World").background(.yellow)
                .tag(2)
        }.tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#Preview {
    ContentView()
}
