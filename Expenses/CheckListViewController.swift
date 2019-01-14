//
//  ViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/3/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, AddItemViewControllerDelegate {
    
    var items = [ChecklistItem]()

  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let item1 = ChecklistItem()
        item1.checked = true
        item1.text = "i'm item 1"
        items.append(item1)
        
        let item2 = ChecklistItem()
        item2.checked = false
        item2.text = "do programming exercise"
        items.append(item2)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! AddItemViewController
            controller.delegate = self
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
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Allows us to delete a row by swiping to delete
        items.remove(at: indexPath.row) //removes the current row from data model
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //removes the current row from the view
    }

    //MARK: Add Item View Controller delegate methods
    func addItemViewControllerDidCancel(_ controller: AddItemViewController) {
        navigationController?.popViewController(animated: true) //dismiss the add item screen
    }
    
    func addItemViewController(_ controller: AddItemViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = items.count
        items.append(item) //item is added to the data model
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic) //item is added to the view
        navigationController?.popViewController(animated: true) //dismiss the add item screen
    }
    
}
