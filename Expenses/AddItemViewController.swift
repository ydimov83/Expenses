//
//  AddItemViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/5/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

protocol AddItemViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: AddItemViewController)
    func addItemViewController(_ controller: AddItemViewController, didFinishAdding item: ChecklistItem)
    func addItemViewController(_ controller: AddItemViewController, didFinishEditing item: ChecklistItem)
}

class AddItemViewController: UITableViewController, UITextFieldDelegate {
    
    var itemToEdit: ChecklistItem?
    
    //MARK: - Outlets
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    //MARK: - Delegate
    weak var delegate: AddItemViewControllerDelegate?
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemToEdit = itemToEdit {
            title = "Edit Item"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
        }
        navigationItem.largeTitleDisplayMode = .never

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        textField.becomeFirstResponder()
    }
    
   
    
    //MARK: - Actions
    @IBAction func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }

    @IBAction func done() {
        if let item = itemToEdit { //if we have an item to edit we want to call the didFinishEditing protocol implementation
            item.text = textField.text!
            delegate?.addItemViewController(self, didFinishEditing: item)
        } else {
            let item = ChecklistItem()
            item.text = textField.text!
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
        
    }
    
    //MARK: - Tableview delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil //make sure we disable cell selection, only text field is selectable
    }
    
   
    // MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange,
                                                  with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //Can use this to set the Done button to disabled when user utilizes the keyboard bar's Clear button to clear out the textField's value
        doneBarButton.isEnabled = false
        return true
    }
    
}
