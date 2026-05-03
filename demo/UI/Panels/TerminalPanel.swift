//
//  TerminalPanel.swift
//  Wisp
//

import SwiftUI
import AppKit
import GhosttyTerminal
import Darwin

struct TerminalPanel: View {
    let project: Project

    @State private var context = TerminalViewState(
        terminalConfiguration: TerminalConfiguration {
            $0.withFontSize(13)
            $0.withCursorStyle(.block)
            $0.withCursorStyleBlink(true)
        }
    )

    @State private var ptySession: PTYSession?
    @State private var sessionTitle: String = "shell"
    @State private var isRunningCommand = false
    @State private var pendingCommand: String?

    private static let shellPath: String = {
        let uid = getuid()
        guard let pw = getpwuid(uid) else { return "/bin/zsh" }
        return String(cString: pw.pointee.pw_shell)
    }()
    private static let shellName = URL(fileURLWithPath: shellPath).lastPathComponent

    var body: some View {
        VStack(spacing: 0) {
            header
            terminalSurface
        }
        .background(Theme.bgWindow)
        .onAppear {
            startShell()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusTerminalView()
            }
        }
        .onDisappear {
            ptySession?.terminate()
            ptySession = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .runCLICommand)) { notification in
            handleRunCommand(notification: notification)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            StatusDot(status: isRunningCommand ? .running : .completed, size: 6)

            Text(sessionTitle)
                .font(WispFont.panelTitle)
                .foregroundStyle(Theme.textPrimary)

            Text("·")
                .font(WispFont.bodySmall)
                .foregroundStyle(Theme.textTertiary)

            Text(Self.shellName)
                .font(WispFont.monoSmall)
                .foregroundStyle(Theme.textTertiary)

            Spacer()

            Button(action: {}) {
                Image(systemName: "rectangle.split.2x1")
            }
            .buttonStyle(.wispIcon)

            Button(action: {}) {
                Image(systemName: "rectangle.split.1x2")
            }
            .buttonStyle(.wispIcon)

            Button(action: {}) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.wispIcon)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .overlay(alignment: .bottom) { WispDivider() }
    }

    // MARK: - Terminal Surface

    private var terminalSurface: some View {
        TerminalSurfaceView(context: context)
            .background(Theme.terminalBg)
            .padding(.horizontal, Space.sm)
            .padding(.bottom, Space.sm)
    }

    // MARK: - Shell lifecycle

    private func startShell() {
        let pty = PTYSession()
        self.ptySession = pty

        let newSession = InMemoryTerminalSession(
            write: { [weak pty] data in
                pty?.write(data)
            },
            resize: { [weak pty] viewport in
                pty?.resize(columns: Int32(viewport.columns), rows: Int32(viewport.rows))
            }
        )

        context.configuration = TerminalSurfaceOptions(
            backend: .inMemory(newSession)
        )

        pty.onData = { data in
            newSession.receive(data)
        }

        pty.onExit = { [project] code in
            newSession.finish(exitCode: UInt32(code), runtimeMilliseconds: 0)
            if let todoID = pty.associatedTodoID {
                NotificationCenter.default.post(
                    name: .cliCommandFinished,
                    object: nil,
                    userInfo: [
                        NotificationKey.projectID: project.id,
                        NotificationKey.todoID: todoID,
                        NotificationKey.exitCode: code
                    ]
                )
            }
            DispatchQueue.main.async {
                self.isRunningCommand = false
                self.sessionTitle = project.name
            }
        }

        let started = pty.start(
            command: Self.shellPath,
            arguments: ["-i", "-l"],
            cwd: project.url,
            postLaunchCommand: "cd '\(project.path)'"
        )

        sessionTitle = started ? project.name : "failed"

        if started, let pending = pendingCommand {
            pendingCommand = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ptySession?.writeLine(pending)
            }
        }
    }

    private func focusTerminalView() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow,
              let contentView = window.contentView else { return }

        func findTerminalView(in view: NSView) -> NSView? {
            if view is AppTerminalView { return view }
            for subview in view.subviews {
                if let found = findTerminalView(in: subview) { return found }
            }
            return nil
        }

        if let terminalView = findTerminalView(in: contentView) {
            window.makeFirstResponder(terminalView)
        }
    }

    // MARK: - Command Execution

    private func handleRunCommand(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let projectID = userInfo[NotificationKey.projectID] as? UUID,
              projectID == project.id,
              let command = userInfo[NotificationKey.command] as? String else { return }

        if let title = userInfo[NotificationKey.title] as? String {
            sessionTitle = title
        }
        if let todoID = userInfo[NotificationKey.todoID] as? UUID {
            ptySession?.associatedTodoID = todoID
        }
        isRunningCommand = true

        if let pty = ptySession {
            pty.writeLine(command)

            if let promptInput = userInfo[NotificationKey.promptInput] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    pty.writeLine(promptInput)
                }
            }
        } else {
            pendingCommand = command
        }
    }
}

// MARK: - PTY Session

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
