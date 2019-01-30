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
    
    init (name: String) {
        self.name = name
        super.init()
    }
}
