#!/bin/bash
set -euo pipefail
# Build-time helper for the l’orangerie fork.
# Run on macOS or CI from the repository root.
# It imports the complete native Open Tangerine app and removes the updater.
rm -rf /tmp/open-tangerine
 git clone --depth 1 https://github.com/sintaxerrorpvtltd/Open-Tangerine.git /tmp/open-tangerine
rm -rf NativeApp
cp -R /tmp/open-tangerine/NativeApp ./NativeApp
find NativeApp -type f \( -name '*.swift' -o -name '*.md' \) -print0 | xargs -0 sed -i '' \
  -e 's/Open Tangerine/l’orangerie/g' \
  -e 's/Open-Tangerine/l-orangerie/g' \
  -e 's/OpenTangerine/lOrangerie/g' \
  -e 's/TangerineMac/lOrangerie/g' \
  -e 's/Tangerine Mac/l’Orangerie/g'
rm -f NativeApp/Sources/App/UpdateChecker.swift
rm -rf Sources/lOrangerie Sources/TangerineMac Package.swift scripts/build-app.sh
printf '%s\n' 'l’orangerie native source imported. Build NativeApp with Xcode/Swift on macOS.' > README.md
