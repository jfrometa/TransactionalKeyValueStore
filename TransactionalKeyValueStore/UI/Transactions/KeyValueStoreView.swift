//
//  ContentView.swift
//  TransactionalKeyValueStore
//
//  Created by Leo Salazar on 21/12/22.
//


import SwiftUI

struct TransactionView: View {
  @State private var store = TransactionalKeyValue()
  @State private var command = ""
  @State private var key = ""
  @State private var value = ""
  @State private var result = ""

  var body: some View {
    VStack {
      HStack {
        TextField("Command", text: $command)
        TextField("Key", text: $key)
        TextField("Value", text: $value)
        Button(action: {
          self.executeCommand()
        }) {
          Text("Execute")
        }
      }
      Text("Result: \(result)")
    }
  }
  
  // Method to execute the command entered by the user
  func executeCommand() {
    let command = self.command.lowercased()
    if command == "set" {
      store.set(key: key, value: value)
      result = "Successfully set value for key: \(key)"
    } else if command == "get" {
      if let value = store.get(key: key) {
        result = "Value for key: \(key) is: \(value)"
      } else {
        result = "Key not set"
      }
    } else if command == "delete" {
      store.delete(key: key)
      result = "Successfully deleted key: \(key)"
    } else if command == "count" {
      let count = store.count(value: value)
      result = "Number of keys with value: \(value) is: \(count)"
    } else if command == "begin" {
      store.begin()
      result = "Transaction started"
    } else if command == "commit" {
      store.commit()
      result = "Transaction committed"
    } else if command == "rollback" {
      store.rollback()
      result = "Transaction rolled back"
    } else {
      result = "Invalid command"
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
