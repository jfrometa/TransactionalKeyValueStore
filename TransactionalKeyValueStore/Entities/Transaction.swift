//
//  Transaction.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Foundation

class Transaction {
  var parent: Transaction?
  var operations: [Operation]
  var store: [String: String] = [:]
    
  init(parent: Transaction?) {
    self.parent = parent
    operations = []
  }

      // Method to add an operation to the transaction
      func addOperation(key: String, value: String, operation: OperationType) {
        operations.append(Operation(key: key,value: value, type: operation))
      }
        // Method to get the value for a key in this transaction
        func getValue(key: String) -> String? {
            for operation in operations.reversed() {
                if operation.key == key {
                    if operation.type == .SET {
                        return operation.value
                    } else if operation.type == .DELETE {
                        return nil
                    }
                }
            }
            return parent?.getValue(key: key)
        }

        // Method to count the number of keys with a given value in this transaction
        func count(value: String) -> Int {
        var count = 0
            
        for operation in operations.reversed() {
            if operation.value == value {
                if operation.type == .SET {
                count += 1
                } else if operation.type == .DELETE {
                count -= 1
                }
            }
        }
            
            return parent?.count(value: value) ?? 0 + count
        }

        // Method to commit the changes in this transaction
        func commit() {
            for operation in operations {
                if operation.type == .SET {
                    store[operation.key] = operation.value
                } else if operation.type == .DELETE {
                    store.removeValue(forKey: operation.key)
                }
            }
        }

        // Method to rollback the changes in this transaction
        func rollback() {
        // No need to do anything, the changes will be discarded when the transaction is removed from the stack
        }
    }
