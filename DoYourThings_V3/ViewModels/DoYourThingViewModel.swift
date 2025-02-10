//
//  DoYourThingViewModel.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import Foundation
import CoreData
import SwiftUI

class DoYourThingViewModel: ObservableObject {
    
    // MARK: - Properties
    let context: NSManagedObjectContext
    @Published var dyts: [DoYourThing] = []
    @Published var searchResults: [DoYourThing] = []
    @Published var categories: [CategoryDB] = []
    
    // Persistiere das Theme in den UserDefaults.
    @Published var theme: String = "Dark" {
        didSet {
            UserDefaults.standard.set(theme, forKey: "AppTheme")
        }
    }
    
    // Eine einzige @Published-Eigenschaft für die Icon-Farbe.
    @Published var themeIconColor: Color = .teal {
        didSet {
            if let hex = UIColor(themeIconColor).toHex() {
                UserDefaults.standard.set(hex, forKey: "ThemeIconColor")
            }
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        // Theme laden
        let savedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? "Dark"
        self.theme = savedTheme
        
        // Icon-Farbe laden
        if let hex = UserDefaults.standard.string(forKey: "ThemeIconColor"),
           let uiColor = UIColor(hex: hex) {
            self.themeIconColor = Color(uiColor)
        } else {
            self.themeIconColor = .teal
        }
        
        fetchCategories()
        fetchDYT()
    }
    
    // MARK: - Categories-Methods
    func fetchCategories() {
        let request: NSFetchRequest<CategoryDB> = CategoryDB.fetchRequest()
        do {
            let results = try context.fetch(request)
            print("=== fetchCategories DEBUG: found \(results.count) CategoryDB objects in the DB ===")
            for (i, cat) in results.enumerated() {
                print("   Category #\(i): objectID=\(cat.objectID) | originalName=\"\(cat.originalName ?? "nil")\" | colorHex=\"\(cat.colorHex ?? "nil")\"")
            }
            
            self.categories = results
            self.categories.removeAll { $0.originalName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true }
            
            if self.categories.isEmpty {
                let privateCategory = CategoryDB(context: context)
                privateCategory.originalName = NSLocalizedString("privateCategory", comment: "Default category for private tasks")
                privateCategory.colorHex = "#4CAF50FF"
                
                let workCategory = CategoryDB(context: context)
                workCategory.originalName = NSLocalizedString("workCategory", comment: "Default category for work tasks")
                workCategory.colorHex = "#2196F3FF"
                
                try context.save()
                fetchCategories()
                return
            } else {
                let localizedPrivate = NSLocalizedString("privateCategory", comment: "Default category for private tasks")
                let localizedWork = NSLocalizedString("workCategory", comment: "Default category for work tasks")
                categories.sort {
                    if $0.originalName == localizedPrivate { return true }
                    else if $1.originalName == localizedPrivate { return false }
                    else if $0.originalName == localizedWork { return true }
                    else if $1.originalName == localizedWork { return false }
                    else { return ($0.originalName ?? "") < ($1.originalName ?? "") }
                }
            }
        } catch {
            print("Fehler beim Abrufen der Kategorien:", error)
        }
    }
    
    func addCategory(name: String, color: Color) {
        let newCat = CategoryDB(context: context)
        newCat.originalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        newCat.colorHex = UIColor(color).toHex() ?? "#000000FF"
        
        do {
            try context.save()
            fetchCategories()
        } catch {
            print("Fehler beim Speichern der Kategorie:", error)
        }
    }
    
    func updateCategory(category: CategoryDB, newName: String, color: Color) {
        category.originalName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        category.colorHex = UIColor(color).toHex() ?? "#000000FF"
        
        do {
            try context.save()
            fetchCategories()
            fetchDYT()
        } catch {
            print("Fehler beim Aktualisieren der Kategorie:", error)
        }
    }
    
    
    func deleteCategory(category: CategoryDB) {
        let request: NSFetchRequest<DytDB> = DytDB.fetchRequest()
        request.predicate = NSPredicate(format: "categoryTasks == %@", category)
        
        do {
            let tasks = try context.fetch(request)
            for t in tasks {
                context.delete(t)
            }
            context.delete(category)
            try context.save()
            fetchCategories()
            fetchDYT()
        } catch {
            print("Fehler beim Löschen der Kategorie:", error)
        }
    }
    
    
    // MARK: - DYT-Methods
    func fetchDYT() {
        let request: NSFetchRequest<DytDB> = DytDB.fetchRequest()
        do {
            let results = try context.fetch(request)
            print("=== fetchDYT DEBUG: found \(results.count) tasks in the DB ===")
            for (i, taskDB) in results.enumerated() {
                let cat = taskDB.categoryTasks
                print("   Task #\(i): Titel=\"\(taskDB.dytTitel ?? "nil")\" | CatName=\"\(cat?.originalName ?? "nil")\" | CatID=\(String(describing: cat?.objectID))")
            }
            self.dyts = results.map { taskDB in
                DoYourThing(
                    id: taskDB.id ?? UUID(),
                    dytTitel: taskDB.dytTitel ?? "",
                    dytDetailtext: taskDB.dytDetailtext ?? "",
                    dytPriority: taskDB.dytPriority ?? "",
                    dytTime: taskDB.dytTime ?? Date(),
                    dytDate: taskDB.dytDate ?? Date(),
                    dytAlarmReminderDate: taskDB.dytAlarmReminderDate ?? Date(),
                    dytAlarmReminderTime: taskDB.dytAlarmReminderTime ?? Date(),
                    dytAlarmDeadlineDate: taskDB.dytAlarmDeadlineDate ?? Date(),
                    dytAlarmDeadlineTime: taskDB.dytAlarmDeadlineTime ?? Date(),
                    category: taskDB.categoryTasks
                )
            }
            self.searchResults = self.dyts
        } catch {
            print("Fehler beim Abrufen der Aufgaben:", error)
        }
    }
    
    func addDYT(
        title: String,
        detail: String,
        priority: String,
        category: CategoryDB,
        date: Date,
        time: Date,
        alarmReminderDate: Date,
        alarmReminderTime: Date,
        alarmDeadlineDate: Date,
        alarmDeadlineTime: Date
    ) {
        let newTask = DytDB(context: context)
        newTask.id = UUID()
        newTask.dytTitel = title
        newTask.dytDetailtext = detail
        newTask.dytPriority = priority
        newTask.dytDate = date
        newTask.dytTime = time
        newTask.dytAlarmReminderDate = alarmReminderDate
        newTask.dytAlarmReminderTime = alarmReminderTime
        newTask.dytAlarmDeadlineDate = alarmDeadlineDate
        newTask.dytAlarmDeadlineTime = alarmDeadlineTime
        newTask.categoryTasks = category
        
        do {
            try context.save()
            let convertedTask = DoYourThing(from: newTask)  // Hier nur ein Argument
            NotificationManager.shared.scheduleNotification(task: convertedTask, isReminder: true)
            NotificationManager.shared.scheduleNotification(task: convertedTask, isReminder: false)
            fetchDYT()
        } catch {
            print("Fehler beim Speichern der neuen Aufgabe:", error)
        }
    }
    
    func updateTask(task: DoYourThing,
                    title: String,
                    detail: String,
                    priority: String,
                    alarmReminderDate: Date,
                    alarmReminderTime: Date,
                    alarmDeadlineDate: Date,
                    alarmDeadlineTime: Date,
                    category: CategoryDB) {
        let updatedTask = DoYourThing(
            id: task.id,
            dytTitel: title,
            dytDetailtext: detail,
            dytPriority: priority,
            dytTime: task.dytTime,
            dytDate: task.dytDate,
            dytAlarmReminderDate: alarmReminderDate,
            dytAlarmReminderTime: alarmReminderTime,
            dytAlarmDeadlineDate: alarmDeadlineDate,
            dytAlarmDeadlineTime: alarmDeadlineTime,
            category: category
        )
        updateDYT(task: updatedTask)
    }
    
    func updateDYT(task: DoYourThing) {
        // Alte Notifikationen für diese Aufgabe entfernen
        NotificationManager.shared.removeNotification(task: task)
        
        let request: NSFetchRequest<DytDB> = DytDB.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let taskToUpdate = results.first {
                // Aktualisiere alle Felder der Aufgabe
                taskToUpdate.dytTitel = task.dytTitel
                taskToUpdate.dytDetailtext = task.dytDetailtext
                taskToUpdate.dytPriority = task.dytPriority
                taskToUpdate.dytDate = task.dytDate
                taskToUpdate.dytTime = task.dytTime
                taskToUpdate.dytAlarmReminderDate = task.dytAlarmReminderDate
                taskToUpdate.dytAlarmReminderTime = task.dytAlarmReminderTime
                taskToUpdate.dytAlarmDeadlineDate = task.dytAlarmDeadlineDate
                taskToUpdate.dytAlarmDeadlineTime = task.dytAlarmDeadlineTime
                taskToUpdate.categoryTasks = task.category
                
                try context.save()
                
                // Erzeuge das aktualisierte DoYourThing-Objekt aus dem Core Data-Objekt
                let updatedTask = DoYourThing(from: taskToUpdate)
                
                // Neue Notifikationen planen
                NotificationManager.shared.scheduleNotification(task: updatedTask, isReminder: true)
                NotificationManager.shared.scheduleNotification(task: updatedTask, isReminder: false)
                
                fetchDYT()
            } else {
                print("Aufgabe nicht gefunden (id: \(task.id))")
            }
        } catch {
            print("Fehler beim Aktualisieren der Aufgabe: \(error)")
        }
    }
    
    func deleteTask(task: DoYourThing) {
        let request: NSFetchRequest<DytDB> = DytDB.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let taskToDelete = results.first {
                context.delete(taskToDelete)
                try context.save()
                fetchDYT()
            }
        } catch {
            print("Fehler beim Löschen der Aufgabe:", error)
        }
    }
    
    func deleteDYT(task: DoYourThing) {
        deleteTask(task: task)
    }
    
    
    // MARK: - Search-Methods
    func searchTasks(query: String) {
        if query.isEmpty {
            searchResults = dyts
        } else {
            searchResults = dyts.filter { task in
                task.dytTitel.localizedCaseInsensitiveContains(query) ||
                task.dytDetailtext.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    // MARK: - Filter-Methods
    // Diese Funktion liefert die gefilterte und ggf. sortierte Liste von Aufgaben für eine gegebene Kategorie und Filteroption.
    func filteredTasks(for category: CategoryDB, filter: String) -> [DoYourThing] {
        // Zuerst werden alle Aufgaben ausgewählt, die zur angegebenen Kategorie gehören.
        var tasks = dyts.filter { $0.category?.objectID == category.objectID }
        
        // Nun sortieren oder filtern wir anhand des übergebenen Filterstrings.
        switch filter {
        case NSLocalizedString("by_date_and_priority", comment: ""):
            // Sortiere zuerst nach Datum (neueste zuerst) und dann nach Priorität (höhere Priorität zuerst)
            tasks.sort {
                if $0.dytDate != $1.dytDate {
                    return $0.dytDate > $1.dytDate
                } else {
                    return priorityRank($0.dytPriority) > priorityRank($1.dytPriority)
                }
            }
        case NSLocalizedString("by_priority_and_date", comment: ""):
            // Sortiere zuerst nach Priorität, dann nach Datum
            tasks.sort {
                let rank0 = priorityRank($0.dytPriority)
                let rank1 = priorityRank($1.dytPriority)
                if rank0 != rank1 {
                    return rank0 > rank1
                } else {
                    return $0.dytDate > $1.dytDate
                }
            }
        case NSLocalizedString("by_reminder", comment: ""):
            // Sortiere Aufgaben nach dem Reminder-Datum und -Zeit (früheste zuerst)
            tasks.sort {
                if $0.dytAlarmReminderDate != $1.dytAlarmReminderDate {
                    return $0.dytAlarmReminderDate < $1.dytAlarmReminderDate
                } else {
                    return $0.dytAlarmReminderTime < $1.dytAlarmReminderTime
                }
            }
        case NSLocalizedString("by_deadline", comment: ""):
            // Sortiere Aufgaben nach dem Deadline-Datum und -Zeit (früheste zuerst)
            tasks.sort {
                if $0.dytAlarmDeadlineDate != $1.dytAlarmDeadlineDate {
                    return $0.dytAlarmDeadlineDate < $1.dytAlarmDeadlineDate
                } else {
                    return $0.dytAlarmDeadlineTime < $1.dytAlarmDeadlineTime
                }
            }
        case NSLocalizedString("overdue_tasks", comment: ""):
            // Filtere alle Aufgaben heraus, die überfällig sind.
            let now = Date()
            tasks = tasks.filter { ($0.dytAlarmReminderDate < now) || ($0.dytAlarmDeadlineDate < now) }
        default:
            break
        }
        return tasks
    }

    // Diese Hilfsfunktion ordnet einem Prioritäts-String einen numerischen Rang zu,
    // sodass wir Aufgaben besser sortieren können.
    private func priorityRank(_ priority: String) -> Int {
        switch priority {
        case NSLocalizedString("veryHigh", comment: ""):
            return 5
        case NSLocalizedString("high", comment: ""):
            return 4
        case NSLocalizedString("medium", comment: ""):
            return 3
        case NSLocalizedString("low", comment: ""):
            return 2
        case NSLocalizedString("veryLow", comment: ""):
            return 1
        default:
            return 0
        }
    }
    
    var priorityOptions: [String] {
        [
            NSLocalizedString("veryHigh", comment: ""),
            NSLocalizedString("high", comment: ""),
            NSLocalizedString("medium", comment: ""),
            NSLocalizedString("low", comment: ""),
            NSLocalizedString("veryLow", comment: "")
        ]
    }

    func priorityColor(priority: String) -> Color {
        switch priority {
        case NSLocalizedString("veryHigh", comment: ""):
            return .red
        case NSLocalizedString("high", comment: ""):
            return .orange
        case NSLocalizedString("medium", comment: ""):
            return .yellow
        case NSLocalizedString("low", comment: ""):
            return .green
        case NSLocalizedString("veryLow", comment: ""):
            return .blue
        default:
            return .gray
        }
    }



}

