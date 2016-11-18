//
//  Array+Add.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import Foundation

/// Conditional append methods added to Array
public extension Array {
    
    /// Check if the condition is true, generate the item and insert it
    ///
    /// - parameter condition: condition to test
    /// - parameter item:      a closure to generate the item to insert
    public mutating func add(if condition:@autoclosure ()-> Bool, item:(()-> Element)) {
        guard condition() else { return }
        let concreteItem = item()
        self.append(concreteItem)
    }
    
    /// Check if the condition is not nil and unwrap it, passing the value to the closure to generate the item
    ///
    /// - parameter condition: a closure that returns an optional
    /// - parameter item:      the closure that will use the unwrapped value to generate the item
    public mutating func add<T>(ifLet condition:@autoclosure ()-> T?, item:((T)-> Element)) {
        guard let value = condition() else { return }
        let concreteItem = item(value)
        self.append(concreteItem)
    }
    
    /// Check if the condition is not nil and unwrap it, passing the value to the closure to generate the item. If the value is nill use the else block to generate an item
    ///
    /// - parameter condition: a closure that returns an optional
    /// - parameter item:      the closure that will use the unwrapped value to generate the item
    /// - parameter elseItem:  a closure that receives no value and generate an item to add to the collection
    public mutating func add<T>(ifLet condition:@autoclosure ()-> T?, item:((T)-> Element), elseItem:(()-> Element)) {
        let concreteItem: Element
        if let value = condition() {
            concreteItem = item(value)
        }
        else {
            concreteItem = elseItem()
        }
        self.append(concreteItem)
    }
    
    /// Add many items from the closure to the array
    ///
    /// - parameter items: the closure that will generate the items
    public mutating func add(many items:(()-> [Element])) {
        let concreteItems = items()
        self.append(contentsOf: concreteItems)
    }
    
    /// check if the condition is true and than invokes the closure to generate and add the items
    ///
    /// - parameter condition: condition to check
    /// - parameter items:     the closure that will generate the items
    public mutating func add(manyIf condition:@autoclosure ()-> Bool, items:(()-> [Element])) {
        guard condition() else { return }
        let concreteItems = items()
        self.append(contentsOf: concreteItems)
    }
    
    /// Check if the condition is not nil and unwrap it, passing the value to the closure to generate the items
    ///
    /// - parameter condition: a closure that returns an optional
    /// - parameter items:     the closure that will use the unwrapped value to generate the items
    public mutating func add<T>(manyIfLet condition:@autoclosure ()-> T?, items:((T)-> [Element])) {
        guard let value = condition() else { return }
        let concreteItems = items(value)
        self.append(contentsOf: concreteItems)
    }
    
    /// check if a condition is true and generates the according item using the right closure
    ///
    /// - parameter condition: the closure to check
    /// - parameter itemTrue:  the closure to generate the item if the condition is true
    /// - parameter itemFalse: the closure to generate the item if the condition is false
    public mutating func add(ifTrue condition:@autoclosure ()-> Bool, itemTrue:(()-> Element), itemFalse:(()-> Element)) {
        let concreteItem: Element
        if condition() {
            concreteItem = itemTrue()
        }
        else {
            concreteItem = itemFalse()
        }
        self.append(concreteItem)
    }
    
    /// check if a condition is true and generates the according items using the right closure
    ///
    /// - parameter condition:  the closure to check
    /// - parameter itemsTrue:  the closure to generate the items if the condition is true
    /// - parameter itemsFalse: the closure to generate the items if the condition is false
    public mutating func add(manyIfTrue condition:@autoclosure ()-> Bool, itemsTrue:(()-> [Element]), itemsFalse:(()-> [Element])) {
        let concreteItems: [Element]
        if condition() {
            concreteItems = itemsTrue()
        }
        else {
            concreteItems = itemsFalse()
        }
        self.append(contentsOf: concreteItems)
    }
    
}
