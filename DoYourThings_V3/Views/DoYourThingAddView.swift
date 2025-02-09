//
//  DoYourThingAddView.swift
//  DoYourThings_V3
//
//  Erstellt von RGMCode am 06.02.25
//

import SwiftUI
import CoreData

struct DoYourThingAddView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    var context: NSManagedObjectContext
    var initialCategory: CategoryDB?
    
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var priority: String = NSLocalizedString("medium", comment: "")
    @State private var category: CategoryDB? = nil  // Optionale Kategorie, wird später initialisiert
    
    @State private var alarmReminderDate: Date = Date()
    @State private var alarmReminderTime: Date = Date()
    @State private var alarmDeadlineDate: Date = Date()
    @State private var alarmDeadlineTime: Date = Date()
    
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: DoYourThingViewModel, context: NSManagedObjectContext, initialCategory: CategoryDB? = nil) {
        self.viewModel = viewModel
        self.context = context
        self.initialCategory = initialCategory
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    
                    // 1. Kategorie-Sektion
                    Group {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(Color(hex: category?.colorHex ?? "#000000") ?? .primary)
                            Text(NSLocalizedString("category", comment: "Category"))
                                .font(.headline)
                                .foregroundColor(Color(hex: category?.colorHex ?? "#000000") ?? .primary)
                            Spacer()
                            Picker("", selection: $category) {
                                ForEach(viewModel.categories, id: \.self) { cat in
                                    Text(cat.originalName ?? "")
                                        .tag(cat as CategoryDB?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // 2. Prioritäts-Sektion
                    Group {
                        HStack {
                            Image(systemName: "circle.hexagongrid.circle")
                                .foregroundColor(viewModel.priorityColor(priority: priority))
                                .frame(width: 20, height: 20)
                            Text(NSLocalizedString("priority", comment: "Priority"))
                                .font(.headline)
                                .foregroundColor(viewModel.priorityColor(priority: priority))
                            Spacer()
                            Picker("", selection: $priority) {
                                ForEach(viewModel.priorityOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // 3. Reminder-Sektion
                    Group {
                        HStack {
                            Text(NSLocalizedString("reminder", comment: "Reminder"))
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $alarmReminderDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            DatePicker("", selection: $alarmReminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // 4. Deadline-Sektion
                    Group {
                        HStack {
                            Text(NSLocalizedString("deadline", comment: "Deadline"))
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $alarmDeadlineDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            DatePicker("", selection: $alarmDeadlineTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // 5. Titel und Detailtext-Sektion
                    Group {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("title", comment: "Title"))
                                .font(.headline)
                            TextField(NSLocalizedString("title", comment: "Title"), text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(NSLocalizedString("detail", comment: "Detail"))
                                .font(.headline)
                            TextEditor(text: $detail)
                                .frame(minHeight: 115)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // 6. Save-Button
                    Group {
                        Button(action: { saveTask() }) {
                            Text(NSLocalizedString("save", comment: "Save"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
            }
            .navigationBarTitle(NSLocalizedString("newTask", comment: "New Task"), displayMode: .inline)
            .navigationBarItems(trailing: Button(NSLocalizedString("cancel", comment: "Cancel")) {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Setze die Kategorie beim Erscheinen: Falls initialCategory gesetzt wurde, oder ansonsten die erste Kategorie
                if let givenCat = initialCategory {
                    category = givenCat
                } else if category == nil, let first = viewModel.categories.first {
                    category = first
                }
            }
        }
    }
    
    private func saveTask() {
        guard let usedCategory = category ?? viewModel.categories.first else {
            print("Keine Kategorie vorhanden!")
            return
        }
        
        let newTask = DytDB(context: context)
        newTask.id = UUID()
        newTask.dytTitel = title
        newTask.dytDetailtext = detail
        newTask.dytPriority = priority
        newTask.dytDate = Date()
        newTask.dytTime = Date()
        newTask.dytAlarmReminderDate = alarmReminderDate
        newTask.dytAlarmReminderTime = alarmReminderTime
        newTask.dytAlarmDeadlineDate = alarmDeadlineDate
        newTask.dytAlarmDeadlineTime = alarmDeadlineTime
        newTask.categoryTasks = usedCategory
        
        do {
            try context.save()
            let convertedTask = DoYourThing(from: newTask)
            NotificationManager.shared.scheduleNotification(task: convertedTask, isReminder: true)
            NotificationManager.shared.scheduleNotification(task: convertedTask, isReminder: false)
            viewModel.fetchDYT()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Fehler beim Speichern der Aufgabe:", error)
        }
    }
}

struct DoYourThingAddView_Previews: PreviewProvider {
    static var previews: some View {
        DoYourThingAddView(
            viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext),
            context: PersistenceController.shared.container.viewContext
        )
    }
}

