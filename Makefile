GO_EASY_ON_ME = 1
SDKVERSION = 13.2
ARCHS = armv7 arm64 arm64e
TARGET =  iphone:clang:latest:8.4

include theos/makefiles/common.mk

TWEAK_NAME = SpeakNotification
SpeakNotification_FILES = Tweak.xm SpeakHelper.m
SpeakNotification_FRAMEWORKS = UIKit, AVFoundation, CoreTelephony
SpeakNotification_PRIVATE_FRAMEWORKS = VoiceServices, PersistentConnection, MediaRemote 

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += speaknotificationprefs
include $(THEOS_MAKE_PATH)/aggregate.mk


after-install::
	install.exec "killall -9 SpringBoard"
