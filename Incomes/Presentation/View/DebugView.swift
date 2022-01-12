//
//  DebugView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/12.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct DebugView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.presentationMode)
    var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(String.debugPreviewData) {
                        do {
                            _ = PreviewData(context: viewContext).items
                            try ItemController(context: viewContext).saveAll()
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
