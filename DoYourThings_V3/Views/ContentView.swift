//
//  ContentView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    // Für die Vorschau verwenden wir einen Binding‑Parameter deepLinkTaskId, im realen Einsatz wird DeepLinkManager genutzt.
    @Binding var deepLinkTaskId: String?
    
    // DeepLinkManager als EnvironmentObject (wird in DoYourThingsApp gesetzt)
    @EnvironmentObject var deepLinkManager: DeepLinkManager

    @State private var filter: String = NSLocalizedString("by_date_and_priority", comment: "")
    @State private var selectedCategory: CategoryDB? = nil
    
    // Sheet-/Action-Zustände
    @State private var isPresentingAddView = false
    @State private var isPickerPresented = false
    @State private var isPresentingSearchView = false
    @State private var isPresentingInfoView = false
    
    // Lösch-Alert
    @State private var isShowingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet? = nil
    
    // Für das Öffnen einer Aufgabe via Deep Link/Notification
    @State private var selectedTask: DoYourThing? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                categoryPicker
                taskList
            }
            .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
            .onAppear(perform: onAppearAction)
            .alert(isPresented: $isShowingDeleteAlert, content: deleteAlert)
            .background(
                NavigationLink(
                    destination: destinationForSelectedTask,
                    isActive: Binding(
                        get: { selectedTask != nil },
                        set: { newValue in
                            if !newValue { selectedTask = nil }
                        }
                    )
                ) {
                    EmptyView()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(viewModel.theme == "Light" ? .light : .dark)
        .onReceive(deepLinkManager.$pendingTaskId) { taskId in
            processDeepLink(with: taskId)
        }
        // Für die Vorschau (optional, da deepLinkTaskId in der Preview verwendet wird)
        .onReceive(Just(deepLinkTaskId)) { _ in
            processDeepLink(with: deepLinkTaskId)
        }
    }
    
    // MARK: - Hilfsfunktion zur DeepLink-Verarbeitung
    private func processDeepLink(with taskId: String?) {
        guard let taskId = taskId, !taskId.isEmpty else { return }
        if let foundTask = viewModel.dyts.first(where: { $0.id.uuidString == taskId }) {
            selectedTask = foundTask
        } else {
            // Falls die Tasks noch nicht vollständig geladen sind, versuche es nach einer kurzen Verzögerung erneut.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let foundTask = viewModel.dyts.first(where: { $0.id.uuidString == taskId }) {
                    selectedTask = foundTask
                }
            }
        }
        // Nach der Verarbeitung zurücksetzen:
        deepLinkManager.pendingTaskId = nil
        deepLinkTaskId = nil
    }
    
    // MARK: - Computed Properties
    private var categoryPicker: some View {
        let bgColor: Color = {
            if let cat = selectedCategory, let hex = cat.colorHex {
                return Color(hex: hex) ?? .clear
            }
            return .clear
        }()
        return Picker(NSLocalizedString("category", comment: "Category Picker"), selection: $selectedCategory) {
            ForEach(viewModel.categories, id: \.self) { cat in
                Text(cat.originalName ?? "???")
                    .tag(cat as CategoryDB?)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(bgColor)
        .cornerRadius(8)
        .padding()
    }
    
    private var filteredTasks: [DoYourThing] {
        if let selectedCat = selectedCategory {
            return viewModel.filteredTasks(for: selectedCat, filter: filter)
        }
        return []
    }
    
    private var taskList: some View {
        Group {
            if selectedCategory != nil {
                List {
                    ForEach(filteredTasks, id: \.id) { task in
                        Button(action: {
                            selectedTask = task
                        }) {
                            HStack {
                                Image(systemName: "circle.hexagongrid.circle")
                                    .foregroundColor(viewModel.priorityColor(priority: task.dytPriority))
                                    .font(.system(size: 25))
                                Text(task.dytTitel)
                                Spacer()
                            }
                        }
                    }
                    .onDelete(perform: handleDelete)
                }
            } else {
                Text(NSLocalizedString("noCategorySelected", comment: "No category selected"))
            }
        }
    }
    
    private var leadingBarItems: some View {
        HStack {
            Button(action: { isPresentingAddView = true }) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .foregroundColor(viewModel.themeIconColor) // Stelle sicher, dass hier keine andere Definition existiert
                    .font(.system(size: 30))
            }
            .sheet(isPresented: $isPresentingAddView) {
                DoYourThingAddView(viewModel: viewModel, context: viewModel.context, initialCategory: selectedCategory)
            }
            
            Button(action: { isPresentingSearchView = true }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(viewModel.themeIconColor)
                    .font(.system(size: 30))
            }
            .sheet(isPresented: $isPresentingSearchView) {
                DoYourThingSearchView(viewModel: viewModel, context: viewModel.context)
            }
        }
    }
    
    private var trailingBarItems: some View {
        HStack {
            Button(action: { isPresentingInfoView = true }) {
                Image(systemName: "info.circle")
                    .foregroundColor(viewModel.themeIconColor)
                    .font(.system(size: 30))
            }
            .sheet(isPresented: $isPresentingInfoView) {
                DoYourThingPriorityInformationView()
            }
            
            Button(action: { isPickerPresented = true }) {
                Image(systemName: "blinds.horizontal.open")
                    .foregroundColor(viewModel.themeIconColor)
                    .font(.system(size: 30))
            }
            .actionSheet(isPresented: $isPickerPresented) {
                ActionSheet(
                    title: Text(NSLocalizedString("filter", comment: "")),
                    message: Text(NSLocalizedString("choose_filter_option", comment: "")),
                    buttons: [
                        .default(Text(NSLocalizedString("by_date_and_priority", comment: ""))) {
                            filter = NSLocalizedString("by_date_and_priority", comment: "")
                            viewModel.fetchDYT()
                        },
                        .default(Text(NSLocalizedString("by_priority_and_date", comment: ""))) {
                            filter = NSLocalizedString("by_priority_and_date", comment: "")
                            viewModel.fetchDYT()
                        },
                        .default(Text(NSLocalizedString("by_reminder", comment: ""))) {
                            filter = NSLocalizedString("by_reminder", comment: "")
                            viewModel.fetchDYT()
                        },
                        .default(Text(NSLocalizedString("by_deadline", comment: ""))) {
                            filter = NSLocalizedString("by_deadline", comment: "")
                            viewModel.fetchDYT()
                        },
                        .default(Text(NSLocalizedString("overdue_tasks", comment: ""))) {
                            filter = NSLocalizedString("overdue_tasks", comment: "")
                            viewModel.fetchDYT()
                        },
                        .cancel()
                    ]
                )
            }
            
            NavigationLink(destination: DoYourThingSettingView(viewModel: viewModel)) {
                Image(systemName: "gear")
                    .foregroundColor(viewModel.themeIconColor)
                    .font(.system(size: 30))
            }
        }
    }
    
    private var destinationForSelectedTask: some View {
        Group {
            if let task = selectedTask {
                DoYourThingDetailView(dyt: task, viewModel: viewModel, context: viewModel.context)
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Actions
    private func onAppearAction() {
        if selectedCategory == nil, let firstCat = viewModel.categories.first {
            selectedCategory = firstCat
        }
        viewModel.fetchDYT()
    }
    
    private func handleDelete(at offsets: IndexSet) {
        if let index = offsets.first, let selectedCat = selectedCategory {
            let tasks = viewModel.filteredTasks(for: selectedCat, filter: filter)
            if index < tasks.count {
                let taskToDelete = tasks[index]
                viewModel.deleteDYT(task: taskToDelete)
            }
            deleteIndexSet = nil
        }
    }
    
    private func deleteAlert() -> Alert {
        Alert(
            title: Text(NSLocalizedString("deleteTaskTitle", comment: "Delete Task")),
            message: Text(NSLocalizedString("deleteTaskMessage", comment: "Are you sure you want to delete this task?")),
            primaryButton: .destructive(Text(NSLocalizedString("deleteButton", comment: "Delete"))) {
                if let indexSet = deleteIndexSet,
                   let index = indexSet.first,
                   let selectedCat = selectedCategory {
                    let tasks = viewModel.filteredTasks(for: selectedCat, filter: filter)
                    if index < tasks.count {
                        let taskToDelete = tasks[index]
                        viewModel.deleteDYT(task: taskToDelete)
                    }
                    deleteIndexSet = nil
                }
            },
            secondaryButton: .cancel(Text(NSLocalizedString("cancelButton", comment: "Cancel")))
        )
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext),
                    deepLinkTaskId: .constant(nil))
            .environmentObject(DeepLinkManager.shared)
    }
}
#endif
