//
//  DoYourThing.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

struct DoYourThing: Identifiable, Hashable {
    var id: UUID
    var dytTitel: String
    var dytDetailtext: String
    var dytPriority: String
    var dytTime: Date
    var dytDate: Date
    var dytAlarmReminderDate: Date
    var dytAlarmReminderTime: Date
    var dytAlarmDeadlineDate: Date
    var dytAlarmDeadlineTime: Date
    var category: CategoryDB?
    
    // Custom initializer: Wandelt ein DytDB-Objekt in ein DoYourThing-Objekt um.
    init(from taskDB: DytDB) {
        self.id = taskDB.id ?? UUID()
        self.dytTitel = taskDB.dytTitel ?? ""
        self.dytDetailtext = taskDB.dytDetailtext ?? ""
        self.dytPriority = taskDB.dytPriority ?? ""
        self.dytTime = taskDB.dytTime ?? Date()
        self.dytDate = taskDB.dytDate ?? Date()
        self.dytAlarmReminderDate = taskDB.dytAlarmReminderDate ?? Date()
        self.dytAlarmReminderTime = taskDB.dytAlarmReminderTime ?? Date()
        self.dytAlarmDeadlineDate = taskDB.dytAlarmDeadlineDate ?? Date()
        self.dytAlarmDeadlineTime = taskDB.dytAlarmDeadlineTime ?? Date()
        self.category = taskDB.categoryTasks
    }
    
    // normaler Initializer
    init(id: UUID, dytTitel: String, dytDetailtext: String, dytPriority: String, dytTime: Date, dytDate: Date, dytAlarmReminderDate: Date, dytAlarmReminderTime: Date, dytAlarmDeadlineDate: Date, dytAlarmDeadlineTime: Date, category: CategoryDB?) {
        self.id = id
        self.dytTitel = dytTitel
        self.dytDetailtext = dytDetailtext
        self.dytPriority = dytPriority
        self.dytTime = dytTime
        self.dytDate = dytDate
        self.dytAlarmReminderDate = dytAlarmReminderDate
        self.dytAlarmReminderTime = dytAlarmReminderTime
        self.dytAlarmDeadlineDate = dytAlarmDeadlineDate
        self.dytAlarmDeadlineTime = dytAlarmDeadlineTime
        self.category = category
    }
}


