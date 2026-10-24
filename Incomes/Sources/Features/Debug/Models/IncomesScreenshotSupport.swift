#if DEBUG
import Foundation
import SwiftData
import SwiftUI
import UIKit

/// Isolates explicitly requested Store captures from saved records and services.
enum IncomesScreenshotSupport {
    private static let chartDefaultVerticalAnchor: CGFloat = 0.01
    private static let chartLayoutDelayMilliseconds = 500
    private static let chartLayoutDelay: Duration = .milliseconds(chartLayoutDelayMilliseconds)
    private static let cardOutgoBaseUSD: Decimal = 900
    private static let chartDefaultScrollBack: CGFloat = 32
    private static let chartMaximumScrollBack: CGFloat = 128

    private static var chartScrollBack: CGFloat {
        guard let value = ProcessInfo.processInfo.environment["INCOMES_SCREENSHOT_CHART_SCROLL_BACK"],
              let requestedDistance = Double(value),
              (.zero...chartMaximumScrollBack).contains(CGFloat(requestedDistance)) else {
            return chartDefaultScrollBack
        }
        return CGFloat(requestedDistance)
    }

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--incomes-screenshots")
    }

    static var showsItemInformation: Bool {
        isEnabled && ProcessInfo.processInfo.arguments.contains("--incomes-screenshots-info")
    }

    private static var chartScrollAnchor: UnitPoint {
        var verticalAnchor = chartDefaultVerticalAnchor
        if isEnabled,
           let value = ProcessInfo.processInfo.environment["INCOMES_SCREENSHOT_CHART_ANCHOR"],
           let requestedAnchor = Double(value),
           (UnitPoint.top.y...UnitPoint.bottom.y).contains(CGFloat(requestedAnchor)) {
            verticalAnchor = CGFloat(requestedAnchor)
        }
        return .init(x: UnitPoint.top.x, y: verticalAnchor)
    }

    @MainActor
    static func positionCharts(using scrollProxy: ScrollViewProxy) async {
        guard isEnabled,
              ProcessInfo.processInfo.arguments.contains("--incomes-screenshots-charts") else {
            return
        }
        scrollProxy.scrollTo("incomes-screenshot-balance-section", anchor: chartScrollAnchor)
        do {
            try await Task.sleep(for: chartLayoutDelay)
        } catch {
            return
        }
        // Lazy List rows have their final heights only after the first scroll.
        scrollProxy.scrollTo("incomes-screenshot-balance-section", anchor: chartScrollAnchor)
        do {
            try await Task.sleep(for: chartLayoutDelay)
        } catch {
            return
        }
        restoreChartHeading()
    }

    @MainActor
    private static func restoreChartHeading() {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { scene in
                scene as? UIWindowScene
            }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
        let scrollViews = windows.flatMap { window in
            window.layoutIfNeeded()
            return visibleVerticalScrollViews(in: window)
        }
        guard let scrollView = scrollViews.max(by: { first, second in
            first.bounds.width * first.bounds.height < second.bounds.width * second.bounds.height
        }) else {
            return
        }
        let topOffset = -scrollView.adjustedContentInset.top
        let targetOffset = max(topOffset, scrollView.contentOffset.y - chartScrollBack)
        scrollView.setContentOffset(.init(x: scrollView.contentOffset.x, y: targetOffset), animated: false)
    }

    @MainActor
    private static func visibleVerticalScrollViews(in view: UIView) -> [UIScrollView] {
        guard !view.isHidden, view.alpha > .zero else {
            return []
        }
        var scrollViews = view.subviews.flatMap { subview in
            visibleVerticalScrollViews(in: subview)
        }
        if let scrollView = view as? UIScrollView,
           let window = scrollView.window,
           scrollView.convert(scrollView.bounds, to: window).intersects(window.bounds),
           scrollView.contentSize.height > scrollView.bounds.height {
            scrollViews.append(scrollView)
        }
        return scrollViews
    }

    @MainActor
    static func presentItemInformationIfRequested(
        context: ModelContext,
        router: MainNavigationRouter
    ) {
        guard showsItemInformation else {
            return
        }
        do {
            let items = try ItemQueryOperations.items(
                context: context,
                date: .now,
                ledgerIdentifier: router.ledgerIdentifier
            )
            let expectedOutgo = LocaleAmountConverter.localizedAmount(baseUSD: cardOutgoBaseUSD)
            guard let item = items.first(where: { item in
                item.outgo == expectedOutgo
            }) else {
                preconditionFailure("Missing sample card payment for screenshots")
            }
            let itemID = try PersistentIdentifierCoder.encode(item.persistentModelID)
            try router.navigate(to: .item(itemID), context: context)
        } catch {
            preconditionFailure("Failed to present screenshot item information: \(error)")
        }
    }
}

#endif
