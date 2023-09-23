//
//  ItemFormView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ItemFormView {
    enum Mode {
        case create
        case edit
        case detail
    }

    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode

    @State private var mode = Mode.create
    @State private var isActionSheetPresented = false
    @State private var isDebugAlertPresented = false

    @State private var date = Date()
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var outgo: String = .empty
    @State private var group: String = .empty
    @State private var repeatSelection: Int = .zero

    private let item: Item?

    init(create: Void) {
        self.item = nil
        _mode = State(initialValue: .create)
    }

    init(detail item: Item) {
        self.item = item
        _mode = State(initialValue: .detail)
    }
}

extension ItemFormView: View {
    // TODO: Resolve SwiftLint
    // swiftlint:disable closure_body_length
    var body: some View {
        Form {
            Section(content: {
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text(.localized(.date))
                }.disabled(isEditable)
                HStack {
                    Text(.localized(.content))
                    Spacer()
                    TextField(String.empty, text: $content)
                        .disabled(isEditable)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(.localized(.income))
                    TextField(String.zero, text: $income)
                        .disabled(isEditable)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                }
                HStack {
                    Text(.localized(.outgo))
                    TextField(String.zero, text: $outgo)
                        .disabled(isEditable)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(outgo.isEmptyOrDecimal ? .primary : .red)
                }
                HStack {
                    Text(.localized(.group))
                    Spacer()
                    TextField(.localized(.others), text: $group)
                        .disabled(isEditable)
                        .multilineTextAlignment(.trailing)
                }
                if mode == .create {
                    HStack {
                        Text(.localized(.repeatCount))
                        Spacer()
                        Picker(.localized(.repeatCount),
                               selection: $repeatSelection) {
                            ForEach((.minRepeatCount)..<(.maxRepeatCount + .one), id: \.self) {
                                Text($0.description)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(width: .componentS,
                               height: .componentS)
                        .clipped()
                    }
                }
            }, header: {
                Text(.localized(.information))
            })
            if DebugView.isDebug {
                DebugSection(item: item)
            }
        }
        .navigationBarTitle({ () -> String in
            switch mode {
            case .create:
                return .localized(.createTitle)

            case .edit:
                return .localized(.editTitle)

            case .detail:
                // TODO: Localized
                return "Detail"
            }
        }())
        .navigationBarItems(
            leading: Button(action: cancel) {
                Text(.localized(.cancel))
            },
            trailing: Button(action: mode == .edit ? save : create) {
                Text(mode == .edit ? .localized(.save) : .localized(.create))
                    .bold()
            }
            .disabled(!isValid))
        .gesture(DragGesture()
                    .onChanged { _ in
                        dismissKeyboard()
                    })
        .alert(String.debugTitle, isPresented: $isDebugAlertPresented) {
            Button(.localized(.cancel), role: .cancel) {}
            Button(String.debugOK) {
                DebugView.isDebug = true
                dismiss()
            }
        } message: {
            Text(String.debugMessage)
        }
        .onAppear {
            guard let item else {
                return
            }
            date = item.date
            content = item.content
            income = item.income.description
            outgo = item.outgo.description
            group = item.group
        }
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(title: Text(.localized(.saveDetail)),
                        buttons: [
                            .default(Text(.localized(.saveForThisItem)),
                                     action: saveForThisItem),
                            .default(Text(.localized(.saveForFutureItems)),
                                     action: saveForFutureItems),
                            .default(Text(.localized(.saveForAllItems)),
                                     action: saveForAllItems),
                            .cancel()
                        ])
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    // swiftlint:enable closure_body_length
}

// MARK: - private

private extension ItemFormView {
    var isEditable: Bool {
        mode != .detail
    }

    var isValid: Bool {
        content.isNotEmpty
            && income.isEmptyOrDecimal
            && outgo.isEmptyOrDecimal
    }

    func save() {
        do {
            if let repeatID = item?.repeatID,
               try ItemService(context: context).items(predicate: Item.predicate(repeatIDIs: repeatID)).count > .one {
                presentToActionSheet()
            } else {
                saveForThisItem()
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func saveForThisItem() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemService(context: context)
                .update(item: item,
                        date: date,
                        content: content,
                        income: income.decimalValue,
                        outgo: outgo.decimalValue,
                        group: group)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForFutureItems() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemService(context: context)
                .updateForFutureItems(item: item,
                                      date: date,
                                      content: content,
                                      income: income.decimalValue,
                                      outgo: outgo.decimalValue,
                                      group: group)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func saveForAllItems() {
        guard let item else {
            assertionFailure()
            return
        }
        do {
            try ItemService(context: context)
                .updateForAllItems(item: item,
                                   date: date,
                                   content: content,
                                   income: income.decimalValue,
                                   outgo: outgo.decimalValue,
                                   group: group)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func create() {
        do {
            try ItemService(context: context)
                .create(date: date,
                        content: content,
                        income: income.decimalValue,
                        outgo: outgo.decimalValue,
                        group: group,
                        repeatCount: repeatSelection + .one)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func cancel() {
        if content == .debugCommand {
            content = .empty
            isDebugAlertPresented = true
            return
        }
        dismiss()
    }

    func presentToActionSheet() {
        isActionSheetPresented = true
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

#Preview {
    ItemFormView(create: ())
}
