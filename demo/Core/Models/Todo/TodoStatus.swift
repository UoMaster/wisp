//
//  TodoStatus.swift
//  Wisp
//

import Foundation

enum TodoStatus: String, Codable, Equatable {
    case pending
    case running
    case completed
    case failed
}
