# Disabling the permanent lock for testing (dev only)

The **permanent lock** (a.k.a. *hardcore mode*) is meant to be irreversible from
inside the app — once enabled, the settings dialog only lets you make blocks
*more* restrictive, never relax them. That's great for users and annoying when
you're the developer testing the lock flow over and over.

This doc explains how to flip it back off **over ADB, without uninstalling /
reinstalling**, plus a script that does it for you:
[`disable_permanent_lock.sh`](../disable_permanent_lock.sh).

## What the lock actually is

It's a single boolean in SharedPreferences (see
[`patches/FeurConfig.smali`](../patches/FeurConfig.smali)):

```
file:  /data/data/<package>/shared_prefs/feurstagram_prefs.xml
entry: <boolean name="hardcore_mode" value="true" />
```

`isHardcoreMode()` reads it; `enableHardcoreMode()` sets it to `true`. There is
no method that sets it back to `false`, which is why we reset it from outside.

## The catch: app private data is sandboxed

That XML lives in Instagram's private data directory. ADB can only touch it if
**one** of these is true:

| Access path | Requirement | Effect |
|-------------|-------------|--------|
| `adb shell su` | device is **rooted** | edit the pref directly |
| `adb shell run-as <pkg>` | the build is **debuggable** | edit the pref directly |
| `adb shell pm clear <pkg>` | always works | wipes **all** app data, **logs you out of Instagram** |

A normal release build is **neither rooted nor debuggable**, so the only pure
ADB option is `pm clear` — too heavy for repeated testing because you'd have to
log back into Instagram every cycle.

## Recommended setup: one debuggable test build

Build your **test** APK once with the new `--debuggable` flag, install it, and
from then on every reset is surgical and instant — no reinstall, your Instagram
session and other toggles stay intact:

```bash
# one time
./patch.sh --debuggable instagram.apk
adb install -r feurstagram.apk
```

`--debuggable` injects `android:debuggable="true"` into the manifest. It is
**dev-only**: never publish a debuggable APK, and it is intentionally rejected
when combined with `--clone`.

Then, each test cycle:

```bash
# 1. In the app: enable the permanent lock, test whatever you need.
# 2. Reset it:
./disable_permanent_lock.sh
```

The script will:
1. auto-detect the package (`com.instagram.android.feurstagram` or
   `com.instagram.android`),
2. pick the best access method (root > run-as > `pm clear` fallback),
3. `am force-stop` the app (so the in-memory prefs cache can't overwrite the
   file),
4. flip `hardcore_mode` back to `false`,
5. relaunch the app.

## Script usage

```bash
./disable_permanent_lock.sh [--package PKG] [--nuke] [--pm-clear] [--no-launch] [--serial SERIAL]
```

| Flag | Meaning |
|------|---------|
| `--package PKG` | Target a specific package (otherwise auto-detected). |
| `--nuke` | Delete `feurstagram_prefs.xml` entirely — resets **every** FeurStagram toggle to default. Keeps your Instagram login. |
| `--pm-clear` | Last resort on a non-root / non-debuggable build: `pm clear` the app. **Wipes your Instagram login too.** |
| `--no-launch` | Don't relaunch the app afterwards. |
| `--serial SERIAL` | Target a specific device (`adb -s SERIAL`). |

Default behaviour (no flags) only flips `hardcore_mode` to `false` and leaves
your block settings and login alone.

## If you're on a non-debuggable build right now

You'll see:

```
No surgical access: device is not rooted and this build is not debuggable.
```

Two options:

- **Best:** rebuild once with `./patch.sh --debuggable …`, reinstall, then use
  the script normally forever after.
- **Right now, no rebuild:** `./disable_permanent_lock.sh --pm-clear` — clears
  the lock immediately but logs you out of Instagram.

## Why force-stop matters

Android caches SharedPreferences in memory and flushes them on `apply()`/exit.
If you edit the XML while the process is alive, the cached copy wins and your
edit is lost (or clobbered on the next write). The script force-stops the app
first so the next launch reads the freshly edited file from disk.
