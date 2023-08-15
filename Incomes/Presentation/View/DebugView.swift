//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView: View {
    static var isDebug = false

    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var isDebugOption = Self.isDebug
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(String.debugOption, isOn: $isDebugOption)
                        .onChange(of: isDebugOption) {
                            Self.isDebug = $0
                        }
                    Toggle(String.debugSubscribe, isOn: $isSubscribeOn)
                        .disabled(!isDebugOption)
                    Button(String.debugPreviewData) {
                    }.onLongPressGesture {
                        do {
                            _ = PreviewData(context: viewContext).items
                            try viewContext.save()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }.disabled(!isDebugOption)
                }
            }.toolbar {
                Button(.localized(.done)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }.navigationBarTitle(String.debugTitle)
        }
    }
}

#if DEBUG
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
#endif
