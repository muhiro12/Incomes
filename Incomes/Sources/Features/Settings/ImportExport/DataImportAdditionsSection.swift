import SwiftUI

struct DataImportAdditionsSection: View {
    let additions: [IncomesFileItem]
    let isIncluded: (Int) -> Bool
    let setIncluded: (Int, Bool) -> Void

    var body: some View {
        Section {
            ForEach(Array(additions.enumerated()), id: \.offset) { index, item in
                Toggle(
                    isOn: .init(
                        get: {
                            isIncluded(index)
                        },
                        set: { isOn in
                            setIncluded(index, isOn)
                        }
                    )
                ) {
                    DataImportItemRow(item: item)
                }
            }
        } header: {
            Text("Items to add")
        } footer: {
            Text("These items are only in the file. Turn off any you do not want to add.")
        }
    }
}
