//
//  ViewProtocol.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 22/12/22.
//

import Combine

protocol ViewProtocol {
    typealias Input<T> = PassthroughSubject<T, Never>
    typealias Output<K> = AnyPublisher<K, Never>
}
