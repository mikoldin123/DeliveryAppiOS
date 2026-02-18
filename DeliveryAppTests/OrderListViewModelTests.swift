//
//  OrderListViewModelTests.swift
//  DeliveryAppTests
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import XCTest
import Combine
@testable import DeliveryApp

@MainActor
final class OrderListViewModelTests: XCTestCase {
    
    var sut: OrderListViewModel!
    var mockRepo: MockOrderRepository!
    
    override func setUp() {
        super.setUp()
        
        mockRepo = MockOrderRepository()
        mockRepo.delaySeconds = 0
        sut = OrderListViewModel(repository: mockRepo)
    }
    
    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }
    
    func testInitialStateIsIdle() {
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testLoadOrdersSuccess() async {
        await sut.loadOrders()
        
        let orders = try? await mockRepo.fetchOrders()
        
        /*
         Orders via api returns 5 items, 1 of them is unsupported
         */
        XCTAssertEqual(orders?.count, 5)
        
        if case let .loaded(orders) = sut.state {
            /*
             Orders displayed on is only 4 items, filtered out
             unknown status
             */
            XCTAssertEqual(orders.count, 4)
        } else {
            XCTFail("State should be .loaded")
        }
    }
    
    func testLoadOrdersFailure() async {
        mockRepo.shouldFail = true
        
        await sut.loadOrders()
        
        if case .error = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should be .error")
        }
    }
    
    func testFilterLogic() async {
        await sut.loadOrders()
        
        sut.selectedFilter = .pending
        sut.filterOrders()
        
        if case let .loaded(orders) = sut.state {
            XCTAssertTrue(orders.allSatisfy { $0.status == .pending })
            XCTAssertEqual(orders.count, 1)
        } else {
            XCTFail("State should be .loaded")
        }
        
        sut.selectedFilter = .delivered
        sut.filterOrders()
        
        if case let .loaded(orders) = sut.state {
            XCTAssertEqual(orders.first?.status, .delivered)
        }
    }
    
    func testEmptyState() async {
        class EmptyRepo: OrderRepositoryProtocol {
            func fetchOrders() async throws -> [Order] { return [] }
            func updateOrder(id: Int64, status: OrderStatus) async throws -> Order { throw NSError() }
        }
        sut = OrderListViewModel(repository: EmptyRepo())
        
        await sut.loadOrders()
        
        XCTAssertEqual(sut.state, .empty)
    }
}
