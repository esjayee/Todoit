//
//  ViewController.swift
//  Todoit
//
//  Created by Susan Emmons on 20/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    // set selected category as optional datatype as it will initially not have a value
    var selectedCategory : Category? {
        // didSet is like a trigger activated when selectedCategory is set
        didSet {
            self.title = selectedCategory!.name
            loadItems()
        }
    }

    // get AppDelegate instance to access persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))
        
    }

    // MARK: - tableview datasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // MARK: - tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // toggle done property
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoit item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen when user clicks the add item button on our UIAlert
            if let text = textField.text {
                
                if text.count > 0 {
                    let newItem = Item(context: self.context)
                    newItem.title = text
                    newItem.parentCategory = self.selectedCategory
                    
                    self.itemArray.append(newItem)
                    
                    // save new item
                    self.saveItems()
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
    
    func saveItems() {
     
        do {
            try context.save()
        } catch {
            print("Unable to save item \(error)")
        }
        
        // refresh table data
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Unable to fetch items \(error)")
        }
        
        tableView.reloadData()
    }
}

// MARK: - search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // set filter / search criteria
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // set sort (expects an array of sort descriptors)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // retrieve items
        loadItems(with: request, predicate: predicate)

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
