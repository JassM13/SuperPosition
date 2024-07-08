MODULES = jailed
TARGET := iphone:clang:latest:17.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SuperPosition
DISPLAY_NAME = SuperPosition
BUNDLE_ID = com.malak.superposition

SuperPosition_FILES = Tweak.xm SpoofLocation.xm JoystickView.xm

include $(THEOS_MAKE_PATH)/tweak.mk
