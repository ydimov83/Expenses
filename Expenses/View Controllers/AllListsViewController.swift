//
//  AllListsViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/16/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class AllListsViewController:
UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
    
    let cellIdentifier = "CheckListCell"
    var dataModel: DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Reload the table data so we can show up to date counts of items left to-do in subtitle
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        
        //If we have a real entry in UserDefaults navigate to that list
        if index >= 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get cell
        let cell: UITableViewCell
        if let c = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = c
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let checklist = dataModel.lists[indexPath.row]
        //Update cell info with data from model
        cell.textLabel?.text = checklist.name
        cell.accessoryType = .detailDisclosureButton
        //Set the UIImmage for the subtitle text
        cell.imageView!.image  = UIImage(named: checklist.iconName)
        
        //Set subtitle text
        if checklist.items.count > 0
        {
            let count = checklist.countUncheckedItems()
            //use of ternary conditional operator to perform an if else
            cell.detailTextLabel!.text = count == 0 ? "All done!" : "\(checklist.countUncheckedItems()) Remaining"
        } else {
            cell.detailTextLabel!.text = "No items"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier:
            "ListDetailViewController") as! ListDetailViewController
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Write the currently selected row to UserDefaults so we can default to that screen on startup if needed
        dataModel.indexOfSelectedChecklist = indexPath.row
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as? CheckListViewController
            controller?.checklist = sender as? Checklist
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as? ListDetailViewController
            controller?.delegate = self
        }
    }
    
    //MARK: - Navigation controller delegates
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        //If back button was tapped we want to set the row index to -1, a value that doesn't exist, so we know to go back to the default list view
        if viewController === self {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
    
    //MARK: ListDetailViewController delegate implementation
    
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklist()
        tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        dataModel.sortChecklist()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
}
