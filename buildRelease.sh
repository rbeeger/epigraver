#!/usr/bin/env zsh

xcodebuild \
  -project Epigraver.xcodeproj \
  -target Epigraver \
  -configuration Release

[[ -f Epigraver.dmg ]] && rm Epigraver.dmg

mkdir dmg_source

cp assets/dmgbackground*.png .

create-dmg \
  --no-internet-enable \
  --volname "Epigraver" \
  --icon-size 64 \
  --background "dmgbackground.png" \
  --window-pos 300 200 \
  --window-size 400 352 \
  --text-size 14 \
  --add-file "Epigraver.saver" "build/Release/Epigraver.saver" 200 190 \
  "Epigraver.dmg" \
  "dmg_source/"

rmdir dmg_source
rm dmgbackground*.png

if [[ -z "${EPIGRAVER_DMG_SIGNER}" ]]
then
  echo "DMG signer missing"
  exit 1
fi

echo "Signing DMG"

codesign -s "${EPIGRAVER_DMG_SIGNER}" Epigraver.dmg --options runtime

if [[ -z "${EPIGRAVER_NOTARIZATION_KEYCHAIN_PROFILE}" ]]
then
  echo "Notarization keychain profile missing"
  exit 1
fi

xcrun notarytool submit Epigraver.dmg \
                   --keychain-profile "${EPIGRAVER_NOTARIZATION_KEYCHAIN_PROFILE}" \
                   --wait

xcrun stapler staple "Epigraver.dmg"
