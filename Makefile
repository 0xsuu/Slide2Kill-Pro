include theos/makefiles/common.mk

TWEAK_NAME = Slide2Kill
Slide2Kill_FILES = Tweak.xm
Slide2Kill_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += slide2killsettings
include $(THEOS_MAKE_PATH)/aggregate.mk
