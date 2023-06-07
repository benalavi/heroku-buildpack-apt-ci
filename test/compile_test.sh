#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testCompile() {
  loadFixture "Aptfile-ci"

  compile

  assertCapturedSuccess

  assertCaptured "Fetching .debs for s3cmd"
  assertCaptured "Installing s3cmd_"
  assertCaptured "Fetching .debs for wget"
  assertCaptured "Installing wget_"
}

testStackChange() {
  loadFixture "Aptfile-ci"

  #Set the cached STACK value to a non-existent stack, so it is guaranteed to change.
  mkdir -p "$CACHE_DIR/.apt/"
  echo "cedar-10" > "$CACHE_DIR/.apt/STACK"

  #Load the Aptfile-ci into the cache, to exclusively test the stack changes
  mkdir -p "$CACHE_DIR/apt/cache"
  cp $BUILD_DIR/Aptfile-ci "$CACHE_DIR/apt/cache"

  compile

  assertCapturedSuccess

  assertCaptured "Detected Aptfile-ci or Stack changes, flushing cache"
}

testStackNoChange() {
  loadFixture "Aptfile-ci"

  #Load the Aptfile-ci into the cache, to exclusively test the stack changes
  mkdir -p "$CACHE_DIR/apt/cache"
  cp $BUILD_DIR/Aptfile-ci "$CACHE_DIR/apt/cache"

  compile

  assertCaptured "Reusing cache"
}

testStackCached() {
  loadFixture "Aptfile-ci"

  compile
  assertCapturedSuccess

  assertTrue 'STACK not cached' "[ -e $CACHE_DIR/.apt/STACK ]"
}

loadFixture() {
  cp -a $BUILDPACK_HOME/test/fixtures/$1/. ${BUILD_DIR}
}