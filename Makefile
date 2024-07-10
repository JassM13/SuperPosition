MODULES = jailed
TARGET := iphone:clang:latest:17.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SuperPosition
DISPLAY_NAME = SuperPosition
BUNDLE_ID = com.malak.superposition

$(TWEAK_NAME)_FILES = Tweak.xm SpoofLocation.m JoystickView.m PopupViewController.m

$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
