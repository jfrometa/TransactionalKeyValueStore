//
//  TransactionalKeyValueStoreApp.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 21/12/22.
//

import SwiftUI

@main
struct Main: App {
    
    var body: some Scene {
        WindowGroup {
            TransactionView()
                .environment(\.colorScheme, .light)
        }
    }
}
