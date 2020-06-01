#!/usr/bin/env sh

[ -f Epigraver.dmg ] && rm Epigraver.dmg
mkdir dmg_source

create-dmg \
  --no-internet-enable \
  --volname "Epigraver" \
  --icon-size 64 \
  --background "dmgbackground.png" \
  --window-pos 300 200 \
  --window-size 400 352 \
  --text-size 14 \
  --add-file "Epigraver.saver" "Epigraver.saver" 200 190 \
  --hide-extension "Epigraver.saver" \
  "Epigraver.dmg" \
  "dmg_source/"

rmdir dmg_source
