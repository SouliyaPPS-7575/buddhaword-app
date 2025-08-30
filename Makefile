SHELL := /bin/bash

KEY_ID ?= 32V7XKG237
ISSUER_ID ?= 5be73893-b4a5-4205-b93f-2448c38285b2
IPA ?= build/ios/ipa/Buddhaword.ipa

.PHONY: verify-auth upload-ipa

# Verify App Store Connect API key authentication
verify-auth:
	@./scripts/appstore_upload.sh verify $(KEY_ID) $(ISSUER_ID) || exit 1

# Upload the IPA to App Store Connect
upload-ipa:
	@./scripts/appstore_upload.sh upload $(KEY_ID) $(ISSUER_ID) $(IPA) || exit 1

.PHONY: ios-build ios-upload

ios-build:
	cd ios && bundle config set --local path 'vendor/bundle' && bundle install --quiet && bundle exec fastlane ios build_ipa

ios-upload:
	bash scripts/upload_testflight.sh
