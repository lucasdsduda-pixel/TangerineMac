import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @ObservedObject var model: ConverterModel
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 18) {
            header
            dropZone
            settings
            fileList
            footer
        }
        .padding(24)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 3) {
                Text("TangerineMac").font(.largeTitle.bold())
                Text("Conversões rápidas, diretamente no seu Mac")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { model.chooseFiles() } label: {
                Label("Adicionar imagens", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var dropZone: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 34))
                .foregroundStyle(.tint)
            Text("Arraste imagens para cá").font(.title3.weight(.semibold))
            Text("Ou use “Adicionar imagens” para escolher arquivos")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(isTargeted ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4])).foregroundStyle(isTargeted ? Color.accentColor : Color.secondary.opacity(0.4)))
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            let providers = providers
            var urls: [URL] = []
            let group = DispatchGroup()
            for provider in providers {
                group.enter()
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url { urls.append(url) }
                    group.leave()
                }
            }
            group.notify(queue: .main) { model.add(urls: urls) }
            return true
        }
    }

    private var settings: some View {
        GroupBox("Configurações de saída") {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Formato")
                    Picker("Formato", selection: $model.outputFormat) {
                        ForEach(OutputFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 130)
                    Spacer()
                    Text("Qualidade JPEG")
                    Slider(value: $model.jpegQuality, in: 0.2...1, step: 0.05)
                        .frame(width: 130)
                        .disabled(model.outputFormat != .jpeg)
                    Text("\(Int(model.jpegQuality * 100))%")
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
                HStack {
                    Text("Dimensão máxima")
                    Slider(value: $model.maxDimension, in: 0...4096, step: 128)
                        .frame(maxWidth: 220)
                    Text(model.maxDimension == 0 ? "Original" : "\(Int(model.maxDimension)) px")
                        .frame(width: 90, alignment: .trailing)
                    Spacer()
                    Button("Pasta de saída…") { model.chooseOutputFolder() }
                    Text(model.outputFolder.lastPathComponent)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 150, alignment: .leading)
                }
            }
            .padding(.top, 6)
        }
    }

    private var fileList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Fila de conversão").font(.headline)
                Text("\(model.files.count)")
                    .font(.caption.monospacedDigit())
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
                Spacer()
                Button("Limpar") { model.clear() }
                    .disabled(model.files.isEmpty || model.isConverting)
            }
            if model.files.isEmpty {
                ContentUnavailableView("Nenhuma imagem adicionada", systemImage: "photo.on.rectangle.angled", description: Text("Adicione uma ou mais imagens para preparar a conversão."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(model.files) { item in
                        HStack(spacing: 10) {
                            Image(nsImage: NSImage(contentsOf: item.url) ?? NSImage(size: NSSize(width: 32, height: 32)))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.url.lastPathComponent).lineLimit(1)
                                Text(item.status).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 3)
                    }
                }
                .listStyle(.inset)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Text(model.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button { model.convertAll() } label: {
                if model.isConverting {
                    ProgressView().controlSize(.small)
                    Text("Convertendo…")
                } else {
                    Label("Converter arquivos", systemImage: "arrow.right.circle.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.files.isEmpty || model.isConverting)
        }
    }
}
