//
//  TerminalPanel.swift
//  Wisp
//

import SwiftUI
import GhosttyTerminal

struct TerminalPanel: View {
    @State private var context = TerminalViewState(
        terminalConfiguration: TerminalConfiguration {
            $0.withFontSize(13)
            $0.withCursorStyle(.block)
            $0.withCursorStyleBlink(true)
        }
    )

    @State private var shellProcess: Process?
    @State private var inputPipe: Pipe?
    @State private var stdoutPipe: Pipe?
    @State private var stderrPipe: Pipe?
    @State private var sessionTitle: String = "shell"

    private static let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
    private static let shellName = URL(fileURLWithPath: shellPath).lastPathComponent

    var body: some View {
        VStack(spacing: 0) {
            header
            terminalSurface
        }
        .background(Theme.bgWindow)
        .onAppear { startShell() }
        .onDisappear { teardownShell() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Space.sm) {
            Circle()
                .fill(Theme.statusSuccess)
                .frame(width: 6, height: 6)

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

    private func teardownShell() {
        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        stderrPipe?.fileHandleForReading.readabilityHandler = nil
        shellProcess?.terminationHandler = nil
        shellProcess?.terminate()
    }

    private func startShell() {
        let newSession = InMemoryTerminalSession(
            write: { [inputPipe = self.inputPipe] data in
                inputPipe?.fileHandleForWriting.write(data)
            },
            resize: { viewport in
                print("Terminal resized: \(viewport)")
            }
        )

        context.configuration = TerminalSurfaceOptions(
            backend: .inMemory(newSession)
        )

        let inPipe = Pipe()
        let outPipe = Pipe()
        let errPipe = Pipe()
        self.inputPipe = inPipe
        self.stdoutPipe = outPipe
        self.stderrPipe = errPipe

        let task = Process()
        task.executableURL = URL(fileURLWithPath: Self.shellPath)
        task.arguments = ["-i", "-l"]
        task.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser

        task.standardInput = inPipe
        task.standardOutput = outPipe
        task.standardError = errPipe

        let onData: (FileHandle) -> Void = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                newSession.receive(data)
            }
        }
        outPipe.fileHandleForReading.readabilityHandler = onData
        errPipe.fileHandleForReading.readabilityHandler = onData

        task.terminationHandler = { process in
            print("Shell exited with code: \(process.terminationStatus)")
        }

        do {
            try task.run()
            self.shellProcess = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                inPipe.fileHandleForWriting.write(Data("\n".utf8))
            }
        } catch {
            print("Failed to start shell: \(error)")
        }
    }
}
