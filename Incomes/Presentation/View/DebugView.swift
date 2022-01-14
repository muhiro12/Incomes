//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView: View {
    static var isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var isDebugOption = Self.isDebug

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(String.debugOption, isOn: $isDebugOption)
                        .onChange(of: isDebugOption) {
                            Self.isDebug = $0
                        }
                    Button(String.debugPreviewData) {
                        do {
                            _ = PreviewData(context: viewContext).items
                            try ItemRepository(context: viewContext).save()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }
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
