import SwiftUI

struct YearlyDuplicationYearMenuGroup: View {
    @Binding var sourceYear: Int
    @Binding var targetYear: Int

    let sourceYears: [Int]
    let targetYears: [Int]
    let inlineSpacing: CGFloat
    let controlSpacing: CGFloat

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
    }
}

private extension YearlyDuplicationYearMenuGroup {
    var sourceYearMenu: some View {
        YearlyDuplicationYearMenu(
            title: "Source Year",
            selection: $sourceYear,
            years: sourceYears,
            inlineSpacing: inlineSpacing
        )
    }

    var targetYearMenu: some View {
        YearlyDuplicationYearMenu(
            title: "Target Year",
            selection: $targetYear,
            years: targetYears,
            inlineSpacing: inlineSpacing
        )
    }

    var horizontalLayout: some View {
        HStack(alignment: .top, spacing: controlSpacing) {
            sourceYearMenu
            targetYearMenu
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            sourceYearMenu
            targetYearMenu
        }
    }
}
