//
//  DoYourThingSearchView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI
import CoreData

struct DoYourThingSearchView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    let context: NSManagedObjectContext

    @State private var searchText: String = ""
    @State private var selectedTask: DoYourThing? = nil

    var body: some View {
        NavigationView {
            VStack {
                TextField(NSLocalizedString("searchPlaceholder", comment: "Search..."), text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        viewModel.searchTasks(query: newValue)
                    }
                
                List(viewModel.searchResults, id: \.id) { task in
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
                .sheet(item: $selectedTask) { task in
                    DoYourThingDetailView(dyt: task, viewModel: viewModel, context: context)
                }
            }
            .navigationTitle(NSLocalizedString("search", comment: "Search"))
        }
        .onAppear {
            viewModel.searchTasks(query: "")
        }
    }
}

struct DoYourThingSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DoYourThingSearchView(
            viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext),
            context: PersistenceController.shared.container.viewContext
        )
    }
}

