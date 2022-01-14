//
//  EditView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct EditView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.presentationMode)
    var presentationMode

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
        return item != nil
    }

    private var isValid: Bool {
        return content.isNotEmpty
            && income.isEmptyOrDecimal
            && outgo.isEmptyOrDecimal
    }

    init() {}

    init(of item: Item) {
        self.item = item
        _date = State(initialValue: item.date)
        _content = State(initialValue: item.content)
        _income = State(initialValue: item.income.stringValue)
        _outgo = State(initialValue: item.outgo.stringValue)
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
                        TextField(String.empty, text: $group)
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
                   let item = item {
                    Section(content: {
                        Text(item.description)
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
        if item?.repeatID == nil {
            Task {
                saveForThisItem()
            }
        } else {
            presentToActionSheet()
        }
    }

    func saveForThisItem() {
        guard let item = item else {
            assertionFailure()
            return
        }
        Task {
            do {
                try ItemService(context: viewContext)
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
        guard let item = item else {
            assertionFailure()
            return
        }
        Task {
            do {
                try ItemService(context: viewContext)
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
        guard let item = item else {
            assertionFailure()
            return
        }
        Task {
            do {
                try ItemService(context: viewContext)
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
            try ItemService(context: viewContext)
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

#if DEBUG
struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
#endif
