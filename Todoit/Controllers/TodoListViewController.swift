//
//  ViewController.swift
//  Todoit
//
//  Created by Susan Emmons on 20/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    var toDoItems : Results<Item>?
    let realm = try! Realm()
    
    // set selected category as optional datatype as it will initially not have a value
    var selectedCategory : Category? {
        // didSet is like a trigger activated when selectedCategory is set
        didSet {
            self.title = selectedCategory!.name
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - tableview datasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // call ancestor function to get cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items to display"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    // MARK: - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                item.done = !item.done
                }
            } catch {
                print("Unable to save done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Unable to delete item \(error)")
            }
        }
    }
    
    // MARK: - add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoit item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen when user clicks the add item button on our UIAlert
            if let text = textField.text {
                
                if text.count > 0 {
                    
                    if let currentCategory = self.selectedCategory {
                        do {
                            let newItem = Item()
                            newItem.title = text
                            
                            try self.realm.write {
                                self.realm.add(newItem)
                                currentCategory.items.append(newItem)
                            }
                        } catch {
                            print("Unable to save item \(error)")
                        }
                    }
                    
                    self.loadItems()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        
        // gets all items for a given parent category
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
}

// MARK: - search bar methods
extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // when user clears text in the searchbar
        if searchBar.text?.count == 0 {
            // load all items
            loadItems()

            // make the following run in the main queue / thread (foreground)
            DispatchQueue.main.async {
                // lose focus from searchbar
                searchBar.resignFirstResponder()
            }
        }
    }
}
