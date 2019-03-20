gem install jazzy

jazzy \
--author "Virgil Security" \
--author_url "https://virgilsecurity.com/" \
--xcodebuild-arguments -scheme,"VirgilSDKPythia macOS" \
--module "VirgilSDKPythia" \
--output "${OUTPUT}" \
--hide-documentation-coverage \
--theme apple
