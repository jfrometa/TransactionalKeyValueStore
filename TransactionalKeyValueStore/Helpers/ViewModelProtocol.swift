//
//  ViewModelProtocol.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Foundation
import Combine


protocol ViewModelProtocol: ObservableObject {
    associatedtype Input
    associatedtype Output

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
