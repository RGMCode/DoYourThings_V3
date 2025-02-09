//
//  DoYourThingManageCategoriesView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

struct DoYourThingManageCategoriesView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    @State private var isPresentingAddView = false
    @State private var isShowingDeleteAlert = false
    @State private var categoryToDelete: CategoryDB?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        NavigationLink(
                            destination: DoYourThingCategoriesEditView(viewModel: viewModel, category: cat)
                        ) {
                            HStack {
                                Text(cat.originalName ?? "")
                                Spacer()
                                // Zeige ein farbiges Icon – passe ggf. das Systemimage an
                                Image(systemName: "square.fill")
                                    .foregroundColor(Color(hex: cat.colorHex ?? "#000000") ?? .black)
                                    .font(.system(size: 25))
                            }
                        }
                    }
                    .onDelete(perform: handleDelete)
                }
                
                Button(NSLocalizedString("addCategory", comment: "Add Category")) {
                    isPresentingAddView = true
                }
                .padding()
                .sheet(isPresented: $isPresentingAddView) {
                    DoYourThingCategoriesAddView(viewModel: viewModel)
                }
            }
            .navigationTitle(NSLocalizedString("manageCategories", comment: "Manage Categories"))
            .alert(isPresented: $isShowingDeleteAlert) {
                Alert(
                    title: Text(NSLocalizedString("deleteCategoryTitle", comment: "Delete Category")),
                    message: Text(NSLocalizedString("deleteCategoryMessage", comment: "Are you sure you want to delete this category? All tasks in this category will also be deleted.")),
                    primaryButton: .destructive(Text(NSLocalizedString("deleteButton", comment: "Delete"))) {
                        if let cat = categoryToDelete {
                            viewModel.deleteCategory(category: cat)
                            categoryToDelete = nil
                        }
                    },
                    secondaryButton: .cancel {
                        categoryToDelete = nil
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            categoryToDelete = viewModel.categories[index]
            isShowingDeleteAlert = true
        }
    }
}

struct DoYourThingManageCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        DoYourThingManageCategoriesView(viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext))
    }
}

