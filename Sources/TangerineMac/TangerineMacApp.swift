import SwiftUI
import AppKit

@main
struct LOrangerieApp: App {
    @StateObject private var model = ConverterModel()
    var body: some Scene {
        WindowGroup("l’orangerie") { MainView(model: model) }
        MenuBarExtra("l’orangerie", systemImage: "leaf.fill") {
            VStack(alignment: .leading, spacing: 12) {
                Label("l’orangerie", systemImage: "leaf.fill").font(.headline)
                Text("Processamento local. Nenhum arquivo é enviado.").font(.caption).foregroundStyle(.secondary)
                Button("Adicionar imagens…") { model.chooseFiles() }
                Button("Abrir janela principal") { NSApp.activate(ignoringOtherApps: true) }
                Divider()
                Text(model.files.isEmpty ? "Nenhum arquivo na fila" : "\(model.files.count) arquivo(s) na fila").font(.caption).foregroundStyle(.secondary)
                Button("Limpar fila") { model.clear() }.disabled(model.files.isEmpty || model.isConverting)
            }.padding(16).frame(width: 280)
        }.menuBarExtraStyle(.window)
    }
}
