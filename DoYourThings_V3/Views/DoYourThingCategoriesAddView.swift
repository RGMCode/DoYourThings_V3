//
//  DoYourThingCategoriesAddView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

struct DoYourThingCategoriesAddView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    @State private var categoryName: String = ""
    @State private var selectedColor: Color = .gray
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField(NSLocalizedString("categoryName", comment: "Category Name"), text: $categoryName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding()

            ColorPicker(NSLocalizedString("categoryColor", comment: "Category Color"), selection: $selectedColor)
                .padding()

            // ACHTUNG: Hier muss viewModel.addCategory(...) verwendet werden, nicht $viewModel.addCategory(...)
            /*Button(NSLocalizedString("save", comment: "Save"))
            {
                // Überprüfe, ob der Name nicht leer ist
                guard !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    print("Kategorie nicht hinzugefügt: Name ist leer.")
                    return
                }
                
                // Kategorie hinzufügen – direkt über viewModel, ohne den $-Operator!
                viewModel.addCategory(name: categoryName, color: selectedColor)
                
                // Ansicht schließen
                presentationMode.wrappedValue.dismiss()
            }*/
            
            Section {
                Button(action: {
                    // Überprüfe, ob der Name nicht leer ist
                    guard !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        print("Kategorie nicht hinzugefügt: Name ist leer.")
                        return
                    }
                    
                    // Kategorie hinzufügen – direkt über viewModel, ohne den $-Operator!
                    viewModel.addCategory(name: categoryName, color: selectedColor)
                    
                    // Ansicht schließen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(NSLocalizedString("save", comment: "Save"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            
            Spacer()
        }
        .padding()
        .navigationBarItems(trailing: Button(NSLocalizedString("cancel", comment: "Cancel")) {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct DoYourThingCategoriesAddView_Previews: PreviewProvider {
    static var previews: some View {
        DoYourThingCategoriesAddView(viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext))
    }
}

