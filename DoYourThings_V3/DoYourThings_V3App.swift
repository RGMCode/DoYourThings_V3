//
//  DoYourThings_V3App.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

@main
struct DoYourThingsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = DoYourThingViewModel(context: PersistenceController.shared.viewContext)
    @StateObject private var deepLinkManager = DeepLinkManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, deepLinkTaskId: .constant(nil))
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    // Erwartetes URL-Schema: myapp://task/<taskID>
                    guard url.scheme == "myapp", url.host == "task" else { return }
                    let taskId = url.lastPathComponent
                    deepLinkManager.pendingTaskId = taskId
                }
        }
    }
}
