//
//  OrderStatus.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import Foundation

enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "PENDING"
    case inTransit = "IN_TRANSIT"
    case delivered = "DELIVERED"
    case unknown = "UNKNOWN"
    
    var id: String { rawValue }

    /*
     Added here to support or as a fallback new statuses linke "CANCELLED" so app won't break until
     it will be developed
     */
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = OrderStatus(rawValue: rawValue) ?? .pending
    }
    
    var iconName: String {
        switch self {
            case .pending: return "clock"
            case .inTransit: return "shippingbox"
            case .delivered: return "checkmark.seal.fill"
            case .unknown: return "questionmark"
        }
    }
}
