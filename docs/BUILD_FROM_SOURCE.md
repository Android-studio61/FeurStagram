# Build from source

This guide explains how to build FeurStagram yourself.

Building from source is the recommended option if you want to inspect the patches and avoid trusting a prebuilt APK.

## Requirements

- Linux, macOS, or WSL;
- `apktool`;
- Java / JDK;
- Python 3;
- Android SDK build-tools with `zipalign` and `apksigner`;
- a local Android signing keystore;
- the official Instagram APK version supported by the current release.

## Install dependencies

### Linux

```sh
sudo apt install apktool android-sdk-build-tools openjdk-17-jdk python3
```

### macOS

```sh
brew install apktool android-commandlinetools openjdk python3
sdkmanager "build-tools;34.0.0"
```

## Steps

1. Clone the repository.

```sh
git clone https://github.com/jean-voila/FeurStagram.git
cd FeurStagram
```

2. Download a supported Instagram APK.

Use a trusted APK source and check the release notes for the Instagram version currently supported by FeurStagram. The existing quick start recommends the arm64-v8a APK from APKMirror.

3. Create a local signing keystore if you do not already have one.

```sh
keytool -genkey -v -keystore feurstagram.keystore -alias feurstagram \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=Feurstagram, OU=Feurstagram, O=Feurstagram, L=Unknown, ST=Unknown, C=XX"
```

Do not commit your keystore.

4. Run the patch script.

```sh
FEURSTAGRAM_KEYSTORE=./feurstagram.keystore \
FEURSTAGRAM_KEYSTORE_PASS=android \
FEURSTAGRAM_KEY_ALIAS=feurstagram \
FEURSTAGRAM_KEY_PASS=android \
./patch.sh instagram.apk
```

To build a clone APK that installs alongside the official Instagram app:

```sh
FEURSTAGRAM_KEYSTORE=./feurstagram.keystore \
FEURSTAGRAM_KEYSTORE_PASS=android \
FEURSTAGRAM_KEY_ALIAS=feurstagram \
FEURSTAGRAM_KEY_PASS=android \
./patch.sh --clone instagram.apk
```

You can also specify a clone package ID:

```sh
FEURSTAGRAM_KEYSTORE=./feurstagram.keystore \
FEURSTAGRAM_KEYSTORE_PASS=android \
FEURSTAGRAM_KEY_ALIAS=feurstagram \
FEURSTAGRAM_KEY_PASS=android \
./patch.sh --clone com.instagram.android.feurstagram instagram.apk
```

5. Install the patched APK.

```sh
adb install -r artifacts/feurstagram_patched_<instagram_apk_name>.apk
```

For clone builds, install the clone artifact:

```sh
adb install -r artifacts/feurstagram_clone_patched_<instagram_apk_name>.apk
```

6. Clean generated build artifacts when you are done.

```sh
./cleanup.sh
```

## Notes

- Only use APKs from trusted sources.
- Make sure the Instagram APK version matches the supported version.
- Keep the same keystore if you want to reinstall without losing app data.
- If the build fails, check open issues or create a bug report.
