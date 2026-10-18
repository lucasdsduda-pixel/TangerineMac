import AppKit
import Foundation
import ImageIO
import PDFKit
import UniformTypeIdentifiers

struct ConversionItem: Identifiable {
    let id = UUID()
    let url: URL
    var status: String = "Pronto"
}

enum OutputFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case jpeg = "JPEG"
    case tiff = "TIFF"
    case pdf = "PDF"

    var id: String { rawValue }
    var fileExtension: String {
        switch self {
        case .png: "png"
        case .jpeg: "jpg"
        case .tiff: "tiff"
        case .pdf: "pdf"
        }
    }
}

@MainActor
final class ConverterModel: ObservableObject {
    @Published var files: [ConversionItem] = []
    @Published var outputFormat: OutputFormat = .png
    @Published var outputFolder: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? FileManager.default.homeDirectoryForCurrentUser
    @Published var jpegQuality: Double = 0.9
    @Published var maxDimension: Double = 0
    @Published var isConverting = false
    @Published var message = "Adicione imagens para começar."

    func add(urls: [URL]) {
        let known = Set(files.map(\.url.standardizedFileURL))
        let accepted = urls.filter { url in
            guard !known.contains(url.standardizedFileURL) else { return false }
            return NSImage(contentsOf: url) != nil
        }
        files.append(contentsOf: accepted.map { ConversionItem(url: $0) })
        message = accepted.isEmpty ? "Nenhuma imagem nova foi adicionada." : "\(accepted.count) imagem(ns) adicionada(s)."
    }

    func chooseFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK { add(urls: panel.urls) }
    }

    func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        if panel.runModal() == .OK, let url = panel.url { outputFolder = url }
    }

    func clear() {
        guard !isConverting else { return }
        files.removeAll()
        message = "Fila limpa."
    }

    func convertAll() {
        guard !files.isEmpty, !isConverting else { return }
        isConverting = true
        message = "Convertendo…"
        let batch = files
        Task.detached(priority: .userInitiated) { [weak self] in
            var results: [(UUID, String)] = []
            for item in batch {
                do {
                    let destination = try Self.convert(
                        item.url,
                        format: await self?.outputFormat ?? .png,
                        folder: await self?.outputFolder ?? FileManager.default.temporaryDirectory,
                        quality: await self?.jpegQuality ?? 0.9,
                        maxDimension: await self?.maxDimension ?? 0
                    )
                    results.append((item.id, "Salvo: \(destination.lastPathComponent)"))
                } catch {
                    results.append((item.id, "Erro: \(error.localizedDescription)"))
                }
            }
            await MainActor.run {
                guard let self else { return }
                for (id, status) in results {
                    if let index = self.files.firstIndex(where: { $0.id == id }) {
                        self.files[index].status = status
                    }
                }
                self.isConverting = false
                self.message = "Conversão concluída: \(results.filter { $0.1.hasPrefix("Salvo:") }.count) de \(results.count) arquivo(s)."
            }
        }
    }

    nonisolated private static func convert(_ source: URL, format: OutputFormat, folder: URL, quality: Double, maxDimension: Double) throws -> URL {
        guard let image = NSImage(contentsOf: source) else {
            throw NSError(domain: "TangerineMac", code: 1, userInfo: [NSLocalizedDescriptionKey: "Não foi possível abrir esta imagem."])
        }
        var size = image.size
        if maxDimension > 0, max(size.width, size.height) > maxDimension {
            let ratio = maxDimension / max(size.width, size.height)
            size = NSSize(width: size.width * ratio, height: size.height * ratio)
        }
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: max(1, Int(size.width.rounded())),
            pixelsHigh: max(1, Int(size.height.rounded())),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        guard let bitmap else {
            throw NSError(domain: "TangerineMac", code: 2, userInfo: [NSLocalizedDescriptionKey: "Falha ao preparar os pixels da imagem."])
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()

        let data: Data
        switch format {
        case .png:
            guard let value = bitmap.representation(using: .png, properties: [:]) else { throw conversionError() }
            data = value
        case .jpeg:
            guard let value = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]) else { throw conversionError() }
            data = value
        case .tiff:
            guard let value = bitmap.representation(using: .tiff, properties: [:]) else { throw conversionError() }
            data = value
        case .pdf:
            let page = PDFPage(image: image)
            let document = PDFDocument()
            if let page { document.insert(page, at: 0) }
            guard let value = document.dataRepresentation() else { throw conversionError() }
            data = value
        }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let baseName = source.deletingPathExtension().lastPathComponent
        var destination = folder.appendingPathComponent("\(baseName).\(format.fileExtension)")
        var counter = 2
        while FileManager.default.fileExists(atPath: destination.path) {
            destination = folder.appendingPathComponent("\(baseName)-\(counter).\(format.fileExtension)")
            counter += 1
        }
        try data.write(to: destination, options: .atomic)
        return destination
    }

    nonisolated private static func conversionError() -> NSError {
        NSError(domain: "TangerineMac", code: 3, userInfo: [NSLocalizedDescriptionKey: "O macOS não conseguiu codificar este formato."])
    }
}
