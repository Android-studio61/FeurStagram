#!/usr/bin/env python3
"""
Clone patch: change the APK's application ID so a patched FeurStagram build
can be installed alongside a stock Instagram.

A full apktool decode of Instagram's resources does not round-trip cleanly
(aapt2 rejects apktool's encoded layout refs), so we keep the fast
``apktool d --no-res`` flow and edit the binary AndroidManifest.xml in
place.

Approach:
  1. Parse the AXML: outer header, string pool, XML element chunks.
  2. Walk the XML chunks and, for every attribute we care about
     (``package``, ``authorities``, ``taskAffinity``, ``permission``,
     plus ``name`` on permission tags), record its location and the
     desired new value.
  3. Add each new value to the string pool as a *new* entry (dedup'd on
     value), then rewrite the targeted attribute's string reference to
     point at the new index. Other references to the original pool entry
     (notably ``android:name`` on <provider>/<activity>, which happens to
     share the same literal with an authority because Instagram names
     some providers after their class) remain intact.
  4. Re-emit the string pool with the extra entries appended; every
     other chunk stays byte-identical.

Renaming rules:
  * ``com.instagram.android`` and ``com.instagram.android.*`` -> new package
  * For authorities / taskAffinity only, ``com.instagram.*`` is also
    retargeted (Instagram declares providers like
    ``com.instagram.fileprovider`` outside the formal package namespace,
    and those would clash with a stock install otherwise).

Per-attribute whitelist:
  * Permission renames target only this app's own permissions
    (prefix ``com.instagram.android``). External permissions
    (``com.instagram.direct.*``) are declared by other apps and must keep
    their original names so ``<uses-permission>`` still refers to them.
"""

import struct
import sys


CHUNK_XML = 0x0003
CHUNK_STRING_POOL = 0x0001
CHUNK_XML_START_ELEMENT = 0x0102

FLAG_UTF8 = 1 << 8
TYPE_STRING = 0x03

OLD_PACKAGE = "com.instagram.android"
SHORT_PREFIX = "com.instagram."

PERMISSION_TAGS = {"permission", "uses-permission", "uses-permission-sdk-23"}

# Layout of a StartElement chunk's attribute entry, for clarity:
ATTR_FMT = "<IIIHBBI"
ATTR_SIZE = struct.calcsize(ATTR_FMT)  # 20 bytes


def decode_pool_string(data: bytes, offset: int, is_utf8: bool) -> str:
    if is_utf8:
        i = offset
        b = data[i]
        i += 1
        if b & 0x80:
            i += 1  # second byte of utf16 char count (unused)
        u8_len = data[i]
        i += 1
        if u8_len & 0x80:
            u8_len = ((u8_len & 0x7F) << 8) | data[i]
            i += 1
        return data[i:i + u8_len].decode("utf-8")
    u16_len = struct.unpack_from("<H", data, offset)[0]
    i = offset + 2
    if u16_len & 0x8000:
        high = u16_len & 0x7FFF
        low = struct.unpack_from("<H", data, i)[0]
        u16_len = (high << 16) | low
        i += 2
    return data[i:i + u16_len * 2].decode("utf-16-le")


def encode_pool_string(text: str, is_utf8: bool) -> bytes:
    if is_utf8:
        u8 = text.encode("utf-8")
        u16_len = len(text)
        u8_len = len(u8)
        if u16_len > 0x7FFF or u8_len > 0x7FFF:
            raise ValueError(f"String too long to encode: {text!r}")
        prefix = bytearray()
        if u16_len > 0x7F:
            prefix += bytes([(u16_len >> 8) | 0x80, u16_len & 0xFF])
        else:
            prefix += bytes([u16_len])
        if u8_len > 0x7F:
            prefix += bytes([(u8_len >> 8) | 0x80, u8_len & 0xFF])
        else:
            prefix += bytes([u8_len])
        return bytes(prefix) + u8 + b"\x00"
    utf16 = text.encode("utf-16-le")
    u16_len = len(text)
    if u16_len > 0x7FFF:
        raise ValueError(f"String too long to encode: {text!r}")
    return struct.pack("<H", u16_len) + utf16 + b"\x00\x00"


def rename_authority(value: str, new_package: str) -> str:
    if value == OLD_PACKAGE or value.startswith(OLD_PACKAGE + "."):
        return new_package + value[len(OLD_PACKAGE):]
    if value.startswith(SHORT_PREFIX):
        return new_package + "." + value[len(SHORT_PREFIX):]
    return value


def rename_own_permission(value: str, new_package: str) -> str:
    if value == OLD_PACKAGE or value.startswith(OLD_PACKAGE + "."):
        return new_package + value[len(OLD_PACKAGE):]
    return value


def collect_attribute_rewrites(blob: bytes, xml_start: int, strings: list, new_package: str):
    """Walk XML chunks and return a list of (attr_file_offset, new_value).

    The caller rewrites each attribute's string reference at that file
    offset — not the underlying pool entry — so other consumers of the
    same pool index (e.g. ``android:name`` class references) are not
    disturbed.
    """
    attr_name_indices = {
        i: s for i, s in enumerate(strings)
        if s in {"package", "authorities", "taskAffinity", "permission", "name"}
    }
    tag_name_indices = {
        i: s for i, s in enumerate(strings) if s in {"manifest"} | PERMISSION_TAGS
    }

    to_rewrite: list[tuple[int, str]] = []

    off = xml_start
    blob_len = len(blob)
    while off + 8 <= blob_len:
        ctype, chdr, csize = struct.unpack_from("<HHI", blob, off)
        if csize == 0 or off + csize > blob_len:
            break
        if ctype == CHUNK_XML_START_ELEMENT:
            base = off + 16  # after 8-byte chunk hdr + line (4) + comment (4)
            (_ns, name_idx, attr_start, attr_size, attr_count) = struct.unpack_from(
                "<IIHHH", blob, base,
            )
            tag_name = tag_name_indices.get(name_idx)
            attr_base = base + attr_start
            for a in range(attr_count):
                ap = attr_base + a * attr_size
                (_a_ns, a_name_idx, raw_val_idx,
                 _tv_size, _tv_res0, tv_type, _tv_data) = struct.unpack_from(
                    ATTR_FMT, blob, ap,
                )
                attr_name = attr_name_indices.get(a_name_idx)
                if attr_name is None or raw_val_idx == 0xFFFFFFFF:
                    continue

                original = strings[raw_val_idx]
                if attr_name in ("package", "authorities", "taskAffinity"):
                    new_value = rename_authority(original, new_package)
                elif attr_name == "permission":
                    new_value = rename_own_permission(original, new_package)
                elif attr_name == "name" and tag_name in PERMISSION_TAGS:
                    new_value = rename_own_permission(original, new_package)
                else:
                    continue

                if new_value != original:
                    to_rewrite.append((ap, new_value))
        off += csize

    return to_rewrite


def patch_manifest(path: str, new_package: str) -> None:
    with open(path, "rb") as f:
        blob = bytearray(f.read())

    file_type, file_hdr_size, file_size = struct.unpack_from("<HHI", blob, 0)
    if file_type != CHUNK_XML:
        raise SystemExit(f"Not an AXML file (type=0x{file_type:04x})")
    if file_size != len(blob):
        raise SystemExit(f"Header size {file_size} != actual size {len(blob)}")

    pool_off = file_hdr_size
    (sp_type, sp_hdr_size, sp_chunk_size,
     sp_string_count, sp_style_count, sp_flags,
     sp_strings_start, sp_styles_start) = struct.unpack_from(
        "<HHIIIIII", blob, pool_off,
    )
    if sp_type != CHUNK_STRING_POOL:
        raise SystemExit(f"Expected string pool, got 0x{sp_type:04x}")

    is_utf8 = bool(sp_flags & FLAG_UTF8)

    offsets_off = pool_off + sp_hdr_size
    strings_data_off = pool_off + sp_strings_start
    strings_data_end = (
        pool_off + sp_styles_start if sp_style_count else pool_off + sp_chunk_size
    )

    offsets = list(struct.unpack_from(f"<{sp_string_count}I", blob, offsets_off))
    pool_bytes = bytes(blob[strings_data_off:strings_data_end])

    strings = [decode_pool_string(pool_bytes, o, is_utf8) for o in offsets]

    xml_start = pool_off + sp_chunk_size
    rewrites = collect_attribute_rewrites(blob, xml_start, strings, new_package)
    if not rewrites:
        print("  Warning: nothing to rewrite — manifest may already be patched")
        return

    # Allocate new pool indices for each distinct new value. Appending
    # strings at the end extends string_count; we update offsets[] to
    # include the new entries so every attribute referencing the new
    # index resolves to the correct appended bytes.
    new_value_to_index: dict[str, int] = {}
    appended = bytearray()
    new_offsets = list(offsets)

    def intern(value: str) -> int:
        if value in new_value_to_index:
            return new_value_to_index[value]
        idx = len(new_offsets)
        new_offsets.append(len(pool_bytes) + len(appended))
        appended.extend(encode_pool_string(value, is_utf8))
        new_value_to_index[value] = idx
        return idx

    # Rewrite the targeted attributes in the blob in place. Attribute
    # entries encode the string reference twice (raw_val_idx and
    # typed_value.data when type == TYPE_STRING), so update both.
    attr_changes = 0
    for attr_ap, new_value in rewrites:
        new_idx = intern(new_value)
        (_a_ns, a_name_idx, _old_raw, tv_size, tv_res0, tv_type, tv_data) = struct.unpack_from(
            ATTR_FMT, blob, attr_ap,
        )
        new_tv_data = new_idx if tv_type == TYPE_STRING else tv_data
        struct.pack_into(
            ATTR_FMT, blob, attr_ap,
            _a_ns, a_name_idx, new_idx, tv_size, tv_res0, tv_type, new_tv_data,
        )
        attr_changes += 1

    new_pool_bytes = pool_bytes + bytes(appended)
    pad = (-len(new_pool_bytes)) & 3
    new_pool_bytes += b"\x00" * pad

    new_string_count = len(new_offsets)
    new_offsets_bytes = struct.pack(f"<{new_string_count}I", *new_offsets)

    styles_section = (
        bytes(blob[pool_off + sp_styles_start:pool_off + sp_chunk_size])
        if sp_style_count else b""
    )
    new_strings_start = sp_hdr_size + len(new_offsets_bytes)
    new_styles_start = (
        new_strings_start + len(new_pool_bytes) if sp_style_count else 0
    )
    new_chunk_size = new_strings_start + len(new_pool_bytes) + len(styles_section)

    new_pool_header = struct.pack(
        "<HHIIIIII",
        sp_type, sp_hdr_size, new_chunk_size,
        new_string_count, sp_style_count, sp_flags,
        new_strings_start, new_styles_start,
    )

    new_pool_chunk = new_pool_header + new_offsets_bytes + new_pool_bytes + styles_section

    rest = bytes(blob[pool_off + sp_chunk_size:])
    new_blob = bytearray(blob[:pool_off]) + new_pool_chunk + rest
    struct.pack_into("<I", new_blob, 4, len(new_blob))

    with open(path, "wb") as f:
        f.write(new_blob)

    print(f"  Rewrote {attr_changes} attribute(s) via {len(new_value_to_index)} new pool entries; package -> {new_package}")
    for value, idx in sorted(new_value_to_index.items(), key=lambda kv: kv[1]):
        print(f"    [{idx}] {value}")


def main() -> int:
    if len(sys.argv) < 3:
        print("Usage: apply_clone_patch.py <AndroidManifest.xml> <new_package>")
        return 1
    patch_manifest(sys.argv[1], sys.argv[2])
    return 0


if __name__ == "__main__":
    sys.exit(main())
