//
//  Order.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//
import Foundation

struct Order: Identifiable, Codable, Equatable {
    let id: Int64
    let itemName: String
    var status: OrderStatus
    let date: Date
}
