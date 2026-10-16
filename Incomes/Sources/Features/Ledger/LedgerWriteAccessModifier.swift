import MHPlatform
import SwiftUI

/// Keeps presentation and mutation-time entitlement checks aligned.
private struct LedgerWriteAccessModifier: ViewModifier {
    @Environment(\.ledgerIsAvailable)
    private var isAvailable
    @Environment(\.ledgerIdentifier)
    private var selectedIdentifier
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
    private let disabledOpacity = 0.5
    let owner: LedgerIdentifier?

    func body(content: Content) -> some View {
        let canEdit = isAvailable
            && LedgerAccessOperations.canEdit(owner ?? selectedIdentifier, isPremium: isSubscribeOn)
        content
            .disabled(!canEdit)
            .opacity(canEdit ? 1 : disabledOpacity)
    }
}

extension View {
    func ledgerWriteAccess(owner: LedgerIdentifier? = nil) -> some View {
        modifier(LedgerWriteAccessModifier(owner: owner))
    }
}
