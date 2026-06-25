#!/usr/bin/env bash
#
# Feurstagram build pipeline.
#
#   ./build.sh <instagram.apk> [--clone] [--install]
#
# Builds the patch bundle (.mpp) from the Gradle project, then applies it to the
# given Instagram APK with the local Morphe CLI, producing ./feurstagram.apk.
#   --clone     install side-by-side as a separate package (com.instagram.android.feurstagram)
#   --install   install the result on the connected ADB device
#
# Signing: set FEURSTAGRAM_KEYSTORE_PASS (and optionally FEURSTAGRAM_KEY_PASS)
# to sign with feurstagram.keystore. Otherwise the CLI generates a throwaway
# keystore (fine for testing, not for release).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$(ls -t "$DIR"/tools/morphe-cli-*.jar 2>/dev/null | head -1)"
OUT="$DIR/feurstagram.apk"

# Morphe's Android Gradle plugin targets JDK 17-21; pin to 21 so the build does
# not pick up a newer system JDK.
if [ -d "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home" ]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home"
fi

# The patcher dependency lives on GitHub Packages. Credentials come from
# ~/.gradle/gradle.properties (gpr.user/gpr.key); otherwise fall back to the
# GitHub CLI token if it is available (needs the read:packages scope).
if [ -z "${GITHUB_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
    export GITHUB_TOKEN="$(gh auth token 2>/dev/null || true)"
    export GITHUB_ACTOR="${GITHUB_ACTOR:-$(gh api user --jq .login 2>/dev/null || true)}"
fi

# The extension is an Android library, so the Android SDK must be locatable.
if [ -z "${ANDROID_HOME:-}" ]; then
    for sdk in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "${ANDROID_SDK_ROOT:-}"; do
        if [ -n "$sdk" ] && { [ -d "$sdk/platform-tools" ] || [ -d "$sdk/build-tools" ]; }; then
            export ANDROID_HOME="$sdk"
            break
        fi
    done
fi

APK=""
CLONE=0
INSTALL=0
for arg in "$@"; do
    case "$arg" in
        --clone) CLONE=1 ;;
        --install) INSTALL=1 ;;
        *) APK="$arg" ;;
    esac
done

if [ -z "$APK" ] || [ ! -f "$APK" ]; then
    echo "usage: ./build.sh <instagram.apk> [--clone] [--install]" >&2
    exit 1
fi
if [ -z "$CLI" ]; then
    echo "Error: Morphe CLI not found under tools/ (morphe-cli-*.jar)." >&2
    exit 1
fi

echo "==> [1/3] Building patch bundle (.mpp)"
"$DIR/gradlew" -p "$DIR" :patches:build
MPP="$(ls -t "$DIR"/patches/build/libs/patches-*[0-9].mpp 2>/dev/null | grep -v -- '-sources\|-javadoc' | head -1)"
if [ -z "$MPP" ]; then
    echo "Error: no .mpp produced under patches/build/libs/" >&2
    exit 1
fi
echo "    bundle: $MPP"

echo "==> [2/3] Applying to $(basename "$APK")"
ARGS=(-jar "$CLI" patch -p "$MPP" -f --purge -o "$OUT")
[ "$CLONE" -eq 1 ] && ARGS+=(-e "Clone")
if [ -n "${FEURSTAGRAM_KEYSTORE_PASS:-}" ]; then
    ARGS+=(--keystore "$DIR/feurstagram.keystore"
           --keystore-entry-alias "feurstagram"
           --keystore-password "$FEURSTAGRAM_KEYSTORE_PASS"
           --keystore-entry-password "${FEURSTAGRAM_KEY_PASS:-$FEURSTAGRAM_KEYSTORE_PASS}")
fi
ARGS+=("$APK")
java "${ARGS[@]}"

echo "==> [3/3] Output: $OUT"
if [ "$INSTALL" -eq 1 ]; then
    echo "    installing on device..."
    adb install -r "$OUT"
fi
