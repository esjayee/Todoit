//
//  Item.swift
//  Todoit
//
//  Created by Susan Emmons on 29/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date = Date()
    
    // set inverse parent category relationship by linking
    // to items relationship in Category class
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
