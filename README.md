# TangerineMac

An independent macOS utility project for Apple Silicon, built with Swift and SwiftUI. The initial milestone focuses on native image conversion and a menu-bar entry point, with room to grow into floating tools and additional workflows.

## Status

Early prototype. This repository is a starting point, not yet a feature-complete replacement for Tangerine.

### Initial scope
- Native SwiftUI interface
- Drag-and-drop image input
- Convert images to PNG, JPEG, TIFF, and PDF
- Optional output resizing and JPEG quality control
- Choose an output folder
- Menu-bar extra for quick access

### Planned work
- More image editing tools and batch workflows
- Additional file formats where macOS frameworks support them
- Floating/panel workflows and configurable shortcuts
- Better progress, errors, and accessibility
- Automated tests, signing, and distribution packaging

## Requirements
- macOS 13 or later
- Xcode 15 or later (or a compatible Swift toolchain)
- Apple Silicon recommended; Swift code is not intentionally limited to one CPU architecture

## Build

Open `Package.swift` in Xcode, or run:

```sh
swift build
swift run TangerineMac
```

To build a local `.app` bundle, run `sh scripts/build-app.sh` from Terminal. The script uses the installed Swift toolchain and creates an unsigned app bundle under `dist/`.

## Privacy

The prototype processes files locally using Apple frameworks. It does not upload file contents.

## License

MIT. See `LICENSE`.