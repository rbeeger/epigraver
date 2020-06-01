#!/usr/bin/env sh

xcodebuild \
  -project ../Epigraver.xcodeproj \
  -target Epigraver \
  -configuration Release

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
  --add-file "Epigraver.saver" "../build/Release/Epigraver.saver" 200 190 \
  --hide-extension "Epigraver.saver" \
  "Epigraver.dmg" \
  "dmg_source/"

rmdir dmg_source

if [ -z "${EPIGRAVER_DMG_SIGNER}" ]
then
  echo "DMG signer missing"
  exit 1
fi

echo "Signing DMG"

codesign -s "${EPIGRAVER_DMG_SIGNER}" Epigraver.dmg --options runtime

if [ -z "${EPIGRAVER_AC_USER}" ]
then
  echo "Notarization user missing"
  exit 1
fi

if [ -z "${EPIGRAVER_AC_PASSWD_NAME}" ]
then
  echo "Notarization password missing"
  exit 1
fi

[ -f notarizationUpload.plist ] && rm notarizationUpload.plist
[ -f notarizationInfo.plist ] && rm notarizationInfo.plist


echo "Uploading for notarization"

xcrun altool \
  --notarize-app \
  --primary-bundle-id "net.beeger.scrn.Epigraver" \
  --username "${EPIGRAVER_AC_USER}" \
  --password "@keychain:${EPIGRAVER_AC_PASSWD_NAME}" \
  --file Epigraver.dmg \
  --output-format xml > notarizationUpload.plist

echo "Upload finished"

while true
do
  xcrun altool \
    --notarization-info `/usr/libexec/PlistBuddy -c "Print :notarization-upload:RequestUUID" notarizationUpload.plist` \
    --username "${EPIGRAVER_AC_USER}" \
    --password "@keychain:${EPIGRAVER_AC_PASSWD_NAME}" \
    --output-format xml > notarizationInfo.plist

  if [ `/usr/libexec/PlistBuddy -c "Print :notarization-info:Status" notarizationInfo.plist` != "in progress" ]
  then
    break
  fi

  echo "Waiting for notarization"
  sleep 60
done

if [ `/usr/libexec/PlistBuddy -c "Print :notarization-info:Status" notarizationInfo.plist` != "success" ]
then
  echo "Notarization failed"
  exit 1
fi

xcrun stapler staple "Epigraver.dmg"
