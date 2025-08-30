#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ASC_KEY_ID=... ASC_ISSUER_ID=... ASC_KEY_FILE=/path/to/AuthKey_XXXXXX.p8 \
#   TESTFLIGHT_WHATS_NEW="What's new text" \
#   bash scripts/upload_testflight.sh

pushd ios > /dev/null

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler not found. Install Ruby bundler: gem install bundler" >&2
  exit 1
fi

bundle config set --local path 'vendor/bundle'
bundle install --quiet

echo "Building IPA via fastlane..."
bundle exec fastlane ios build_ipa

echo "Uploading to TestFlight via fastlane..."
bundle exec fastlane ios upload_testflight

popd > /dev/null
echo "Done. Check App Store Connect → TestFlight for processing status."

