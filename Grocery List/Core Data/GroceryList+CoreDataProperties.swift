//
//  GroceryList+CoreDataProperties.swift
//  Grocery List
//
//  Created by Pranab Raj Satyal on 5/17/21.
//
//

import Foundation
import CoreData


extension GroceryList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryList> {
        return NSFetchRequest<GroceryList>(entityName: "GroceryList")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?

}

extension GroceryList : Identifiable {

}
