//
//  Panel.swift
//  Wisp
//

import Foundation

protocol Panel: AnyObject, Identifiable {
    var id: UUID { get }
    var title: String { get set }
}
