//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView {
    static var isDebug = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @State private var isDebugOption = Self.isDebug
}

extension DebugView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(String.debugOption, isOn: $isDebugOption)
                        .onChange(of: isDebugOption) { _, newValue in
                            Self.isDebug = newValue
                        }
                    Toggle(String.debugSubscribe, isOn: $isSubscribeOn)
                        .disabled(!isDebugOption)
                    Button(String.debugPreviewData) {}
                        .disabled(!isDebugOption)
                        .onLongPressGesture {
                            do {
                                PreviewData.items.forEach(context.insert)
                                try context.save()
                            } catch {
                                assertionFailure(error.localizedDescription)
                            }
                        }
                }
            }
            .toolbar {
                Button(.localized(.done)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationBarTitle(String.debugTitle)
        }
    }
}

#Preview {
DebugView()
}
