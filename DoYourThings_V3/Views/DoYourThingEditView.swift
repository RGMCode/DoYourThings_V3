//
//  DoYourThingEditView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI
import CoreData

struct DoYourThingEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DoYourThingViewModel
    let context: NSManagedObjectContext
    @State var task: DoYourThing

    // Bearbeitungsfelder
    @State private var title: String
    @State private var detail: String
    @State private var priority: String
    @State private var selectedCategory: CategoryDB

    // Datums-/Uhrzeitfelder für Reminder und Deadline
    @State private var alarmReminderDate: Date
    @State private var alarmReminderTime: Date
    @State private var alarmDeadlineDate: Date
    @State private var alarmDeadlineTime: Date

    @State private var showingDeleteAlert = false

    // Callback-Closure, das nach dem Speichern den aktualisierten Task zurückgibt
    var onSave: ((DoYourThing) -> Void)? = nil

    init(viewModel: DoYourThingViewModel, task: DoYourThing, context: NSManagedObjectContext, onSave: ((DoYourThing) -> Void)? = nil) {
        self.viewModel = viewModel
        self.context = context
        self.task = task
        self.onSave = onSave
        
        _title = State(initialValue: task.dytTitel)
        _detail = State(initialValue: task.dytDetailtext)
        _priority = State(initialValue: task.dytPriority)
        let existingCategory = task.category ?? viewModel.categories.first!
        _selectedCategory = State(initialValue: existingCategory)
        
        _alarmReminderDate = State(initialValue: task.dytAlarmReminderDate)
        _alarmReminderTime = State(initialValue: task.dytAlarmReminderTime)
        _alarmDeadlineDate = State(initialValue: task.dytAlarmDeadlineDate)
        _alarmDeadlineTime = State(initialValue: task.dytAlarmDeadlineTime)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Kategorie-Sektion
                    Group {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(Color(hex: selectedCategory.colorHex ?? "#000000") ?? .primary)
                            Text(NSLocalizedString("category", comment: "Category"))
                                .font(.headline)
                                .foregroundColor(Color(hex: selectedCategory.colorHex ?? "#000000") ?? .primary)
                            Spacer()
                            Picker("", selection: $selectedCategory) {
                                ForEach(viewModel.categories, id: \.self) { cat in
                                    Text(cat.originalName ?? "")
                                        .tag(cat)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // Prioritäts-Sektion
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
                                ForEach(viewModel.priorityOptions, id: \.self) { p in
                                    Text(p).tag(p)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // Reminder-Sektion
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
                    
                    // Deadline-Sektion
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
                    
                    // Titel und Detailtext-Sektion
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
                    
                    // Buttons (Save und Delete)
                    Group {
                        Button(action: { saveTask() }) {
                            Text(NSLocalizedString("save", comment: "Save"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Button(action: { showingDeleteAlert = true }) {
                            Text(NSLocalizedString("delete", comment: "Delete"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("edit", comment: "Edit Task"))
            .navigationBarItems(trailing: Button(NSLocalizedString("cancel", comment: "Cancel")) {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text(NSLocalizedString("deleteTaskTitle", comment: "Delete Task")),
                    message: Text(NSLocalizedString("deleteTaskMessage", comment: "Are you sure you want to delete this task?")),
                    primaryButton: .destructive(Text(NSLocalizedString("deleteButton", comment: "Delete"))) {
                        deleteTask()
                    },
                    secondaryButton: .cancel(Text(NSLocalizedString("cancel", comment: "Cancel")))
                )
            }
        }
    }
    
    private func saveTask() {
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
            category: selectedCategory
        )
        viewModel.updateDYT(task: updatedTask)
        viewModel.fetchDYT()  // (Optional: Aktualisiere die Aufgabenliste im ViewModel)
        onSave?(updatedTask)  // Übergibt den aktualisierten Task an den Callback
        presentationMode.wrappedValue.dismiss()
    }

    private func deleteTask() {
        viewModel.deleteDYT(task: task)
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
struct DoYourThingEditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let exampleTask = DoYourThing(
            id: UUID(),
            dytTitel: "Example Task",
            dytDetailtext: "This is the example detail text for the task.",
            dytPriority: NSLocalizedString("medium", comment: ""),
            dytTime: Date(),
            dytDate: Date(),
            dytAlarmReminderDate: Date(),
            dytAlarmReminderTime: Date(),
            dytAlarmDeadlineDate: Date(),
            dytAlarmDeadlineTime: Date(),
            category: nil
        )
        let viewModel = DoYourThingViewModel(context: context)
        return NavigationView {
            DoYourThingEditView(viewModel: viewModel, task: exampleTask, context: context)
        }
    }
}
#endif

