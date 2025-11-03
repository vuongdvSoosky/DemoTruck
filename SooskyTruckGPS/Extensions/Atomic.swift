//
//  Atomic.swift
//  SooskyTractorGPS
//
//  Created by VuongDV on 24/8/25.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {
  private var value: Value
  private let queue = DispatchQueue(label: "AtomicQueue")
  
  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
  
  var wrappedValue: Value {
    get { queue.sync { value } }
    set { queue.sync { value = newValue } }
  }
}
