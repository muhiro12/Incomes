//
//  NotificationSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct NotificationSection: View {
    @Environment(NotificationService.self)
    private var notificationService

    var body: some View {
        Section("Notification") {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .accessibilityHidden(true)
                Text("Upcoming Changes to the Subscription Plan")
            }
            .font(.headline)
            .foregroundStyle(.red)
            Text(
                """
                We would like to inform you that starting August 1st (tentative), the contents of the subscription plan will be updated as follows:

                  1. iCloud synchronization and ad removal will become subscription features.
                  2. Features such as categories and graphs, which were previously part of the subscription, will now be available for free to all users.

                We greatly appreciate your support and understanding as we make these changes to enhance your experience with our app. Thank you for being a valued member of our community.
                """
            )
        }
        .task {
            notificationService.refresh()
        }
    }
}

#Preview {
    NotificationSection()
}
