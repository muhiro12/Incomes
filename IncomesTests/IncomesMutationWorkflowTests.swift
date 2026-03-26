import Foundation
@testable import Incomes
import IncomesLibrary
import MHMutationFlow
import Testing

@MainActor
struct IncomesMutationWorkflowTests {
    @Test
    func follow_up_hint_adapter_returns_no_steps_when_no_hints_are_present() {
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: {
                // Intentionally empty.
            },
            reloadWidgets: {
                // Intentionally empty.
            }
        )

        let steps = adapter.steps(for: [])

        #expect(steps.isEmpty)
    }

    @Test
    func follow_up_hint_adapter_emits_refresh_notification_step_only_when_requested() async throws {
        var refreshedNotifications = false
        var reloadedWidgets = false
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: {
                refreshedNotifications = true
            },
            reloadWidgets: {
                reloadedWidgets = true
            }
        )

        let steps = adapter.steps(for: [.refreshNotificationSchedule])

        #expect(steps.map(\.name) == ["refreshNotificationSchedule"])

        for step in steps {
            try await step.action()
        }

        #expect(refreshedNotifications)
        #expect(reloadedWidgets == false)
    }

    @Test
    func follow_up_hint_adapter_emits_reload_widgets_step_only_when_requested() async throws {
        var refreshedNotifications = false
        var reloadedWidgets = false
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: {
                refreshedNotifications = true
            },
            reloadWidgets: {
                reloadedWidgets = true
            }
        )

        let steps = adapter.steps(for: [.reloadWidgets])

        #expect(steps.map(\.name) == ["reloadWidgets"])

        for step in steps {
            try await step.action()
        }

        #expect(refreshedNotifications == false)
        #expect(reloadedWidgets)
    }

    @Test
    func follow_up_hint_adapter_preserves_declared_step_order_for_combined_hints() async throws {
        var executedSteps = [String]()
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: {
                executedSteps.append("refreshNotificationSchedule")
            },
            reloadWidgets: {
                executedSteps.append("reloadWidgets")
            }
        )

        let steps = adapter.steps(
            for: [
                .refreshNotificationSchedule,
                .reloadWidgets
            ]
        )

        #expect(steps.map(\.name) == [
            "refreshNotificationSchedule",
            "reloadWidgets"
        ])

        for step in steps {
            try await step.action()
        }

        #expect(executedSteps == [
            "refreshNotificationSchedule",
            "reloadWidgets"
        ])
    }
}
