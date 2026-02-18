//
//  OrderDetailViewModelTests.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import XCTest
import Combine
@testable import DeliveryApp

@MainActor
final class OrderDetailViewModelTests: XCTestCase {
    
    var sut: OrderDetailViewModel!
    var mockRepo: MockOrderRepository!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockOrderRepository()
    }
    
    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }
    
    func testInitialState() {
        let order = Order(
            id: 1,
            itemName: "Test Item",
            status: .pending,
            date: Date()
        )
        
        sut = OrderDetailViewModel(
            order: order,
            repository: mockRepo
        )
        
        XCTAssertEqual(sut.order.status, .pending)
        XCTAssertFalse(sut.isUpdating)
    }
    
    func testStatusAdvancementFromPendingToInTransit() async {
        let order = Order(
            id: 1,
            itemName: "Test",
            status: .pending,
            date: Date()
        )
        
        sut = OrderDetailViewModel(order: order, repository: mockRepo)

        await sut.advanceStatus()

        XCTAssertEqual(sut.order.status, .inTransit)
    }
    
    func testStatusAdvancementToDeliveredStopsSimulation() async {
        let order = Order(
            id: 1,
            itemName: "Test",
            status: .inTransit,
            date: Date()
        )
        
        sut = OrderDetailViewModel(order: order, repository: mockRepo)
        
        await sut.advanceStatus()
        
        XCTAssertEqual(sut.order.status, .delivered)
        
        await sut.advanceStatus()
        
        XCTAssertEqual(sut.order.status, .delivered)
    }
    
    func testStatusTryToUpdateDelivered() async {
        let order = Order(
            id: 1,
            itemName: "Test",
            status: .delivered,
            date: Date()
        )
        
        sut = OrderDetailViewModel(order: order, repository: mockRepo)
        
        XCTAssertEqual(sut.order.status, .delivered)
        
        await sut.advanceStatus()
        
        XCTAssertEqual(sut.order.status, .delivered)
    }
}
