//
//  TrasactionsViewModel.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Foundation
import Combine

class TrasactionsViewModel: ViewModelProtocol {
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables: Set<AnyCancellable> = .init()
   
    @Published var transactions = TransactionalKeyValue()
    @Published var operation = Operation(key: "", value: "", type: .SET)
    @Published var showingAlert = false
    @Published var showingErrorAlert = false
    @Published var lastOperationDetails = ""
        
    init() {
        self.beginTransactions()
    }
    
    enum Input {
        case willExecuteTransaction
    }
    
    enum Output {
        case transactionFailed(_ error: Error)
        case transactionSucceded(_ data: String)
    }
    
    var isValueFieldDisplayed: Bool {
        operation.type == .SET || operation.type == .COUNT
    }
    
    var isKeyFieldDisplayed: Bool {
        operation.type == .SET  || operation.type == .GET || operation.type == .DELETE
    }
    
    func alertIfNeeded(_ onComplete:() -> ()) {
        switch operation.type {
        case .DELETE,  .COMMIT,  .ROLLBACK:
            showingAlert = true
        default:
            onComplete()
        }
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
            case .willExecuteTransaction:
                self.execute()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
       
    private func execute() {
        switch self.operation.type {
        case .SET:
            self.set()
        case .GET:
            self.get()
        case .DELETE:
            self.delete()
        case .COUNT:
            self.count()
        case .BEGIN:
            self.beginTransactions()
        case .COMMIT:
            self.commit()
        case .ROLLBACK:
            self.rollBack()
        default:
            self.errorWithDefault()
        }
    }
}


private extension TrasactionsViewModel {
    func beginTransactions() {
        transactions.begin()
        lastOperationDetails = OperationType.BEGIN.rawValue
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func rollBack() {
        transactions.rollback()
        lastOperationDetails =  OperationType.ROLLBACK.rawValue
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func commit() {
        transactions.commit()
        lastOperationDetails = OperationType.COMMIT.rawValue
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func count() {
        if operation.value.isEmpty {
            output.send(.transactionFailed(NSError(domain: "cant count!", code: 504)))
            return
        }
        
        let count = transactions.count(value: operation.value)
        lastOperationDetails = "key: \(operation.value) count is: \(count)"
        
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func delete() {
        transactions.delete(key: operation.key)
        lastOperationDetails = "deleted key: \(operation.key)"
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func get() {
        if let value = transactions.get(key: operation.key) {
          lastOperationDetails = "get: \(operation.key) is: \(value)"
          self.output.send(.transactionSucceded(operation.key))
        } else {
          lastOperationDetails = "Key not set"
          self.output.send(.transactionFailed(NSError(domain: "invalid request", code: 501)))
        }
    }
    
    func set() {
        if operation.key.isEmpty || operation.value.isEmpty {
            output.send(.transactionFailed(NSError(domain: "missing input field", code: 502)))
            return
        }
        
        transactions.set(key: operation.key, value: operation.value)
        lastOperationDetails = "set: \(operation.key) \(operation.value)"
        self.output.send(.transactionSucceded(operation.key))
    }
    
    func errorWithDefault() {
        output.send(.transactionFailed(NSError(domain: "platform error", code: 500)))
        lastOperationDetails = "Invalid command"
    }
}
