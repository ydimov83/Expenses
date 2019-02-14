//
//  DataModel.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/23/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import Foundation


class DataModel {
    var lists = [Checklist]()
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "CheckListIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CheckListIndex")
        }
    }
    
    init () {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    // Class level method (instead of instance method) so that we can call this without having a direct reference to a DataModel object
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        
        return itemID
    }
    //MARK: - Data Management
    
    //Find out where app directory is
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("pathing stuff: \(paths[0])")
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("ShoppingList.plist")
    }
    
    func saveChecklists() {
        let encoder = PropertyListEncoder()
        
        // the do statement here is used since we know that the code after it can throw an error, thus we must be able to catch it if it occurs
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    func loadChecklists() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            
            do {
                lists = try decoder.decode([Checklist].self, from: data)
                sortChecklist()
            }
            catch {
                print("Encountered an error trying to decode data: \(error.localizedDescription)")
            }
        }
    }
    
    func registerDefaults() {
        let dictionary = [ "CheckListIndex": -1, "FirstTime": true ] as [String : Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
            
        }
    }
    
    func sortChecklist() {
        lists.sort(by:
            { list1, list2 in
                return list1.name.localizedStandardCompare(list2.name)
                    == .orderedAscending})
    }
    
    func sortChecklistItems(list: Checklist) {
            list.items.sort(by:
                { item1, item2 in
                    return item1.dueDate.compare(item2.dueDate)
                        == .orderedAscending})
        
    }
}

