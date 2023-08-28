//
//  EditView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct EditView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.presentationMode)
    private var presentationMode

    @State
    private var isPresentedToActionSheet = false
    @State
    private var isDebugPresented = false

    @State
    private var date = Date()
    @State
    private var content: String = .empty
    @State
    private var income: String = .empty
    @State
    private var outgo: String = .empty
    @State
    private var group: String = .empty
    @State
    private var repeatSelection: Int = .zero

    private var item: Item?

    private var isEditMode: Bool {
        item != nil
    }

    private var isValid: Bool {
        content.isNotEmpty
            && income.isEmptyOrDecimal
            && outgo.isEmptyOrDecimal
    }

    init() {}

    init(of item: Item) {
        self.item = item
        _date = State(initialValue: item.date)
        _content = State(initialValue: item.content)
        _income = State(initialValue: item.income.description)
        _outgo = State(initialValue: item.outgo.description)
        _group = State(initialValue: item.group)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    DatePicker(selection: $date, displayedComponents: .date) {
                        Text(.localized(.date))
                    }
                    HStack {
                        Text(.localized(.content))
                        Spacer()
                        TextField(String.empty, text: $content)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(.localized(.income))
                        TextField(String.zero, text: $income)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(income.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(.localized(.outgo))
                        TextField(String.zero, text: $outgo)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(outgo.isEmptyOrDecimal ? .primary : .red)
                    }
                    HStack {
                        Text(.localized(.group))
                        Spacer()
                        TextField(.localized(.others), text: $group)
                            .multilineTextAlignment(.trailing)
                    }
                    if !isEditMode {
                        HStack {
                            Text(.localized(.repeatCount))
                            Spacer()
                            Picker(.localized(.repeatCount),
                                   selection: $repeatSelection) {
                                ForEach((.minRepeatCount)..<(.maxRepeatCount + .one)) {
                                    Text($0.description)
                                }
                            }.pickerStyle(WheelPickerStyle())
                            .labelsHidden()
                            .frame(width: .componentS,
                                   height: .componentS)
                            .clipped()
                        }
                    }
                }, header: {
                    Text(.localized(.information))
                })
                if DebugView.isDebug,
                   let item {
                    Section(content: {
                        Text(String(describing: item))
                    }, header: {
                        Text(String.debugTitle)
                    })
                }
            }.navigationBarTitle(isEditMode ? .localized(.editTitle) : .localized(.createTitle))
            .navigationBarItems(
                leading: Button(action: cancel) {
                    Text(.localized(.cancel))
                },
                trailing: Button(action: isEditMode ? save : create) {
                    Text(isEditMode ? .localized(.save) : .localized(.create))
                        .bold()
                }.disabled(!isValid))
            .gesture(DragGesture()
                        .onChanged { _ in
                            dismissKeyboard()
                        })
        }.sheet(isPresented: $isDebugPresented) {
            DebugView()
        }.actionSheet(isPresented: $isPresentedToActionSheet) {
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
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - private

private extension EditView {
    func save() {
        do {
            if let repeatID = item?.repeatID,
               try ItemService(context: context).items(predicate: Item.predicate(repeatIDIs: repeatID)).count > .one {
                presentToActionSheet()
            } else {
                Task {
                    saveForThisItem()
                }
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
        Task {
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
    }

    func saveForFutureItems() {
        guard let item else {
            assertionFailure()
            return
        }
        Task {
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
    }

    func saveForAllItems() {
        guard let item else {
            assertionFailure()
            return
        }
        Task {
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
            isDebugPresented = true
            return
        }
        dismiss()
    }

    func presentToActionSheet() {
        isPresentedToActionSheet = true
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
    EditView()
}
