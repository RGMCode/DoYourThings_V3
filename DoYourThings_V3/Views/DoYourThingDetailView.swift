//
//  DoYourThingDetailView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI
import CoreData

struct DoYourThingDetailView: View {
    @State var dyt: DoYourThing      // Lokale State-Variable für die aktuell angezeigte Aufgabe
    @ObservedObject var viewModel: DoYourThingViewModel
    let context: NSManagedObjectContext

    @State private var isPresentingEditView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Darstellung der Kategorie, Datum, Uhrzeit etc.
                HStack {
                    Spacer()
                    Image(systemName: "folder.fill")
                        .foregroundColor(Color(hex: dyt.category?.colorHex ?? "#000000") ?? .blue)
                    Text(dyt.category?.originalName ?? NSLocalizedString("uncategorized", comment: "Uncategorized"))
                        .font(.headline)
                        .foregroundColor(Color(hex: dyt.category?.colorHex ?? "#000000") ?? .blue)
                
                //.padding(.horizontal)
                    
                    Spacer()
                    
                    // Priorität
                    
                        Image(systemName: "circle.hexagongrid.circle")
                            .foregroundColor(viewModel.priorityColor(priority: dyt.dytPriority))
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("priority", comment: "Priority"))
                            .font(.headline)
                            .foregroundColor(viewModel.priorityColor(priority: dyt.dytPriority))
                    Spacer()
                            
                }.padding()

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.yellow)
                        Text("\(NSLocalizedString("date", comment: "Date")): \(dyt.dytDate, formatter: dateFormatter)")
                            .font(.subheadline)
                    }
                    HStack{
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                        Text("\(NSLocalizedString("time", comment: "Time")): \(dyt.dytTime, formatter: timeFormatter)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                        Text("\(NSLocalizedString("reminder", comment: "Reminder")): \(dyt.dytAlarmReminderDate, formatter: dateFormatter) – \(dyt.dytAlarmReminderTime, formatter: timeFormatter)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("\(NSLocalizedString("deadline", comment: "Deadline")): \(dyt.dytAlarmDeadlineDate, formatter: dateFormatter) – \(dyt.dytAlarmDeadlineTime, formatter: timeFormatter)")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                Divider()

                Text(dyt.dytTitel)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Text(dyt.dytDetailtext)
                    .font(.body)
                    .padding(.horizontal)

                Spacer()

                // Bearbeiten-Button
                HStack {
                    Spacer()
                    Button(NSLocalizedString("edit", comment: "Edit")) {
                        isPresentingEditView = true
                    }
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle(dyt.dytTitel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("edit", comment: "Edit")) {
                    isPresentingEditView = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            DoYourThingEditView(
                viewModel: viewModel,
                task: dyt,
                context: context,
                onSave: { updatedTask in
                    // Sobald in der Edit-View gespeichert wurde, aktualisieren wir dyt
                    dyt = updatedTask
                }
            )
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#if DEBUG
struct DoYourThingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let exampleTask = DoYourThing(
            id: UUID(),
            dytTitel: "Example Task",
            dytDetailtext: "This is an example detail text for the task.",
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
            DoYourThingDetailView(dyt: exampleTask, viewModel: viewModel, context: context)
        }
    }
}
#endif
