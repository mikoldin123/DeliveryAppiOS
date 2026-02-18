//
//  OrderListView.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//


import SwiftUI

struct OrderListView: View {
    @StateObject private var viewModel = OrderListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: Filter Segment
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    Text("All").tag(OrderStatus?.none)
                    ForEach(OrderStatus.allCases) { status in
                        Text(status.rawValue).tag(Optional(status))
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: viewModel.selectedFilter) {
                    viewModel.filterOrders()
                }
                .accessibilityLabel("Order filter")
                .accessibilityHint("Filters the list by all, pending, in transit, or delivered")
                
                // MARK: Content Switcher
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear { Task { await viewModel.loadOrders() } }
                case .loading:
                        
                    ProgressView("Tracking packages...")
                        .frame(maxHeight: .infinity)
                        
                case .empty:
                    VStack {
                        
                        Image(systemName: "box.truck")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No orders found")
                            .font(.headline)
                    }
                    .frame(maxHeight: .infinity)
                        
                case .error(let message):
                        
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text(message)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry", action: viewModel.retry)
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                        
                case .loaded(let orders):
                    List(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                    .refreshable {
                        await viewModel.loadOrders()
                    }
                }
            }
            .navigationTitle("My Deliveries")
        }
    }
}

#Preview {
    OrderListView()
}
