//
//  RefreshSyncButton.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import SwiftUI
import ComposableArchitecture
import DoroDesignSystem

enum Hello {
    case start
    case stop
}

extension IcloudSyncComponents {
    struct RefreshSyncListButton: View {
        let title: String
        let description: String
        let isLoading: Bool
        let action: () -> ()
        
        
        @State private var rotationDegree: CGFloat = 0
        @State private var task: Task<(), any Error>?
        var body: some View {
            HStack(content: {
                Text(title)
                    .font(.paragraph02())
                    .foregroundStyle(Color.doroWhite)
                    .fontCoordinator()
                Spacer()
                HStack {
                    Text(description)
                        .font(.paragraph04)
                        .foregroundStyle(Color.grey02)
                        .fontCoordinator().fontCoordinator()
                    Button {
                        action()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .fontWeight(.heavy)
                            .foregroundStyle(Color.doroBlack)
                            .rotationEffect(.init(degrees: rotationDegree))
                            .padding(4)
                            .background(content: {
                                Circle().fill(Color.doroWhite)
                            })
                            .padding(.trailing,17)
                    }
                    .contentShape(Rectangle())
                }
            })
            .frame(height: 68)
            .padding(.leading,23)
            .background(Color.grey03)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onChange(of: isLoading, { oldValue, newValue in
                if newValue {
                    startRotation()
                } else {
                    stopRotation()
                }
            })
            .onAppear() {
                if isLoading {
                    startRotation()
                } else {
                    stopRotation()
                }
            }
        }
        
        private func startRotation() {
            task?.cancel()
            task = Task {
                let clock = SuspendingClock()
                while true {
                    try await clock.sleep(for: .seconds(0.01))
                    let val = (Int(rotationDegree + 5) % 360)
                    await MainActor.run {
                        rotationDegree = CGFloat(val)
                    }
                }
            }
        }
        private func stopRotation() {
            task?.cancel()
        }
    }
}

#Preview {
    let stream = AsyncStream<Hello> { observer in
        observer.yield(.start)
    }
    
    IcloudSyncComponents.RefreshSyncListButton(
        title: "Last Sync",
        description: "1 munites ago...",
        isLoading: false,
        action: {
            print("Hello world!!")
        }
    )
}
