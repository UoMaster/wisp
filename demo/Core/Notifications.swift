//
//  Notifications.swift
//  Wisp
//

import Foundation

extension Notification.Name {
    static let runCLICommand = Notification.Name("com.wisp.runCLICommand")
    static let cliCommandFinished = Notification.Name("com.wisp.cliCommandFinished")
    static let presentTodoEditor = Notification.Name("com.wisp.presentTodoEditor")
}

enum NotificationKey {
    static let projectID = "projectID"
    static let command = "command"
    static let title = "title"
    static let todoID = "todoID"
    static let promptInput = "promptInput"
    static let exitCode = "exitCode"
    static let cliType = "cliType"
    static let editorMode = "editorMode"
}
