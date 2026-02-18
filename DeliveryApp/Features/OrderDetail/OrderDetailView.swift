//
//  OrderDetailView.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import SwiftUI

struct OrderDetailView: View {
    @StateObject var viewModel: OrderDetailViewModel
    
    init(order: Order) {
        _viewModel = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: Header
            Image(systemName: "cube.box.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.accentColor)
                .padding(.top)
            
            Text(viewModel.order.itemName)
                .font(.title)
                .bold()
            
            Divider()
            
            // MARK: Live status
            VStack(spacing: 10) {
                Text("Current Status")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                StatusBadge(status: viewModel.order.status)
                    .scaleEffect(1.5)
                
                if viewModel.isUpdating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            Spacer()
            
            Text("Simulation: Status updates automatically every 3 seconds.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startTrackingSimulation()
        }
        .onDisappear {
            viewModel.stopTracking()
        }
    }
}

#Preview {
    OrderDetailView(order: .init(id: 1, itemName: "sample", status: .pending, date: Date()))
}
