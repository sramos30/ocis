fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios register_new_devices
```
fastlane ios register_new_devices
```
Register new devices to Apple portal
### ios build_ipa_ad_hoc
```
fastlane ios build_ipa_ad_hoc
```
Ad-Hoc Distribution IPA generation
### ios screenshots
```
fastlane ios screenshots
```
Generate the screenshots for the AppStore
### ios prepare_metadata
```
fastlane ios prepare_metadata
```
Create Metadata Release Notes, Screenshots and push to git
### ios release_on_appstore
```
fastlane ios release_on_appstore
```
Create Release Notes, Screenshots, Build, Upload of regular iOS App and EMM App
### ios owncloud_regular_build
```
fastlane ios owncloud_regular_build
```

### ios owncloud_emm_build
```
fastlane ios owncloud_emm_build
```

### ios owncloud_online_build
```
fastlane ios owncloud_online_build
```

### ios owncloud_branding_adhoc_build
```
fastlane ios owncloud_branding_adhoc_build
```

### ios owncloud_branding_appstore_build
```
fastlane ios owncloud_branding_appstore_build
```

### ios owncloud_ownbrander_build
```
fastlane ios owncloud_ownbrander_build
```

### ios owncloud_enterprise_build
```
fastlane ios owncloud_enterprise_build
```

### ios generate_appicon
```
fastlane ios generate_appicon
```

### ios build_ipa_in_house
```
fastlane ios build_ipa_in_house
```
In-House Enterprise IPA generation

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
