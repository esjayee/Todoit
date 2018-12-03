//
//  CategoryViewController.swift
//  Todoit
//
//  Created by Susan Emmons on 27/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
        
    }
    
    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // call ancestor function to get cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added"
        
        cell.backgroundColor = UIColor.randomFlat
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return categories count, but if nil then return 1
        return categories?.count ?? 1
    }
    
    // MARK: Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Unable to save category \(error)")
        }
        
        // refresh table data
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {

                    for item in category.items {
                        self.realm.delete(item)
                    }

                    self.realm.delete(category)
                }
            } catch {
                print("Unable to delete category \(error)")
            }
        }
    }
    
    // MARK: Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (_) in
            // what will happen when user clicks the add item button on our UIAlert
            if let text = textField.text {
                
                if text.count > 0 {
                    let newCategory = Category()
                    newCategory.name = text
                    
                    // save new item
                    self.save(category: newCategory)
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    // MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // downcast destination controller as descendent todo list controller
        let destinationVC = segue.destination as! TodoListViewController
        
        // get reference to currently selected row
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] 
        }
    }
}

