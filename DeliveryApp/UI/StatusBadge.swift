//
//  StatusBadge.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import SwiftUI

struct StatusBadge: View {
    let status: OrderStatus
    
    var color: Color {
        switch status {
            case .pending: return .orange
            case .inTransit: return .blue
            case .delivered: return .green
            case .unknown: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
            .accessibilityLabel("Current status")
            .accessibilityValue(status.rawValue.lowercased())
    }
}
