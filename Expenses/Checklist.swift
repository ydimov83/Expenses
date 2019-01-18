//
//  Checklist.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/18/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import UIKit

class Checklist: NSObject {
    var name = ""
    
    init (name: String) {
        self.name = name
        super.init()
    }
}
