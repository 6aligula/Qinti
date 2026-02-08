#!/usr/bin/env bash
# Compila MoldLine, instala en los dos iPhones del simulador y lanza la app en ambos.
# Uso: ./deploySimulator.sh

set -e
cd "$(dirname "$0")"

SIM1="A6B51CF3-B683-461B-9344-F0AC06044486"   # iPhone 17 Pro
SIM2="F00738C9-4743-4423-B720-E0F00A6D164B"   # iPhone 17 Pro Max
BUNDLE="com.moldline.chat"

echo "▶ Arrancando simuladores y abriendo Simulator..."
xcrun simctl boot "$SIM1" 2>/dev/null || true
xcrun simctl boot "$SIM2" 2>/dev/null || true
open -a Simulator

echo "▶ Compilando MoldLine..."
xcodebuild -scheme MoldLine -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM1" \
  build -quiet 2>&1 | tail -5

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/MoldLine-*/Build/Products/Debug-iphonesimulator/MoldLine.app -maxdepth 0 2>/dev/null | head -1)
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "❌ No se encontró MoldLine.app en DerivedData."
  exit 1
fi

echo "▶ Instalando en ambos iPhones..."
xcrun simctl install "$SIM1" "$APP_PATH"
xcrun simctl install "$SIM2" "$APP_PATH"

echo "▶ Lanzando app en ambos simuladores..."
xcrun simctl launch "$SIM1" "$BUNDLE" &
xcrun simctl launch "$SIM2" "$BUNDLE" &
wait

echo "✅ Listo. App corriendo en los dos iPhones."
