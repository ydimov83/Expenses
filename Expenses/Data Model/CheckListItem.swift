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
    
    func toggleChecked() {
        checked = !checked
    }
}
