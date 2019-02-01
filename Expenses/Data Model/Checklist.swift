//
//  Checklist.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/18/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class Checklist: NSObject, Codable {
    var name = ""
    var items = [ChecklistItem]()
    var iconName = "No Icon"
    
    init (name: String, iconName: String = "No Icon") {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    func countUncheckedItems() -> Int {
        var count = 0
        
        for item in items where !item.checked {
            count += 1 
        }
        
        return count
    }
}
