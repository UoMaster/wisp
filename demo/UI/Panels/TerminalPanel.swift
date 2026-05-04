//
//  TerminalPanel.swift
//  Wisp
//

import SwiftUI
import AppKit
import GhosttyTerminal
import Darwin

struct TerminalPanel: PanelKind {
    let panelID: UUID
    let project: Project
    let bus: PanelEventBus
    let isFocused: Bool

    var panelTitle: String { project.name }

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
    @State private var currentCLIType: CLIType?
    @State private var didInitialize = false

    private static let shellPath: String = {
        let uid = getuid()
        guard let pw = getpwuid(uid) else { return "/bin/zsh" }
        return String(cString: pw.pointee.pw_shell)
    }()
    private static let shellName = URL(fileURLWithPath: shellPath).lastPathComponent

    var body: some View {
        VStack(spacing: 0) {
            TerminalPanelHeader(
                title: sessionTitle,
                shellName: Self.shellName,
                isRunning: isRunningCommand
            )
            terminalSurface
        }
        .background(Theme.bgWindow)
        .overlay(
            Rectangle()
                .fill(isFocused ? Theme.accent.opacity(0.5) : Color.clear)
                .frame(height: 1)
            , alignment: .top
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(isFocused ? 0 : 0.06))
                .allowsHitTesting(false)
        )
        .onAppear {
            guard !didInitialize else { return }
            didInitialize = true

            bus.send(.focusPanel(projectID: project.id, panelID: panelID))
            startShell()

            if isFocused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    focusTerminalView()
                }
            }
        }
        .onChange(of: isFocused) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusTerminalView()
                }
            }
        }
        .onTapGesture {
            bus.send(.focusPanel(projectID: project.id, panelID: panelID))
        }
        .onReceive(bus.events) { event in
            if case let .panelWillClose(pid, pid2) = event,
               pid == project.id, pid2 == panelID {
                ptySession?.terminate()
                ptySession = nil
                return
            }

            guard case let .runCLI(projectID, todoID, cliType, title, command, promptInput, targetPanelID) = event,
                  projectID == project.id else { return }

            if let target = targetPanelID {
                guard target == panelID else { return }
            } else {
                guard isFocused else { return }
            }

            executeCommand(todoID: todoID, cliType: cliType, title: title, command: command, promptInput: promptInput)
        }
    }

    // MARK: - Terminal Surface

    private var terminalSurface: some View {
        TerminalSurfaceView(context: context)
            .background(Theme.terminalBg)
    }

    // MARK: - Shell lifecycle

    private func startShell() {
        guard ptySession == nil else { return }
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

        pty.onExit = { [project, bus] code in
            newSession.finish(exitCode: UInt32(code), runtimeMilliseconds: 0)
            if let todoID = pty.associatedTodoID, let cliType = self.currentCLIType {
                bus.send(.cliFinished(
                    projectID: project.id,
                    todoID: todoID,
                    exitCode: code,
                    cliType: cliType
                ))
            }
            pty.associatedTodoID = nil
            self.currentCLIType = nil
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
        guard isFocused else { return }
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow,
              let contentView = window.contentView else { return }

        func findVisibleTerminalView(in view: NSView) -> NSView? {
            if view.alphaValue < 0.01 { return nil }
            if view is AppTerminalView { return view }
            for subview in view.subviews {
                if let found = findVisibleTerminalView(in: subview) { return found }
            }
            return nil
        }

        if let terminalView = findVisibleTerminalView(in: contentView) {
            window.makeFirstResponder(terminalView)
        }
    }

    // MARK: - Command Execution

    private func executeCommand(todoID: UUID, cliType: CLIType, title: String, command: String, promptInput: String?) {
        sessionTitle = title
        currentCLIType = cliType
        ptySession?.associatedTodoID = todoID
        isRunningCommand = true

        if let pty = ptySession {
            pty.writeLine(command)
            if let promptInput {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    pty.writeLine(promptInput)
                }
            }
        } else {
            pendingCommand = command
        }
    }
}
