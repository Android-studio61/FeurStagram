import struct, zipfile, os
latest_file = sorted([p for p in os.listdir('artifacts') if p.startswith('feurstagram_patched_clone_') and p.endswith('.apk')], key=lambda p: os.path.getmtime(os.path.join('artifacts', p)), reverse=True)[0]
apk = os.path.join('artifacts', latest_file)
with zipfile.ZipFile(apk, 'r') as zf:
    d = zf.read('resources.arsc')
pos = 0
found = []
while pos < len(d) - 12:
    type_val = struct.unpack_from('<H', d, pos)[0]
    if type_val == 0x0200:
        name = d[pos+12:pos+268].decode('utf-16-le', 'ignore').split('\x00', 1)[0]
        if name and all(32 <= ord(c) < 127 for c in name):
            found.append(name)
        cs = struct.unpack_from('<I', d, pos+4)[0]
        if cs > 0:
            pos += cs
            continue
    pos += 1
print('RESOURCE_PACKAGE_NAMES=' + ','.join(found))
