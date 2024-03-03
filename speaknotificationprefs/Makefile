GO_EASY_ON_ME = 1
SDKVERSION = 11.2
ARCHS = armv7 arm64 arm64e
TARGET =  iphone:clang:latest:8.4

include theos/makefiles/common.mk

BUNDLE_NAME = speaknotificationprefs
speaknotificationprefs_FILES = speaknotificationprefs.mm ./merdokappselect/MerdokAppSelect.m ./merdokappselect/MerdokAppSelectLinkCell.m ./Helpers/MerdokAppList.m
speaknotificationprefs_INSTALL_PATH = /Library/PreferenceBundles
speaknotificationprefs_FRAMEWORKS = UIKit
speaknotificationprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/speaknotificationprefs.plist$(ECHO_END)
