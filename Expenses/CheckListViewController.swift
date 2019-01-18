//
//  ViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/3/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    var items = [ChecklistItem]()
    var checklist: Checklist!

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        title = checklist.name //set the title of the screen to the name of the checklist that was passed to us when performing the segue
        
        //Load the view with any saved check list items
        loadCheckListItem()
        
        print("App directory is:  \(documentsDirectory())")
        print("File path is: \(dataFilePath())")
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = items[indexPath.row] // set the item to edit to the current cell and pass it to the add item controller
            }
        }
    }
    
    func configureCheckmark(for cell: UITableViewCell,
                            with item: ChecklistItem) {
        //central function that can be called to config checkmark status of the table view cell and avoid code duplication
        let label = cell.viewWithTag(1001) as! UILabel
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        //central function that can be called to config row text and avoid code duplication
        
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //start with 1 cell
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath)
        
        let item = items[indexPath.row]
        configureText(for: cell, with: item)
        
        configureCheckmark(for: cell, with: item)
        return cell //returns the cell for the current row
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //use an if let in case the cell is not visible, this will avoid a NPE
        if let cell = tableView.cellForRow(at: indexPath) {
            
            let item = items[indexPath.row]
            item.toggleChecked() //update the data model with correct checked status
            
            configureCheckmark(for: cell, with: item) //update the tableview cell UI with correct checked status
        }
        
        //will deselect the tapped on row and animate
        tableView.deselectRow(at: indexPath, animated: true)
        saveCheckListItems()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Allows us to delete a row by swiping to delete
        items.remove(at: indexPath.row) //removes the current row from data model
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //removes the current row from the view
        saveCheckListItems()
    }

    //MARK: - AddItemViewController protocol delegate methods
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true) //dismiss the add item screen
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = items.count
        items.append(item) //item is added to the data model
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic) //item is added to the view
        navigationController?.popViewController(animated: true) //dismiss the add item screen
        saveCheckListItems()

    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        if let index = items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated: true)
        saveCheckListItems()
    }
    
    //MARK: - Data Management
    
    //Find out where app directory is
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("ShoppingList.plist")
    }
    
    func saveCheckListItems() {
        let encoder = PropertyListEncoder()
        
        // the do statement here is used since we know that the code after it can throw an error, thus we must be able to catch it if it occurs
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    func loadCheckListItem() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            
            do {
                items = try decoder.decode([ChecklistItem].self, from: data)
            }
            catch {
                print("Encountered an error trying to decode data: \(error.localizedDescription)")
            }
        }
    }

    
}
