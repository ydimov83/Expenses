//
//  AddItemViewController.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/5/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: class {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {
    
    var itemToEdit: ChecklistItem?
    var dueDate = Date()
    var datePickerVisible = false
    
    //MARK: - Outlets
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //MARK: - Delegate
    weak var delegate: ItemDetailViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemToEdit = itemToEdit {
            title = "Edit Item"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = itemToEdit.shouldRemind
            dueDate = itemToEdit.dueDate
        }
        updateDueDateLabel()
        navigationItem.largeTitleDisplayMode = .never
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        textField.becomeFirstResponder()
    }
    
    
    
    //MARK: - Actions
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let item = itemToEdit { //if we have an item to edit we want to call the didFinishEditing protocol implementation
            item.text = textField.text!
            item.dueDate = dueDate
            item.shouldRemind = shouldRemindSwitch.isOn
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditing: item)
        } else {
            let item = ChecklistItem()
            item.text = textField.text!
            item.dueDate = dueDate
            item.shouldRemind = shouldRemindSwitch.isOn
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
        
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                //do nothing
            }
        }
    }
    
    //MARK: - Tableview delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath //enables cell selection for the Date label cells
        } else {
            return nil //make sure we disable cell selection for all other cells
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //We'll show the 3rd row only if datePicker is supposed to be visible, otherwise return to default tableView behavior for returning rows
        if section == 1 && datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //We need to override the height for the datePicker cell because we're overriding default static cell behavior, without this override the app can/will crash
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        //Without this override the app will crash when trying to present the DatePicker
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //Can use this to set the Done button to disabled when user utilizes the keyboard bar's Clear button to clear out the textField's value
        doneBarButton.isEnabled = false
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    //MARK: - Helper Methods
    
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        datePicker.setDate(dueDate, animated: false) //Need this in order to show correct Date value when editing items with existing reminder dates
        dueDateLabel.textColor = dueDateLabel.tintColor
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            dueDateLabel.textColor = UIColor.black
        }
    }
    
}
