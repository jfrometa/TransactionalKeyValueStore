//
//  TransactionalKeyValueStoreTests.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Leo Salazar on 21/12/22.
//

import XCTest
import Combine
@testable import TransactionalKeyValueStore

final class TransactionalKeyValueStoreTests: XCTestCase {
    func testExecuteCommand() {
           let viewModel = TrasactionsViewModel()
           viewModel.operation = .init(key: "key1", value: "value1", type: .SET)
        
           let input: PassthroughSubject<TrasactionsViewModel.Input, Never> = .init()
        
           let cancellable = viewModel
            .transform(input: input.eraseToAnyPublisher())
            .sink(receiveCompletion: { (completion) in
               switch completion {
               case .failure(let error):
                   XCTFail("Unexpected error: \(error)")
               case .finished:
                   break
               }
                
           }) { (output) in
               switch output {
               case .transactionFailed(let error):
                   XCTFail("Unexpected error: \(error)")
               case .transactionSucceded(let data):
                   XCTAssertEqual(data, "key1")
               }
           }
        
           input.send(.willExecuteTransaction)
           cancellable.cancel()
       }
    
    func testNestedTransactions() {
         let viewModel = TrasactionsViewModel()
         let input: PassthroughSubject<TrasactionsViewModel.Input, Never> = .init()
         let cancellable = viewModel
            .transform(input: input.eraseToAnyPublisher())
            .sink(receiveCompletion: { (completion) in
             switch completion {
             case .failure(let error):
                 XCTFail("Unexpected error: \(error)")
             case .finished:
                 break
             }
                
         }) { (output) in
             switch output {
             case .transactionFailed(let error):
                 XCTFail("Unexpected error: \(error)")
             case .transactionSucceded(let data):
                 print("key: \(data)")
             }
         }
       
        viewModel.operation = .init(key: "foo", value: "123", type: .SET)
        input.send(.willExecuteTransaction)
        viewModel.operation = .init(key: "bar", value: "456", type: .SET)
        input.send(.willExecuteTransaction)
        viewModel.operation = .init(key: "", value: "", type: .BEGIN)
        input.send(.willExecuteTransaction)
        viewModel.operation = .init(key: "foo", value: "456", type: .SET)
        input.send(.willExecuteTransaction)
        viewModel.operation = .init(key: "", value: "", type: .BEGIN)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "", value: "456", type: .COUNT)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "", type: .GET)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "789", type: .SET)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "", type: .GET)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "", value: "", type: .ROLLBACK)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "", type: .GET)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "", type: .DELETE)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "", value: "", type: .ROLLBACK)
        input.send(.willExecuteTransaction)
         viewModel.operation = .init(key: "foo", value: "", type: .GET)
        input.send(.willExecuteTransaction)
        
        XCTAssertEqual(viewModel.transactions.get(key: "foo"), "123")
        XCTAssertEqual(viewModel.transactions.get(key: "bar"), "456")
        cancellable.cancel()
     }
}
