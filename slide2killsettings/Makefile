include theos/makefiles/common.mk

BUNDLE_NAME = Slide2KillSettings
Slide2KillSettings_FILES = Slide2KillSettings.mm
Slide2KillSettings_INSTALL_PATH = /Library/PreferenceBundles
Slide2KillSettings_FRAMEWORKS = UIKit
Slide2KillSettings_PRIVATE_FRAMEWORKS = Preferences UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Slide2KillSettings.plist$(ECHO_END)
