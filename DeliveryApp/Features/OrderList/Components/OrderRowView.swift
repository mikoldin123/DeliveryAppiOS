//
//  OrderRowView.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import SwiftUI

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        HStack {
            Image(systemName: order.status.iconName)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(order.itemName)
                    .font(.headline)
                Text(order.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            StatusBadge(status: order.status)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(order.itemName)")
        .accessibilityValue("Status: \(order.status.rawValue.replacingOccurrences(of: "_", with: " ")). Ordered on \(order.date.formatted(date: .long, time: .omitted))")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to view tracking details.")
    }
}
