//
//  TerminalPanel.swift
//  Wisp
//

import SwiftUI
import GhosttyTerminal

struct TerminalPanel: View {
    @State private var context = TerminalViewState(
        terminalConfiguration: TerminalConfiguration {
            $0.withFontSize(14)
            $0.withCursorStyle(.block)
            $0.withCursorStyleBlink(true)
        }
    )

    @State private var shellProcess: Process?
    @State private var inputPipe: Pipe?
    @State private var stdoutPipe: Pipe?
    @State private var stderrPipe: Pipe?

    var body: some View {
        TerminalSurfaceView(context: context)
            .background(Color.black)
            .onAppear { startShell() }
            .onDisappear { teardownShell() }
    }

    private func teardownShell() {
        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        stderrPipe?.fileHandleForReading.readabilityHandler = nil
        shellProcess?.terminate()
    }

    private func startShell() {
        let newSession = InMemoryTerminalSession(
            write: { data in
                self.inputPipe?.fileHandleForWriting.write(data)
            },
            resize: { viewport in
                // TODO: 通知 shell 进程窗口大小变化
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

        // 读取用户实际使用的 shell（zsh / bash / fish）
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"

        let task = Process()
        task.executableURL = URL(fileURLWithPath: shell)
        // -i = 强制交互模式（显示 prompt、加载 .zshrc / .bashrc）
        // -l = login shell（加载 .zprofile / .bash_profile）
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
            // 发一个换行触发 prompt 显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                inPipe.fileHandleForWriting.write(Data("\n".utf8))
            }
        } catch {
            print("Failed to start shell: \(error)")
        }
    }
}
