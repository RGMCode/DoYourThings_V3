//
//  Category.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import SwiftUI

struct Category: Identifiable, Hashable {
    var id = UUID()
    var originalName: String
    var colorHex: String

    var tasks: [DoYourThing] = []

    var name: String {
        NSLocalizedString(originalName, comment: "")
    }
    
    var color: Color {
        get {
            Color(hex: colorHex) ?? .black
        }
        set {
            colorHex = UIColor(newValue).toHex() ?? "#000000"
        }
    }
}
