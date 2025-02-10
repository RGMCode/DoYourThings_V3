//
//  DoYourThingSettingView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
import SwiftUI

struct DoYourThingSettingView: View {
    @ObservedObject var viewModel: DoYourThingViewModel
    @State private var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var showRestartAlert = false

    let supportedLanguages = ["en", "de", "fr", "es", "it", "pt", "nl", "pl", "no", "sv", "fi", "el", "hr", "ro", "sk", "cs", "ca", "da", "he", "vi", "uk", "ms", "zh-Hans", "zh-Hant", "zh-HK", "th", "id"]

    var body: some View {
        List {
            NavigationLink(destination: DoYourThingManageCategoriesView(viewModel: viewModel)) {
                Text(NSLocalizedString("manageCategories", comment: "Manage Categories"))
            }
            Section(header: Text(NSLocalizedString("chooseTheme", comment: "Choose Theme"))) {
                Picker(NSLocalizedString("theme", comment: "Theme"), selection: $viewModel.theme) {
                    Text(NSLocalizedString("light", comment: "Light")).tag("Light")
                    Text(NSLocalizedString("dark", comment: "Dark")).tag("Dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                ColorPicker(NSLocalizedString("chooseIconColor", comment: "Choose an Icon Color:"), selection: $viewModel.themeIconColor)
            }
            Section(header: Text(NSLocalizedString("language", comment: "Language"))) {
                Picker(NSLocalizedString("selectLanguage", comment: "Select Language"), selection: $selectedLanguage) {
                    ForEach(supportedLanguages, id: \.self) { identifier in
                        Text(Locale(identifier: identifier).localizedString(forLanguageCode: identifier) ?? identifier)
                            .tag(identifier)
                    }
                }
                .onChange(of: selectedLanguage) { _, newValue in
                    changeLanguage(to: newValue)
                }
            }
            Section {
                NavigationLink(destination: InfoView()) {
                    Text(NSLocalizedString("info", comment: "Info"))
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings", comment: "Settings"))
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text("Restart Required"),
                message: Text("Please restart the app to apply the new language."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func changeLanguage(to languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        showRestartAlert = true
    }
}

#if DEBUG
struct DoYourThingSettingView_Previews: PreviewProvider {
    static var previews: some View {
        DoYourThingSettingView(viewModel: DoYourThingViewModel(context: PersistenceController.shared.container.viewContext))
    }
}
#endif
