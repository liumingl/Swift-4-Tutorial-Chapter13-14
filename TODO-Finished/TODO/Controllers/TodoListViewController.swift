//
//  ViewController.swift
//  TODO
//
//  Created by 刘铭 on 2018/2/23.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UITableViewController {
  
  let realm = try! Realm()
  var todoItems: Results<Item>?
  
  var selectedCategory: Category? {
    didSet {
      loadItems()
    }
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = 80.0
    tableView.separatorStyle = .none
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let colourHex = selectedCategory?.colour {
      title = selectedCategory!.name
      guard let navBar = navigationController?.navigationBar else {
        fatalError("导航栏不存在！")
      }
      
      if let navBarColor = UIColor(hexString: colourHex) {
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
      }
      
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    guard let originalcolour = UIColor(hexString: "1D9BF6" ) else { fatalError() }
    
    navigationController?.navigationBar.barTintColor = originalcolour
    navigationController?.navigationBar.tintColor = FlatWhite()
    navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
  }
  
  //MARK: - Table View DataSource methods
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
    cell.delegate = self
    
    if let item = todoItems?[indexPath.row] {
      cell.textLabel?.text = item.title
      cell.accessoryType = item.done == true ? .checkmark : .none
      
      if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
        cell.backgroundColor = colour
        cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
      }
      
      
    }else {
      cell.textLabel?.text = "没有事项"
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoItems?.count ?? 1
  }
  
  //MARK: - Table View Delegate methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if let item = todoItems?[indexPath.row] {
      do {
        try realm.write {
          item.done = !item.done
        }
      }catch {
        print("保存完成状态失败：\(error)")
      }
    }
    
    tableView.beginUpdates()
    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    tableView.endUpdates()
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  //MARK: - Add New Items
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()

    let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "", preferredStyle: .alert)

    let action = UIAlertAction(title: "添加项目", style: .default) { (action) in
      // 当用户点击添加项目按钮以后要执行的代码
      
      if let currentCategory = self.selectedCategory {
        do {
          try self.realm.write {
            let newItem = Item()
            newItem.title = textField.text!
            newItem.dateCreated = Date()
            currentCategory.items.append(newItem)
          }
        }catch {
          print("保存Item发生错误：\(error)")
        }
      }
      self.tableView.reloadData()
    }

    alert.addTextField { (alertTextField) in
      alertTextField.placeholder = "创建一个新项目..."
      textField = alertTextField
    }

    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  func loadItems() {
    todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    
    tableView.reloadData()
  }
}

// MARK: - Swipe Cell Delegate Methods
extension TodoListViewController: SwipeTableViewCellDelegate {
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: "删除") { action, indexPath in
      if let itemForDeletion = self.todoItems?[indexPath.row] {
        do {
          try self.realm.write {
            self.realm.delete(itemForDeletion)
          }
        }catch {
          print("删除事项失败：\(error)")
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

//MARK: - 搜索栏方法
extension TodoListViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    todoItems = todoItems?.filter("title CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    tableView.reloadData()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
      loadItems()
      
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
}


