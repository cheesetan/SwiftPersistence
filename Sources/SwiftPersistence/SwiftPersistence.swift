// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@available(iOS 13.0, *)
@propertyWrapper
struct Persistence<PersistenceValue> : DynamicProperty {
    private var value: String
    
    init(wrappedValue: String) {
        self.value = wrappedValue.lowercased()
    }
    
    var wrappedValue: String {
        get { value }
        set { value = newValue.lowercased() }
    }
}
