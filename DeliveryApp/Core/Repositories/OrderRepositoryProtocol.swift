//
//  OrderRepositoryProtocol.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import Foundation

// MARK: - Protocol
protocol OrderRepositoryProtocol {
    func fetchOrders() async throws -> [Order]
    func updateOrder(id: Int64, status: OrderStatus) async throws -> Order
}

// MARK: - Mock Implementation
final class MockOrderRepository: OrderRepositoryProtocol {
    
    var shouldFail: Bool = false
    var delaySeconds: UInt64 = 2 // Simulate network latency (2 secs delay)
    
    private var localOrders: [Order] = [
        Order(
            id: 1,
            itemName: "Wireless Headphones",
            status: .pending,
            date: Date()
        ),
        Order(
            id: 2,
            itemName: "Running Shoes",
            status: .inTransit,
            date: Date()
                .addingTimeInterval(-86400)
        ),
        Order(
            id: 3,
            itemName: "Coffee Grinder",
            status: .delivered,
            date: Date()
                .addingTimeInterval(-172800)
        ),
        Order(
            id: 4,
            itemName: "Coffee Maker",
            status: .inTransit,
            date: Date()
                .addingTimeInterval(-162222)
        ),
        Order(
            id: 5,
            itemName: "Tesla",
            status: .unknown,
            date: Date()
                .addingTimeInterval(-192222)
        )
    ]
    
    func fetchOrders() async throws -> [Order] {
        // Simulate network fetch delay to show loading
        try? await Task.sleep(nanoseconds: delaySeconds * 1_000_000_000)
        
        if shouldFail {
            throw NSError(domain: "NetworkError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch orders."])
        }
        
        return localOrders
    }
    
    func updateOrder(id: Int64, status: OrderStatus) async throws -> Order {
        // Simulate processing time (.5 secs)
        try? await Task.sleep(nanoseconds: 500_000_000)

        if let index = localOrders.firstIndex(where: { $0.id == id }) {
            var updatedOrder = localOrders[index]
            updatedOrder.status = status
            localOrders[index] = updatedOrder
            return updatedOrder
        } else {
            throw NSError(domain: "NotFoundError", code: 404, userInfo: nil)
        }
    }
}
