//
//  StoreSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct StoreSection: View {
    @State
    private var restoreAlert = AlertInformation(isPresented: false, title: .empty)

    private let store = Store.shared

    var body: some View {
        Section(content: {
            Button(.localized(.subscribe)) {
                Task {
                    do {
                        guard let product = try await store.product() else {
                            return
                        }
                        try await store.purchase(product: product)
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
            }
            Button(.localized(.restore)) {
                Task {
                    do {
                        try await store.restore()
                    } catch {
                        guard let error = error as? IncomesError else {
                            return
                        }
                        restoreAlert = .init(isPresented: true, title: error.message)
                    }
                }
            }
        }, header: {
            Text(.localized(.subscriptionHeader))
        }, footer: {
            Text(.localized(.subscriptionFooter))
        })
        .alert(restoreAlert.title, isPresented: $restoreAlert.isPresented) {}
    }
}

#if DEBUG
struct StoreSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StoreSection()
        }
    }
}
#endif
