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
    @Published var result = ""
        
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
                self.executeCommand()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
       
    // Method to execute the command entered by the user
    private func executeCommand() {
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
            output.send(.transactionFailed(NSError(domain: "transactions", code: 500)))
            result = "Invalid command"
        }
    }
}


private extension TrasactionsViewModel {
    func beginTransactions() {
        transactions.begin()
        result = OperationType.BEGIN.rawValue
    }
    
    func rollBack() {
        transactions.rollback()
        result =  OperationType.ROLLBACK.rawValue
    }
    
    func commit() {
        transactions.commit()
        result = OperationType.COMMIT.rawValue
    }
    
    func count() {
        let count = transactions.count(value: operation.value)
        result = "key: \(operation.value) count is: \(count)"
    }
    
    func delete() {
        transactions.delete(key: operation.key)
        result = "deleted key: \(operation.key)"
    }
    
    func get() {
        if let value = transactions.get(key: operation.key) {
          result = "get: \(operation.key) is: \(value)"
        } else {
          result = "Key not set"
          output.send(.transactionFailed(NSError(domain: "invalid request", code: 500)))
        }
    }
    
    func set() {
        if !operation.key.isEmpty && !operation.value.isEmpty {
            transactions.set(key: operation.key, value: operation.value)
            result = "set: \(operation.key) \(operation.value)"
        }
    }
}
