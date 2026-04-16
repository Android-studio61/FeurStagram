#!/usr/bin/env python3
"""
Inject a Home-tab long-press hook into the main tab-bar binder.

Target: the LX/4jG.<init>(Landroid/view/View;)V constructor (Instagram's
main tab-bar binder). It resolves the tab_bar ViewGroup and stashes it in
field A0F. We append a call to FeurSettings.installHomeTabWatcher right
after that iput so we can find the feed_tab child (the Home button at the
bottom-left) and attach our long-press listener to it.

The target class is located under smali_classes*/X/4jG.smali; Instagram
shuffles which DEX a class lands in between versions, so we search every
smali_classes* directory for the marker rather than hard-coding a path.
"""

import os
import sys

# Signature of the iput we key off of: unique to the tab-bar binder
# constructor. Matching on this anchors the injection regardless of minor
# whitespace or surrounding-code churn.
TAB_BAR_IPUT = "iput-object v0, p0, LX/4jG;->A0F:Landroid/view/ViewGroup;"
# Class declaration we verify when picking the target. On case-insensitive
# filesystems (macOS default) "4jG.smali" and "4jg.smali" resolve to the same
# path, so we content-check to make sure we grabbed the real LX/4jG; class
# and not the lowercase sibling.
CLASS_DECL = ".class public final LX/4jG;"
INJECTION = (
    "\n\n    # Feurstagram: watch the tab_bar for feed_tab to attach long-press\n"
    "    invoke-static {v0}, "
    "Lcom/feurstagram/FeurSettings;->installHomeTabWatcher(Landroid/view/ViewGroup;)V"
)
MARKER = "Lcom/feurstagram/FeurSettings;->installHomeTabWatcher"


def find_target(workdir: str):
    """Locate LX/4jG.smali across smali/ and smali_classes*/ trees."""
    for entry in sorted(os.listdir(workdir)):
        if entry != "smali" and not entry.startswith("smali_classes"):
            continue
        candidate = os.path.join(workdir, entry, "X", "4jG.smali")
        if not os.path.isfile(candidate):
            continue
        # Verify class identity — guards against case-insensitive FS confusion
        # between "4jG.smali" and "4jg.smali" on macOS.
        with open(candidate, "r") as f:
            if CLASS_DECL in f.read():
                return candidate
    return None


def patch(workdir: str) -> bool:
    target = find_target(workdir)
    if target is None:
        print("  Error: LX/4jG.smali not found in any smali_classes* tree")
        return False

    with open(target, "r") as f:
        content = f.read()

    if MARKER in content:
        print(f"  Already patched: {target}")
        return True

    if TAB_BAR_IPUT not in content:
        print(f"  Error: tab_bar iput marker not found in {target}")
        return False

    content = content.replace(TAB_BAR_IPUT, TAB_BAR_IPUT + INJECTION, 1)

    with open(target, "w") as f:
        f.write(content)

    print(f"  Patched: {target}")
    return True


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: apply_longpress_patch.py <decompiled_apk_dir>")
        sys.exit(1)

    if not patch(sys.argv[1]):
        sys.exit(1)
