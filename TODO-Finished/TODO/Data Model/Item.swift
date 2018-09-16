//
//  Item.swift
//  TODO
//
//  Created by 刘铭 on 2018/3/3.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
  @objc dynamic var title: String = ""
  @objc dynamic var done: Bool = false
  @objc dynamic var dateCreated: Date?
  
  var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
