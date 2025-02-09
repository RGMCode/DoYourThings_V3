//
//  DeepLinkManager.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI
import Combine

final class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    @Published var pendingTaskId: String? = nil
    private init() {}
}
