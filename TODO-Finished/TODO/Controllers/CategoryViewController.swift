//
//  CategoryViewController.swift
//  TODO
//
//  Created by 刘铭 on 2018/3/2.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {
  
  let realm = try! Realm()
  
  var categories: Results<Category>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadCategories()
    
    tableView.rowHeight = 80.0
    
    tableView.separatorStyle = .none
  }
  
  //MARK: - 添加新的类别
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textField = UITextField()
    
    let alert = UIAlertController(title: "添加新的类别", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "添加", style: .default) { (action) in
      let newCategory = Category()
      newCategory.name = textField.text!
      newCategory.colour = UIColor.randomFlat.hexValue()
      self.save(category: newCategory)
    }
    
    alert.addAction(action)
    alert.addTextField { (field) in
      textField = field
      textField.placeholder = "添加一个新的类别"
    }
    
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: - Table View Data Source 方法
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories?.count ?? 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
    cell.delegate = self
    cell.textLabel?.text = categories?[indexPath.row].name ?? "没有任何的类别"
    
    guard let categoryColour = UIColor(hexString: categories?[indexPath.row].colour ?? "1D9BF6") else { fatalError() }
    
    cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
    cell.backgroundColor = categoryColour
  
    return cell
  }
  
  //MARK: - Table View Delegate 方法
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "goToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! TodoListViewController
    
    if segue.identifier == "goToItems" {
      if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categories?[indexPath.row]
      }
    }
  }
  
  //MARK: - Table View 数据维护方法
  
  func save(category: Category) {
    do {
      try realm.write {
        realm.add(category)
      }
    }catch {
      print("保存Category错误：\(error)")
    }
    tableView.reloadData()
  }
  
  func loadCategories() {
    categories = realm.objects(Category.self)
    
    tableView.reloadData()
  }
  
}


// MARK: - Swipe Cell Delegate Methods

extension CategoryViewController: SwipeTableViewCellDelegate {
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: "删除") { action, indexPath in
      if let categoryForDeletion = self.categories?[indexPath.row] {
        do {
          try self.realm.write {
            self.realm.delete(categoryForDeletion)
          }
        }catch {
          print("删除类别失败：\(error)")
        }
      }
    }
    
    // customize the action appearance
    deleteAction.image = UIImage(named: "Trash-Icon")
    
    return [deleteAction]
  }
  
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
    var options = SwipeTableOptions()
    options.expansionStyle = .destructive
    // options.transitionStyle = .border
    return options
  }
}

