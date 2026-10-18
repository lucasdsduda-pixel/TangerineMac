import AppKit
import Foundation
import PDFKit

struct ConversionItem: Identifiable {
    let id = UUID()
    let url: URL
    var status: String = "Pronto"
}

enum OutputFormat: String, CaseIterable, Identifiable {
    case png = "PNG", jpeg = "JPEG", tiff = "TIFF", pdf = "PDF"
    var id: String { rawValue }
    var fileExtension: String { self == .jpeg ? "jpg" : rawValue.lowercased() }
}

@MainActor
final class ConverterModel: ObservableObject {
    @Published var files: [ConversionItem] = []
    @Published var outputFormat: OutputFormat = .png
    @Published var outputFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? FileManager.default.homeDirectoryForCurrentUser
    @Published var jpegQuality = 0.9
    @Published var maxDimension = 0.0
    @Published var isConverting = false
    @Published var message = "Adicione imagens para começar."

    func add(urls: [URL]) {
        let known = Set(files.map { $0.url.standardizedFileURL })
        let accepted = urls.filter { !known.contains($0.standardizedFileURL) && NSImage(contentsOf: $0) != nil }
        files.append(contentsOf: accepted.map { ConversionItem(url: $0) })
        message = accepted.isEmpty ? "Nenhuma imagem nova foi adicionada." : "\(accepted.count) imagem(ns) adicionada(s)."
    }
    func chooseFiles() { let p = NSOpenPanel(); p.allowsMultipleSelection = true; p.canChooseDirectories = false; p.allowedContentTypes = [.image]; if p.runModal() == .OK { add(urls: p.urls) } }
    func chooseOutputFolder() { let p = NSOpenPanel(); p.canChooseFiles = false; p.canChooseDirectories = true; p.canCreateDirectories = true; if p.runModal() == .OK, let u = p.url { outputFolder = u } }
    func clear() { guard !isConverting else { return }; files.removeAll(); message = "Fila limpa." }
    func convertAll() {
        guard !files.isEmpty, !isConverting else { return }
        isConverting = true; message = "Convertendo…"
        let batch = files, format = outputFormat, folder = outputFolder, quality = jpegQuality, dimension = maxDimension
        Task.detached(priority: .userInitiated) {
            var results: [(UUID, String)] = []
            for item in batch {
                do { let d = try Self.convert(item.url, format: format, folder: folder, quality: quality, maxDimension: dimension); results.append((item.id, "Salvo: \(d.lastPathComponent)")) }
                catch { results.append((item.id, "Erro: \(error.localizedDescription)")) }
            }
            await MainActor.run {
                for (id, status) in results { if let i = self.files.firstIndex(where: { $0.id == id }) { self.files[i].status = status } }
                self.isConverting = false
                self.message = "Conversão concluída: \(results.filter { $0.1.hasPrefix("Salvo:") }.count) de \(results.count) arquivo(s)."
            }
        }
    }

    nonisolated private static func convert(_ source: URL, format: OutputFormat, folder: URL, quality: Double, maxDimension: Double) throws -> URL {
        guard let image = NSImage(contentsOf: source) else { throw NSError(domain: "lOrangerie", code: 1, userInfo: [NSLocalizedDescriptionKey: "Não foi possível abrir esta imagem."]) }
        let original = image.size
        let scale = maxDimension > 0 && max(original.width, original.height) > maxDimension ? maxDimension / max(original.width, original.height) : 1
        let size = NSSize(width: original.width * scale, height: original.height * scale)
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: max(1, Int(size.width.rounded())), pixelsHigh: max(1, Int(size.height.rounded())), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        guard let bitmap else { throw conversionError() }
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap); NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1); NSGraphicsContext.restoreGraphicsState()
        let data: Data
        switch format {
        case .png: guard let d = bitmap.representation(using: .png, properties: [:]) else { throw conversionError() }; data = d
        case .jpeg: guard let d = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]) else { throw conversionError() }; data = d
        case .tiff: guard let d = bitmap.representation(using: .tiff, properties: [:]) else { throw conversionError() }; data = d
        case .pdf: let doc = PDFDocument(); if let page = PDFPage(image: image) { doc.insert(page, at: 0) }; guard let d = doc.dataRepresentation() else { throw conversionError() }; data = d
        }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let base = source.deletingPathExtension().lastPathComponent; var destination = folder.appendingPathComponent("\(base).\(format.fileExtension)"); var n = 2
        while FileManager.default.fileExists(atPath: destination.path) { destination = folder.appendingPathComponent("\(base)-\(n).\(format.fileExtension)"); n += 1 }
        try data.write(to: destination, options: .atomic); return destination
    }
    nonisolated private static func conversionError() -> NSError { NSError(domain: "lOrangerie", code: 2, userInfo: [NSLocalizedDescriptionKey: "Falha ao codificar o formato escolhido."]) }
}
