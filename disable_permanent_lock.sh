#!/bin/bash

# FeurStagram — disable the permanent (hardcore) lock via ADB.
#
# The permanent lock is a single SharedPreferences boolean:
#   file: <data>/shared_prefs/feurstagram_prefs.xml   key: hardcore_mode=true
# (see patches/FeurConfig.smali). There is no in-app "off" switch by design,
# so for repeated testing we flip it back to false from outside the app.
#
# Touching an app's private prefs over ADB needs ONE of:
#   * root   (adb shell su), or
#   * a debuggable build (adb shell run-as) — build it with:
#         ./patch.sh --debuggable instagram.apk
# A stock/release build is neither, so the only fallback is `pm clear`, which
# also wipes your Instagram login. See docs/DISABLE_PERMANENT_LOCK.md.
#
# Usage: ./disable_permanent_lock.sh [--package PKG] [--nuke] [--pm-clear]
#                                    [--no-launch] [--serial SERIAL]

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

PREFS_FILE="shared_prefs/feurstagram_prefs.xml"
PKG=""
NUKE=0          # delete the whole feurstagram_prefs.xml (reset ALL Feur settings)
PM_CLEAR=0      # allow `pm clear` fallback on non-root, non-debuggable builds
LAUNCH=1
SERIAL=""

usage() {
    echo "Usage: $0 [--package PKG] [--nuke] [--pm-clear] [--no-launch] [--serial SERIAL]"
    echo ""
    echo "  --package PKG   Target package (auto-detected if omitted)."
    echo "  --nuke          Delete feurstagram_prefs.xml entirely (resets every"
    echo "                  FeurStagram toggle to default, keeps IG login)."
    echo "                  Default behaviour only flips hardcore_mode -> false."
    echo "  --pm-clear      Last resort for non-root / non-debuggable builds:"
    echo "                  'pm clear' the app. WIPES your Instagram login too."
    echo "  --no-launch     Do not relaunch the app afterwards."
    echo "  --serial SERIAL Target a specific device (adb -s)."
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)   usage; exit 0 ;;
        --package)   PKG="$2"; shift ;;
        --nuke)      NUKE=1 ;;
        --pm-clear)  PM_CLEAR=1 ;;
        --no-launch) LAUNCH=0 ;;
        --serial)    SERIAL="$2"; shift ;;
        *) echo -e "${RED}Unknown argument: $1${NC}"; usage; exit 1 ;;
    esac
    shift
done

ADB=(adb)
[ -n "$SERIAL" ] && ADB=(adb -s "$SERIAL")

# --- device present? -------------------------------------------------------
if ! command -v adb >/dev/null 2>&1; then
    echo -e "${RED}Error: adb not found in PATH.${NC}"; exit 1
fi
DEV_COUNT=$("${ADB[@]}" devices | grep -cw "device" || true)
if [ "$DEV_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: no device connected (check 'adb devices').${NC}"; exit 1
fi

# --- resolve package -------------------------------------------------------
pkg_installed() { "${ADB[@]}" shell pm list packages 2>/dev/null | grep -qx "package:$1"; }

if [ -z "$PKG" ]; then
    for cand in com.instagram.android.feurstagram com.instagram.android; do
        if pkg_installed "$cand"; then PKG="$cand"; break; fi
    done
fi
if [ -z "$PKG" ]; then
    echo -e "${RED}Error: could not auto-detect the FeurStagram package.${NC}"
    echo "  Pass it explicitly: $0 --package <pkg>"
    exit 1
fi
if ! pkg_installed "$PKG"; then
    echo -e "${RED}Error: package not installed: $PKG${NC}"; exit 1
fi
echo -e "${YELLOW}Target package:${NC} $PKG"

# --- detect access method --------------------------------------------------
HAS_ROOT=0; HAS_RUNAS=0
if "${ADB[@]}" shell su -c id 2>/dev/null | grep -q "uid=0"; then HAS_ROOT=1; fi
if [ "$HAS_ROOT" -eq 0 ]; then
    if "${ADB[@]}" shell run-as "$PKG" id 2>/dev/null | grep -q "uid="; then HAS_RUNAS=1; fi
fi

# data dir (for root path)
data_dir() { "${ADB[@]}" shell pm path "$PKG" >/dev/null 2>&1; echo "/data/data/$PKG"; }

# --- helpers ---------------------------------------------------------------
force_stop() {
    echo -e "${YELLOW}Stopping app...${NC}"
    "${ADB[@]}" shell am force-stop "$PKG"
}

relaunch() {
    [ "$LAUNCH" -eq 1 ] || return 0
    echo -e "${YELLOW}Relaunching...${NC}"
    local act
    act=$("${ADB[@]}" shell cmd package resolve-activity --brief \
        -c android.intent.category.LAUNCHER "$PKG" 2>/dev/null | tail -n1 | tr -d '\r')
    if [[ "$act" == */* ]]; then
        "${ADB[@]}" shell am start -n "$act" >/dev/null 2>&1 \
            && { echo -e "${GREEN}✓ Launched $act${NC}"; return 0; }
    fi
    "${ADB[@]}" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 \
        && echo -e "${GREEN}✓ Launched (monkey)${NC}"
}

# Run a shell snippet inside the app sandbox, via su or run-as.
in_sandbox() {  # $1 = sh snippet
    if [ "$HAS_ROOT" -eq 1 ]; then
        "${ADB[@]}" shell su -c "cd /data/data/$PKG && $1"
    else
        "${ADB[@]}" shell run-as "$PKG" sh -c "$1"
    fi
}

surgical_reset() {
    local present
    present=$(in_sandbox "[ -f $PREFS_FILE ] && echo yes || echo no")
    present=$(echo "$present" | tr -d '\r')
    if [ "$present" != "yes" ]; then
        echo -e "${GREEN}✓ No $PREFS_FILE yet — lock is not set. Nothing to do.${NC}"
        return 0
    fi

    if [ "$NUKE" -eq 1 ]; then
        in_sandbox "rm -f $PREFS_FILE"
        echo -e "${GREEN}✓ Deleted $PREFS_FILE (all FeurStagram settings reset).${NC}"
        return 0
    fi

    if ! in_sandbox "grep -q 'name=\"hardcore_mode\" value=\"true\"' $PREFS_FILE"; then
        echo -e "${GREEN}✓ hardcore_mode is already off. Nothing to do.${NC}"
        return 0
    fi

    in_sandbox "sed -i 's/name=\"hardcore_mode\" value=\"true\"/name=\"hardcore_mode\" value=\"false\"/' $PREFS_FILE"

    if in_sandbox "grep -q 'name=\"hardcore_mode\" value=\"false\"' $PREFS_FILE"; then
        echo -e "${GREEN}✓ Permanent lock disabled (hardcore_mode -> false).${NC}"
    else
        echo -e "${RED}Error: edit did not take. Try --nuke.${NC}"; exit 1
    fi
}

# --- main ------------------------------------------------------------------
if [ "$HAS_ROOT" -eq 1 ]; then
    echo -e "${YELLOW}Access:${NC} root (su)"
    force_stop; surgical_reset; relaunch
elif [ "$HAS_RUNAS" -eq 1 ]; then
    echo -e "${YELLOW}Access:${NC} run-as (debuggable build)"
    force_stop; surgical_reset; relaunch
else
    echo -e "${RED}No surgical access:${NC} device is not rooted and this build is not debuggable."
    if [ "$PM_CLEAR" -eq 1 ]; then
        echo -e "${YELLOW}Falling back to 'pm clear' (this WIPES your Instagram login)...${NC}"
        force_stop
        "${ADB[@]}" shell pm clear "$PKG" >/dev/null
        echo -e "${GREEN}✓ App data cleared — permanent lock gone, but you must log into Instagram again.${NC}"
        relaunch
    else
        echo "  To reset only the lock (no reinstall, keeps your IG session), build a"
        echo "  debuggable test APK once:"
        echo "      ./patch.sh --debuggable instagram.apk"
        echo "      ./patch.sh ... && adb install -r feurstagram.apk   # one time"
        echo "  then re-run this script."
        echo ""
        echo "  Or, to reset right now on this non-debuggable build (logs you out of IG):"
        echo "      $0 --pm-clear"
        exit 2
    fi
fi
