//
//  TransactionalKeyValue.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Foundation

class TransactionalKeyValue {
    var store = [String: String]()
    var transactionStack = [Dictionary<String, String>]()
    
    func set(key: String,  value: String) {
        store[key] = value
    }

    func get(key: String) -> String? {
        return store[key]
    }
    
    func delete(key: String) {
        store.removeValue(forKey: key)
    }
        
    func count(value: String) -> Int {
        return store.filter { $0.value == value }.count
    }
    
    func begin() {
        // Push a copy of the current store to the transaction stack
        let copy = store
        transactionStack.append(copy)
    }
    
    func commit() {
        _ = transactionStack.popLast()
    }
    
    func rollback() {
        // Pop the top element from the transaction stack and set it as the current store
        if let previousState = transactionStack.popLast() {
            store = previousState
        }
    }
}
