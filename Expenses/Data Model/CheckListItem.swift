//
//  CheckListItem.swift
//  Expenses
//
//  Created by Yavor Dimov on 1/4/19.
//  Copyright © 2019 Yavor Dimov. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, Codable {
    var text = "YAR"
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    

    
    override init() {
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    
    deinit {
        //When a CheckListItem is about to be destroyed we want to remove any existing notification for that item
        removeNotification()
    }
    
    func toggleChecked() {
        checked = !checked
    }
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
}
