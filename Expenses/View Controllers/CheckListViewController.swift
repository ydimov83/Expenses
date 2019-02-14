//
//  ViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/3/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class CheckListViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    var checklist: Checklist!
    var dataModel =  DataModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        title = checklist.name //set the title of the screen to the name of the checklist that was passed to us when performing the segue
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
                controller.itemToEdit = checklist.items[indexPath.row] // set the item to edit to the current cell and pass it to the add item controller
            }
        }
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        //central function that can be called to config checkmark status of the table view cell and avoid code duplication
        if item.checked {
            cell.imageView?.image = UIImage(named: "Check")
        } else {
            cell.imageView?.image = UIImage(named: "No Icon")
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        //central function that can be called to config row text and avoid code duplication
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        cell.detailTextLabel?.text = formatter.string(from: item.dueDate)
        cell.textLabel?.text = item.text
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //start with 1 cell
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath)
        
        let item = checklist.items[indexPath.row]
        configureText(for: cell, with: item)
        
        configureCheckmark(for: cell, with: item)
        return cell //returns the cell for the current row
        
        
        //
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath)
        //        let item = checklist.items[indexPath.row]
        //
        //        let formatter = DateFormatter()
        //        formatter.dateStyle = .medium
        //        formatter.timeStyle = .short
        //        print(item.text)
        //        let formattedDateLabelText = formatter.string(from: item.dueDate)
        //        print("formatted label: \(formattedDateLabelText)")
        //        cell.detailTextLabel?.text = formattedDateLabelText
        //        cell.textLabel?.text = item.text
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //use an if let in case the cell is not visible, this will avoid a NPE
        if let cell = tableView.cellForRow(at: indexPath) {
            
            let item = checklist.items[indexPath.row]
            item.toggleChecked() //update the data model with correct checked status
            
            configureCheckmark(for: cell, with: item) //update the tableview cell UI with correct checked status
        }
        
        //will deselect the tapped on row and animate
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Allows us to delete a row by swiping to delete
        checklist.items.remove(at: indexPath.row) //removes the current row from data model
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //removes the current row from the view
    }
    
    //MARK: - AddItemViewController protocol delegate methods
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true) //dismiss the add item screen
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item) //item is added to the data model
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic) //item is added to the view
        dataModel.sortChecklistItems(list: checklist)
        tableView.reloadData()
        navigationController?.popViewController(animated: true) //dismiss the add item screen
        
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        if let index = checklist.items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        dataModel.sortChecklistItems(list: checklist)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
}
