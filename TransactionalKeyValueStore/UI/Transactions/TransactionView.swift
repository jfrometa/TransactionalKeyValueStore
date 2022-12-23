//
//  ContentView.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 21/12/22.
//


import SwiftUI
import Combine

struct TransactionView: View, ViewProtocol {
    private let input: Input<TrasactionsViewModel.Input> = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    
    enum FormField { case key, value }
    
    @StateObject private var viewModel: TrasactionsViewModel
    @FocusState private var focusedField: FormField?

    init(viewModel: TrasactionsViewModel = TrasactionsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        
        viewModel.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                switch output {
                    
                case .transactionFailed(_):
                    viewModel.showingErrorAlert = true
                case .transactionSucceded(_):
                    viewModel.operation = Operation(key: "", value: "", type: .SET)
                }
            }.store(in: &cancellables)
    }

    var body: some View {
        return NavigationStack {
                VStack {
                    Form {
                        Section(header: Text("Store")) {
                          
                        Picker("Operations", selection: $viewModel.operation.type) {
                            ForEach(OperationType.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle() )
                        
                        Group {
                            if viewModel.isKeyFieldDisplayed {
                                TextField("Key", text: $viewModel.operation.key)
                                    .disableAutocorrection(true)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .key)
                            }
                            
                            if viewModel.isValueFieldDisplayed {
                                TextField("Value", text: $viewModel.operation.value)
                                    .submitLabel(.done)
                                    .disableAutocorrection(true)
                                    .focused($focusedField, equals: .value)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        
                        Button(action: {
                            viewModel.alertIfNeeded { input.send(.willExecuteTransaction) }
                        }) {
                            Text("Commit")
                                .frame(height: 48)
                                .background(.clear)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        }

                        Section(header: Text("Executed")) {
                            Text("\(viewModel.lastOperationDetails)")
                        }
                        
                        if !viewModel.transactions.store.isEmpty {
                            Section(header: Text("Logs")) {
                                List {
                                    ForEach(viewModel.transactions.store.sorted(by: >), id: \.key) { log in
                                        HStack {
                                            Text("key: \(log.key) value: \(log.value)")
                                                .font(.headline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .background(Color.clear)
                                }
                            }
                        }
                    }
                    .onSubmit {  self.checkFocus() }
                }
                .navigationTitle(Text("Transactions"))
                .ignoresSafeArea(.keyboard)
                .alert(isPresented: $viewModel.showingAlert) {
                    Alert(
                        title: Text("Execute \(viewModel.operation.type.rawValue) transaction"),
                        message: Text("Once done, this can't be undone!"),
                        primaryButton: .cancel( Text("Cancel"), action: {
                            viewModel.showingAlert = false
                        }),
                        secondaryButton: .default(Text("OK"), action: {
                            viewModel.showingAlert = false
                            input.send(.willExecuteTransaction)
                        })
                    )
                }
                .alert(isPresented:  $viewModel.showingErrorAlert) {
                    Alert(
                        title: Text("Upss!"),
                        message: Text("Check your inputs!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading
                )
        }
    }
    
    private func checkFocus() {
        switch focusedField {
        case .key:
            focusedField = .value
        case .value:
            focusedField =  nil
        case .none:
            focusedField =  .key
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
