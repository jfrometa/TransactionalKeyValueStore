//
//  Operation.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Foundation

struct Operation {
    var key: String
    var value: String
    var type: OperationType
}

enum OperationType: String, CaseIterable {
    case SET
    case GET
    case DELETE
    case COUNT
    case BEGIN
    case COMMIT
    case ROLLBACK
}
