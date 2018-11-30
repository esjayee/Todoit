//
//  Category.swift
//  Todoit
//
//  Created by Susan Emmons on 29/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    // define child items relationship
    let items = List<Item>()
    
}
