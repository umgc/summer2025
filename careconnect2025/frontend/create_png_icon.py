#!/usr/bin/env python3
"""
Create a minimal PNG icon for CareConnect app
Using pure Python to create a valid PNG file
"""

import struct
import zlib

def create_png_icon():
    """Create a simple PNG icon with healthcare theme"""
    
    width, height = 1024, 1024
    
    # Create RGBA pixel data
    pixels = []
    
    for y in range(height):
        row = []
        for x in range(width):
            # Center coordinates
            cx, cy = width // 2, height // 2
            dx, dy = x - cx, y - cy
            distance = (dx*dx + dy*dy) ** 0.5
            
            # Default background (light blue gradient)
            bg_intensity = int(240 - (40 * y / height))
            r, g, b, a = bg_intensity, bg_intensity + 10, 255, 255
            
            # Medical cross (white)
            cross_thickness = 60
            cross_length = 250
            
            if (abs(dx) < cross_thickness and abs(dy) < cross_length) or \
               (abs(dy) < cross_thickness and abs(dx) < cross_length):
                r, g, b, a = 255, 255, 255, 255  # White cross
            
            # Heart symbol (red, positioned above cross)
            elif distance < 80 and y < cy - 100:
                r, g, b, a = 220, 53, 69, 255  # Red heart
            
            # Outer circle border
            elif 380 < distance < 420:
                r, g, b, a = 70, 130, 180, 255  # Steel blue
            
            row.extend([r, g, b, a])
        pixels.append(row)
    
    # Convert to bytes
    raw_data = b''
    for row in pixels:
        raw_data += b'\x00'  # PNG filter type (None)
        raw_data += bytes(row)
    
    # Compress the data
    compressed_data = zlib.compress(raw_data)
    
    # PNG file structure
    png_data = b''
    
    # PNG signature
    png_data += b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>2I5B', width, height, 8, 6, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff
    png_data += struct.pack('>I', len(ihdr_data))
    png_data += b'IHDR'
    png_data += ihdr_data
    png_data += struct.pack('>I', ihdr_crc)
    
    # IDAT chunk
    idat_crc = zlib.crc32(b'IDAT' + compressed_data) & 0xffffffff
    png_data += struct.pack('>I', len(compressed_data))
    png_data += b'IDAT'
    png_data += compressed_data
    png_data += struct.pack('>I', idat_crc)
    
    # IEND chunk
    iend_crc = zlib.crc32(b'IEND') & 0xffffffff
    png_data += struct.pack('>I', 0)
    png_data += b'IEND'
    png_data += struct.pack('>I', iend_crc)
    
    return png_data

def main():
    print("🎨 Creating CareConnect PNG icon...")
    
    try:
        png_data = create_png_icon()
        
        # Write to file
        with open('assets/images/app_icon.png', 'wb') as f:
            f.write(png_data)
        
        print("✅ PNG icon created successfully!")
        print("📁 Created: assets/images/app_icon.png (1024x1024)")
        print("🎨 Icon features:")
        print("   - Medical cross (white)")
        print("   - Heart symbol (red)")
        print("   - Circular border (blue)")
        print("   - Gradient background")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating PNG: {e}")
        return False

if __name__ == "__main__":
    if main():
        print("\n🔄 Next step: Generate app icons for all platforms")
        print("Run: flutter packages pub run flutter_launcher_icons:main")
    else:
        print("\n❌ Icon creation failed")
