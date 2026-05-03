//
//  PTYSession.swift
//  Wisp
//
//  对 POSIX pseudo-terminal 的薄封装。
//  独立于任何 SwiftUI View —— 后期 V1.0 "会话独立于窗口" 的基础设施。
//

import Darwin
import Foundation

final class PTYSession {
    private var masterFD: Int32 = -1
    private var shellTask: Process?
    private var masterHandle: FileHandle?
    private var postLaunchWorkItem: DispatchWorkItem?

    var onData: ((Data) -> Void)?
    var onExit: ((Int32) -> Void)?
    var associatedTodoID: UUID?

    func start(
        command: String,
        arguments: [String],
        cwd: URL? = nil,
        postLaunchCommand: String? = nil
    ) -> Bool {
        var master: Int32 = 0
        var slave: Int32 = 0

        guard openpty(&master, &slave, nil, nil, nil) >= 0 else {
            print("openpty failed: \(String(cString: strerror(errno)))")
            return false
        }

        self.masterFD = master

        let task = Process()
        task.executableURL = URL(fileURLWithPath: command)
        task.arguments = arguments
        task.currentDirectoryURL = cwd

        var env = ProcessInfo.processInfo.environment
        env["TERM"] = "xterm-256color"
        env["CLICOLOR"] = "1"
        if env["LANG"] == nil {
            env["LANG"] = "en_US.UTF-8"
        }
        task.environment = env

        let slaveHandle = FileHandle(fileDescriptor: slave)
        task.standardInput = slaveHandle
        task.standardOutput = slaveHandle
        task.standardError = slaveHandle

        let masterFileHandle = FileHandle(fileDescriptor: master)
        self.masterHandle = masterFileHandle

        masterFileHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else {
                self?.masterHandle?.readabilityHandler = nil
                return
            }
            self?.onData?(data)
        }

        task.terminationHandler = { [weak self] process in
            self?.onExit?(process.terminationStatus)
        }

        do {
            try task.run()
            self.shellTask = task
            slaveHandle.closeFile()

            if let postLaunchCommand {
                let workItem = DispatchWorkItem { [weak self] in
                    self?.writeLine(postLaunchCommand)
                }
                self.postLaunchWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            }

            return true
        } catch {
            print("Failed to start shell: \(error)")
            masterFileHandle.readabilityHandler = nil
            masterFileHandle.closeFile()
            slaveHandle.closeFile()
            return false
        }
    }

    func write(_ data: Data) {
        masterHandle?.write(data)
    }

    func writeLine(_ string: String) {
        write(Data(string.utf8) + Data([0x0A]))
    }

    func resize(columns: Int32, rows: Int32) {
        guard masterFD >= 0 else { return }
        var winSize = winsize()
        winSize.ws_col = UInt16(columns)
        winSize.ws_row = UInt16(rows)
        _ = ioctl(masterFD, TIOCSWINSZ, &winSize)
    }

    func terminate() {
        postLaunchWorkItem?.cancel()
        postLaunchWorkItem = nil

        masterHandle?.readabilityHandler = nil
        masterHandle?.closeFile()
        masterHandle = nil

        shellTask?.terminate()
        shellTask = nil

        if masterFD >= 0 {
            close(masterFD)
            masterFD = -1
        }
    }
}
