//
//  CheckListItem.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/4/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, Codable {
    var text = "YAR"
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    
    func toggleChecked() {
        checked = !checked
    }
    
    override init() {
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
}
