#!/usr/bin/env python3
"""
Clone runtime patches.

Inject a package-name fallback into RedexResourcesCompat.getIdentifier so
resource lookups keep working even if some call sites still pass
"com.instagram.android" while others pass the cloned package name.
"""

from __future__ import annotations

import os
import sys


TARGET_REL = os.path.join("com", "facebook", "resources", "compat", "RedexResourcesCompat.smali")
MARKER = "# Feurstagram: clone package fallback"

PATCH_OLD = """    invoke-virtual {p0, p1, p2, p3}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v4

    if-nez v4, :cond_7

    const/4 v4, 0x0
"""

PATCH_NEW = """    invoke-virtual {p0, p1, p2, p3}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v4

    if-nez v4, :cond_7

    # Feurstagram: clone package fallback (old <-> clone package)
    if-eqz p3, :cond_clone_pkg_done

    const-string v0, "com.instagram.android"
    invoke-virtual {p3, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :cond_clone_try_old

    const-string v0, "com.instagram.android.feurstagram"
    invoke-virtual {p0, p1, p2, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v4
    if-nez v4, :cond_7
    goto :cond_clone_pkg_done

    :cond_clone_try_old
    const-string v0, "com.instagram.android.feurstagram"
    invoke-virtual {p3, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :cond_clone_pkg_done

    const-string v0, "com.instagram.android"
    invoke-virtual {p0, p1, p2, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v4
    if-nez v4, :cond_7

    :cond_clone_pkg_done
    const/4 v4, 0x0
"""


def find_target(workdir: str) -> str | None:
    for entry in sorted(os.listdir(workdir)):
        if entry != "smali" and not entry.startswith("smali_classes"):
            continue
        candidate = os.path.join(workdir, entry, TARGET_REL)
        if os.path.isfile(candidate):
            return candidate
    return None


def patch_file(path: str) -> bool:
    with open(path, "r") as f:
        content = f.read()

    if MARKER in content:
        print(f"  Already patched: {path}")
        return True

    if PATCH_OLD not in content:
        print("  Error: expected getIdentifier block not found in RedexResourcesCompat")
        return False

    content = content.replace(PATCH_OLD, PATCH_NEW, 1)

    with open(path, "w") as f:
        f.write(content)

    print(f"  Patched clone runtime fallback: {path}")
    return True


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: apply_clone_runtime_patch.py <decompiled_apk_dir>")
        return 1

    workdir = sys.argv[1]
    target = find_target(workdir)
    if target is None:
        print("  Error: RedexResourcesCompat.smali not found")
        return 1

    return 0 if patch_file(target) else 1


if __name__ == "__main__":
    sys.exit(main())
