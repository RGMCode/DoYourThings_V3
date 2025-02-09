//
//  ManualView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 09.02.25.
//

//
//  ManualView.swift
//  DoYourThings_V3
//
//  Created by [Dein Name] on [Datum].
import SwiftUI

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Überschrift
                    /*Text(NSLocalizedString("manual_title", comment: "Manual Title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    
                    Divider() */
                    
                    // 1. Einführung / Introduction
                    cardView(title: NSLocalizedString("manual_intro_title", comment: "Introduction"),
                             content: NSLocalizedString("manual_intro_text", comment: "Introduction text. All data is stored locally on your device."))
                    
                    // 2. Kategorien / Categories
                    cardView(title: NSLocalizedString("manual_categories_title", comment: "Categories"),
                             content: NSLocalizedString("manual_categories_text", comment: "Default categories such as \"Private\" and \"Work\" are shown. You can add, edit, or delete categories and assign each a unique color."))
                    
                    // 3. Aufgaben / Tasks
                    cardView(title: NSLocalizedString("manual_tasks_title", comment: "Tasks"),
                             content: NSLocalizedString("manual_tasks_text", comment: "Create, edit, and delete tasks. Each task includes a title, detailed information, a priority, and reminder/deadline times."))
                    
                    // 4. Benachrichtigungen / Notifications
                    cardView(title: NSLocalizedString("manual_notifications_title", comment: "Notifications"),
                             content: NSLocalizedString("manual_notifications_text", comment: "The app automatically schedules notifications for reminders and deadlines. Tapping a notification opens the corresponding task directly."))
                    
                    // 5. Einstellungen / Settings
                    cardView(title: NSLocalizedString("manual_settings_title", comment: "Settings"),
                             content: NSLocalizedString("manual_settings_text", comment: "Customize the theme (Light/Dark) and icon color, and manage your categories."))
                    
                    // 6. Lokale Speicherung / Local Storage
                    cardView(title: NSLocalizedString("manual_local_storage_title", comment: "Local Storage"),
                             content: NSLocalizedString("manual_local_storage_text", comment: "All data is stored locally on your device, ensuring that your information remains available even after restarting the app."))
                    
                    Divider()
                    Divider()
                    
                    // 7. Version Information
                    cardView(title: NSLocalizedString("manual_version_title", comment: "Version"),
                             content: NSLocalizedString("manual_version_title", comment: "Version") + ": " + NSLocalizedString("manual_version_number", comment: "Version number"))
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("manual_navigation_title", comment: "Navigation title for the manual"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        //Text(NSLocalizedString("back", comment: "Back"))
                    }
                }
            }
        }
    }
    
    // Hilfsfunktion, um eine Card-Ansicht für jeden Abschnitt zu liefern
    private func cardView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ManualView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InfoView()
        }
    }
}
