//
//  ViewState.swift
//  DeliveryApp
//
//  Created by Michael Dean Villanda on 2/18/26.
//

import Foundation

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
}
