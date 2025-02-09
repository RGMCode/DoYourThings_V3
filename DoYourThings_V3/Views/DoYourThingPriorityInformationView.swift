//
//  DoYourThingPriorityInformationView.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 08.02.25.
//

import SwiftUI

struct DoYourThingPriorityInformationView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Priority.allCases, id: \.self) { priority in
                HStack {
                    Image(systemName: "circle.hexagongrid.circle")
                        .foregroundColor(priority.color)
                        .frame(width: 30, height: 30)
                    Text(priority.description)
                }
                .padding(.vertical, 4)
            }
            Spacer()
        }
        .padding()
    }
}

enum Priority: String, CaseIterable {
    case sehrHoch = "Sehr Hoch"
    case hoch = "Hoch"
    case mittel = "Mittel"
    case niedrig = "Niedrig"
    case sehrNiedrig = "Sehr Niedrig"

    var color: Color {
        switch self {
        case .sehrHoch:
            return .red
        case .hoch:
            return .orange
        case .mittel:
            return .yellow
        case .niedrig:
            return .green
        case .sehrNiedrig:
            return .blue
        }
    }

    var description: String {
        switch self {
        case .sehrHoch:
            return NSLocalizedString("veryHighDescription", comment: "Very High Description")
        case .hoch:
            return NSLocalizedString("highDescription", comment: "High Description")
        case .mittel:
            return NSLocalizedString("mediumDescription", comment: "Medium Description")
        case .niedrig:
            return NSLocalizedString("lowDescription", comment: "Low Description")
        case .sehrNiedrig:
            return NSLocalizedString("veryLowDescription", comment: "Very Low Description")
        }
    }
}

#Preview {
    DoYourThingPriorityInformationView()
}
