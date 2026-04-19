import struct

def parse_resources(file_path):
    with open(file_path, 'rb') as f:
        header = f.read(8)
        if not header: return
        res_type, header_size, size = struct.unpack('<HHL', header)
        
        # We look for RES_TABLE_PACKAGE_TYPE which is 0x0200
        # The resources.arsc starts with RES_TABLE_TYPE (0x0002)
        f.seek(0)
        data = f.read()
        
        pos = 0
        while pos + 8 <= len(data):
            chunk_type, chunk_header_size, chunk_size = struct.unpack('<HHL', data[pos:pos+8])
            if chunk_type == 0x0200: # RES_TABLE_PACKAGE_TYPE
                package_id = struct.unpack('<L', data[pos+8:pos+12])[0]
                # Name is at pos+12, 128 characters (256 bytes) UTF-16
                name_bytes = data[pos+12:pos+12+256]
                name = name_bytes.decode('utf-16').split('\0')[0]
                print(f"Package Name: {name}, ID: {package_id}")
            
            if chunk_size == 0: break
            pos += chunk_size

parse_resources('instagram_source/resources.arsc')
