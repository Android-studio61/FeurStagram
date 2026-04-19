#!/usr/bin/env python3
"""
Clone patch for resources.arsc: rewrite the package name inside
RES_TABLE_PACKAGE chunks.

When only AndroidManifest.xml is renamed (e.g. to
com.instagram.android.feurstagram) but resources.arsc still declares
com.instagram.android as its package, calls like:

    Resources.getIdentifier(name, type, context.getPackageName())

can fail at runtime because the lookup package and resource table package no
longer match. That can silently break dynamic spacing/layout dimensions.
"""

from __future__ import annotations

import struct
import sys


RES_TABLE_TYPE = 0x0002
RES_TABLE_PACKAGE_TYPE = 0x0200
PACKAGE_NAME_BYTES = 256  # UTF-16LE char16_t[128]

DEFAULT_OLD_PACKAGE = "com.instagram.android"


def decode_package_name(raw: bytes) -> str:
    # Fixed-length UTF-16LE field, null-terminated.
    return raw.decode("utf-16-le", errors="ignore").split("\x00", 1)[0]


def encode_package_name(name: str) -> bytes:
    encoded = name.encode("utf-16-le")
    # Reserve 2 bytes for the null terminator.
    if len(encoded) > PACKAGE_NAME_BYTES - 2:
        raise ValueError(f"Package name too long for resources.arsc field: {name}")
    padded = encoded + b"\x00\x00"
    padded += b"\x00" * (PACKAGE_NAME_BYTES - len(padded))
    return padded


def patch_resources_arsc(path: str, new_package: str, old_package: str) -> int:
    with open(path, "rb") as f:
        blob = bytearray(f.read())

    if len(blob) < 12:
        raise SystemExit("resources.arsc too small")

    table_type, table_hdr_size, total_size = struct.unpack_from("<HHI", blob, 0)
    if table_type != RES_TABLE_TYPE:
        raise SystemExit(f"Not a resources table (type=0x{table_type:04x})")
    if total_size != len(blob):
        # Keep going; some packers don't keep this exact.
        print(f"  Warning: table header size={total_size}, actual={len(blob)}")

    if table_hdr_size < 12:
        raise SystemExit(f"Invalid RES_TABLE header size: {table_hdr_size}")

    patched = 0
    # RES_TABLE_TYPE wraps child chunks (global string pool + package chunks).
    # We must iterate from the end of the table header, not from offset 0,
    # otherwise the first chunk size (whole table) skips everything.
    offset = table_hdr_size
    table_end = min(total_size, len(blob))
    while offset + 8 <= table_end:
        chunk_type, chunk_header_size, chunk_size = struct.unpack_from("<HHI", blob, offset)
        if chunk_size == 0 or offset + chunk_size > table_end:
            break

        if chunk_type == RES_TABLE_PACKAGE_TYPE:
            # ResTable_package starts with:
            # ResChunk_header (8), id (4), name[128] (256 bytes)
            if chunk_header_size < 12 + PACKAGE_NAME_BYTES:
                raise SystemExit("Invalid RES_TABLE_PACKAGE header size")

            name_off = offset + 12
            current = decode_package_name(bytes(blob[name_off:name_off + PACKAGE_NAME_BYTES]))
            if current == old_package:
                blob[name_off:name_off + PACKAGE_NAME_BYTES] = encode_package_name(new_package)
                patched += 1

        offset += chunk_size

    if patched == 0:
        print(
            "  Warning: no RES_TABLE_PACKAGE chunk matched "
            f"{old_package!r}; resources may already be patched"
        )
    else:
        with open(path, "wb") as f:
            f.write(blob)

    return patched


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: apply_clone_resources_patch.py <resources.arsc> <new_package> [old_package]")
        return 1

    path = sys.argv[1]
    new_package = sys.argv[2]
    old_package = sys.argv[3] if len(sys.argv) >= 4 else DEFAULT_OLD_PACKAGE

    patched = patch_resources_arsc(path, new_package, old_package)
    print(f"  Patched {patched} package chunk(s) in resources.arsc -> {new_package}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
