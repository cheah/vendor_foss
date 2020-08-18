#!/bin/bash
set -e

repo="http://localhost/repo/"

addCopy() {
	addition=""
	if [ "$2"  == org.mozilla.fennec_fdroid ];then
		unzip bin/$1 lib/*
		addition="
LOCAL_PREBUILT_JNI_LIBS := \\
$(unzip -lv bin/$1 |grep -v Stored |sed -nE 's;.*(lib/arm64-v8a/.*);\t\1 \\;p')

		"
	fi
cat >> Android.mk <<EOF
include \$(CLEAR_VARS)
LOCAL_MODULE := $2
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := bin/$1
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_OVERRIDES_PACKAGES := $3
$addition
include \$(BUILD_PREBUILT)

EOF
echo -e "\t$2 \\" >> apps.mk
}

rm -Rf apps.mk lib
cat > Android.mk <<EOF
LOCAL_PATH := \$(my-dir)

EOF
echo -e 'PRODUCT_PACKAGES += \\' > apps.mk

mkdir -p bin
#downloadFromFdroid packageName overrides
downloadFromFdroid() {
	mkdir -p tmp
	if [ ! -f tmp/index.xml ];then
		#TODO: Check security keys
		wget --connect-timeout=10 $repo/index.jar -O tmp/index.jar
		unzip -p tmp/index.jar index.xml > tmp/index.xml
	fi
	marketvercode="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]' -v ./marketvercode tmp/index.xml || true)"
	apk="$(xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[versioncode="'"$marketvercode"'"]' -v ./apkname tmp/index.xml || xmlstarlet sel -t -m '//application[id="'"$1"'"]/package[1]' -v ./apkname tmp/index.xml)"
    if [ ! -f bin/$apk ];then
        while ! wget --connect-timeout=10 $repo/$apk -O bin/$apk;do sleep 1;done
    fi
	addCopy $apk $1 "$2"
}


#phh's Superuser
downloadFromFdroid me.phh.superuser
#YouTube viewer
downloadFromFdroid org.schabi.newpipe
#Ciphered SMS
downloadFromFdroid org.smssecure.smssecure "messaging"
#Navigation
downloadFromFdroid net.osmand.plus
#Web browser
downloadFromFdroid org.mozilla.fennec_fdroid "Browser2 QuickSearchBox"
#Calendar
downloadFromFdroid ws.xsoh.etar Calendar
#Public transportation
downloadFromFdroid de.grobox.liberario
#Pdf viewer
downloadFromFdroid com.artifex.mupdf.viewer.app
#Play Store download
downloadFromFdroid com.aurora.store
#Mail client
downloadFromFdroid com.fsck.k9 "Email"
#Ciphered Instant Messaging
#downloadFromFdroid im.vector.alpha
#Calendar/Contacts sync
downloadFromFdroid com.etesync.syncadapter
#Nextcloud client
downloadFromFdroid com.nextcloud.client
# Todo lists
downloadFromFdroid org.tasks

downloadFromFdroid org.mariotaku.twidere
downloadFromFdroid com.pitchedapps.frost
downloadFromFdroid com.keylesspalace.tusky

#Fake assistant that research on duckduckgo
downloadFromFdroid co.pxhouse.sas

downloadFromFdroid com.simplemobiletools.gallery.pro "Photos Gallery Gallery2"

downloadFromFdroid com.aurora.adroid
echo >> apps.mk

rm -Rf tmp
