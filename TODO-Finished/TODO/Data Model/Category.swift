//
//  Category.swift
//  TODO
//
//  Created by 刘铭 on 2018/3/3.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category: Object {
  @objc dynamic var name: String = ""
  @objc dynamic var colour: String = ""
  
  let items = List<Item>()
}
