brew update;
brew outdated carthage || brew upgrade carthage;
carthage build --use-xcframeworks --no-skip-current;

# TODO: Should be replaced by carthage archive, when it supports xcframeworks
FRAMEWORKS_PATH=Carthage/Build
find ${FRAMEWORKS_PATH} ! -name 'VirgilSDKPythia.xcframework' -delete
zip -r VirgilSDKPythia.xcframework.zip ${FRAMEWORKS_PATH}
