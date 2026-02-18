//
//  OrderListViewModel.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import SwiftUI
import Combine

class OrderListViewModel: ObservableObject {
    
    @Published var state: ViewState<[Order]> = .idle
    @Published var selectedFilter: OrderStatus? = nil // nil = All
    
    private let repository: OrderRepositoryProtocol
    private var allOrders: [Order] = []
    
    init(repository: OrderRepositoryProtocol = MockOrderRepository()) {
        self.repository = repository
    }
    
    @MainActor
    func loadOrders() async {
        state = .loading
        
        do {
            let orders = try await repository.fetchOrders()
            
            /*
             Filter out unsupported statuses to limit app break
             */
            self.allOrders = orders
                .filter { $0.status != .unknown }
            
            filterOrders()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    @MainActor
    func filterOrders() {
        guard !allOrders.isEmpty else {
            state = .empty
            return
        }
        
        let filtered = selectedFilter == nil 
            ? allOrders 
            : allOrders.filter { $0.status == selectedFilter }
            
        state = filtered.isEmpty ? .empty : .loaded(filtered)
    }

    @MainActor
    func retry() {
        Task { await loadOrders() }
    }
}
