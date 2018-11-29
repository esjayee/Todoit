//
//  CategoryViewController.swift
//  Todoit
//
//  Created by Susan Emmons on 27/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    // get AppDelegate instance to access persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }

    // MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // MARK: Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Unable to save category \(error)")
        }
        
        // refresh table data
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Unable to fetch categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (_) in
            // what will happen when user clicks the add item button on our UIAlert
            if let text = textField.text {
                
                if text.count > 0 {
                    let newCategory = Category(context: self.context)
                    newCategory.name = text
                    
                    self.categories.append(newCategory)
                    
                    // save new item
                    self.saveCategories()
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
            destinationVC.selectedCategory = categories[indexPath.row] 
        }
        
        
    }

}
