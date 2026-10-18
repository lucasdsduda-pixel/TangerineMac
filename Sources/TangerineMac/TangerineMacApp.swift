import SwiftUI

@main
struct TangerineMacApp: App {
    @StateObject private var model = ConverterModel()

    var body: some Scene {
        WindowGroup {
            MainView(model: model)
                .frame(minWidth: 720, minHeight: 560)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("TangerineMac", systemImage: "arrow.triangle.2.circlepath") {
            MenuBarPanel(model: model)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarPanel: View {
    @ObservedObject var model: ConverterModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("TangerineMac", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)
            Text("Conversão de imagens, localmente no Mac.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Abrir janela principal") {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            Button("Adicionar imagens…") {
                model.chooseFiles()
            }
            .keyboardShortcut("o", modifiers: [.command])
            Divider()
            Text(model.files.isEmpty ? "Nenhum arquivo na fila" : "\(model.files.count) arquivo(s) na fila")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Limpar fila") { model.clear() }
                .disabled(model.files.isEmpty || model.isConverting)
        }
        .padding(16)
        .frame(width: 280)
    }
}
