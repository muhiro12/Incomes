//
//  EditView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct EditView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State private var isPresentedToActionSheet = false

    @State private var date = Date()
    @State private var content: String = .empty
    @State private var income: String = .empty
    @State private var expenditure: String = .empty
    @State private var group: String = .empty
    @State private var repeatSelection: Int = .zero

    private var item: ListItem?

    private var isEditMode: Bool {
        return item != nil
    }

    private var isValid: Bool {
        return content.isNotEmpty
            && income.isEmptyOrDecimal
            && expenditure.isEmptyOrDecimal
    }

    init() {}

    init(of item: ListItem) {
        self.item = item
        _date = State(initialValue: item.date)
        _content = State(initialValue: item.content)
        _income = State(initialValue: item.income.isZero ? .empty : item.income.description)
        _expenditure = State(initialValue: item.expenditure.isZero ? .empty : item.expenditure.description)
        _group = State(initialValue: item.group)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(.localized(.information))) {
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
                        Text(.localized(.expenditure))
                        TextField(String.zero, text: $expenditure)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(expenditure.isEmptyOrDecimal ? .primary : .red)
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
                }
            }.selectedListStyle()
            .navigationBarTitle(isEditMode ? .localized(.editTitle) : .localized(.createTitle))
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
                            self.dismissKeyboard()
                        })
        }.navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $isPresentedToActionSheet) {
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
    }
}

// MARK: - private

private extension EditView {
    func save() {
        if item?.original?.repeatId == nil {
            Task {
                saveForThisItem()
            }
        } else {
            presentToActionSheet()
        }
    }

    func saveForThisItem() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue,
                            original: self.item?.original)
        Task {
            do {
                try Repository.save(context, item: item)
            } catch {
                assertionFailure(error.localizedDescription)
            }
            dismiss()
        }
    }

    func saveForFutureItems() {
        guard let oldItem = item else {
            assertionFailure()
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Task {
            do {
                try await Repository.saveForFutureItems(context,
                                                        oldItem: oldItem,
                                                        newItem: newItem)
            } catch {
                assertionFailure(error.localizedDescription)
            }
            dismiss()
        }
    }

    func saveForAllItems() {
        guard let oldItem = item else {
            assertionFailure()
            return
        }
        let newItem = ListItem(date: date,
                               content: content,
                               group: group,
                               income: income.decimalValue,
                               expenditure: expenditure.decimalValue,
                               original: self.item?.original)
        Task {
            do {
                try await Repository.saveForAllItems(context,
                                                     oldItem: oldItem,
                                                     newItem: newItem)
            } catch {
                assertionFailure(error.localizedDescription)
            }
            dismiss()
        }
    }

    func create() {
        let item = ListItem(date: date,
                            content: content,
                            group: group,
                            income: income.decimalValue,
                            expenditure: expenditure.decimalValue)
        do {
            try Repository.create(context,
                                  item: item,
                                  repeatCount: repeatSelection + .one)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        dismiss()
    }

    func delete() {
        guard let item = item else {
            assertionFailure()
            return
        }
        Repository.delete(context, item: item)
    }

    func cancel() {
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
