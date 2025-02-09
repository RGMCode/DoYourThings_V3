//
//  DoYourThingCategoriesEditView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

struct DoYourThingCategoriesEditView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    @Environment(\.presentationMode) var presentationMode

    var category: CategoryDB

    @State private var newName: String
    @State private var newColor: Color

    init(viewModel: DoYourThingViewModel, category: CategoryDB) {
        self.viewModel = viewModel
        self.category = category
        // Initialisiere newName und newColor basierend auf der vorhandenen Kategorie
        _newName = State(initialValue: category.originalName ?? "")
        _newColor = State(initialValue: Color(hex: category.colorHex ?? "#000000") ?? .gray)
    }

    var body: some View {
        VStack(spacing: 16) {
            TextField(NSLocalizedString("categoryName", comment: "Category Name"), text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            ColorPicker(NSLocalizedString("categoryColor", comment: "Category Color"), selection: $newColor)
                .padding(.horizontal)

            Button(action: {
                // Rufe updateCategory direkt über viewModel auf – ohne $viewModel
                viewModel.updateCategory(category: category, newName: newName, color: newColor)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text(NSLocalizedString("save", comment: "Save"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: Button(NSLocalizedString("cancel", comment: "Cancel")) {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct DoYourThingCategoriesEditView_Previews: PreviewProvider {
    static var previews: some View {
        // Für die Vorschau wird ein Dummy-ViewModel verwendet.
        // In einem echten Projekt musst du hier einen gültigen NSManagedObjectContext übergeben.
        let context = PersistenceController.shared.container.viewContext
        // Erstelle eine Dummy-Kategorie. (Hier kann es zu Kompilierungswarnungen kommen, da CategoryDB normalerweise mit einem Kontext initialisiert wird.
        // Für die Vorschau genügt es, wenn du eine Dummy-Instanz erstellst, sofern du den Kontext nicht tatsächlich verwendest.)
        let dummyCategory = CategoryDB(context: context)
        dummyCategory.originalName = "Privat"
        dummyCategory.colorHex = "#4CAF50FF"
        
        return NavigationView {
            DoYourThingCategoriesEditView(viewModel: DoYourThingViewModel(context: context), category: dummyCategory)
        }
    }
}

