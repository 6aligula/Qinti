#!/usr/bin/env bash
# Solo lanza MoldLine en los dos iPhones (sin compilar). Úsalo cuando ya tengas la app instalada.
# Uso: ./launchBothSims.sh

SIM1="A6B51CF3-B683-461B-9344-F0AC06044486"   # iPhone 17 Pro
SIM2="F00738C9-4743-4423-B720-E0F00A6D164B"   # iPhone 17 Pro Max
BUNDLE="com.moldline.chat"

xcrun simctl launch "$SIM1" "$BUNDLE" &
xcrun simctl launch "$SIM2" "$BUNDLE" &
wait
echo "✅ App lanzada en ambos simuladores."
