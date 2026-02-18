//
//  OrderDetailViewModel.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import SwiftUI
import Combine

class OrderDetailViewModel: ObservableObject {
    
    @Published var order: Order
    @Published var isUpdating: Bool = false
    
    private let repository: OrderRepositoryProtocol
    private var timer: AnyCancellable?
    
    init(order: Order, repository: OrderRepositoryProtocol = MockOrderRepository()) {
        self.order = order
        self.repository = repository
    }
    
    @MainActor
    func startTrackingSimulation() {
        guard order.status != .delivered else { return }
        
        timer = Timer
            .publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.advanceStatus()
                }
            }
    }
    
    func stopTracking() {
        timer?.cancel()
    }
    
    @MainActor
    internal func advanceStatus() async {
        let nextStatus: OrderStatus?
        switch order.status {
            case .pending: nextStatus = .inTransit
            case .inTransit: nextStatus = .delivered
            case .delivered: nextStatus = nil
            case .unknown: nextStatus = nil
        }
        
        guard let newStatus = nextStatus else {
            stopTracking()
            return
        }
        
        isUpdating = true
        
        defer { isUpdating = false }
        
        do {
            let updated = try await repository.updateOrder(id: order.id, status: newStatus)
            self.order = updated
        } catch {
            // Handle or log error
            print("Failed to update order: \(error)")
        }
    }
}
