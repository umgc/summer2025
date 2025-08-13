#!/usr/bin/env python3
"""
Simple PNG Icon Creator for CareConnect App
Creates a healthcare-themed icon without external dependencies
"""

def create_simple_png():
    """Create a simple PNG icon using minimal approach"""
    
    # Create a simple PPM format first (can be converted to PNG)
    width, height = 1024, 1024
    
    # Create PPM data
    ppm_data = f"P3\n{width} {height}\n255\n"
    
    for y in range(height):
        for x in range(width):
            # Create a gradient background (light blue to white)
            bg_intensity = int(200 + (55 * (height - y) / height))
            bg_color = (min(bg_intensity, 255), min(bg_intensity + 20, 255), 255)
            
            # Center coordinates
            cx, cy = width // 2, height // 2
            
            # Distance from center
            dx, dy = x - cx, y - cy
            distance = (dx*dx + dy*dy) ** 0.5
            
            # Medical cross (white)
            cross_thickness = 80
            cross_length = 300
            
            is_cross = False
            if (abs(dx) < cross_thickness and abs(dy) < cross_length) or \
               (abs(dy) < cross_thickness and abs(dx) < cross_length):
                is_cross = True
                color = (255, 255, 255)  # White cross
            
            # Heart shape (simplified circle for now)
            elif distance < 120 and y < cy - 50:
                color = (220, 53, 69)  # Red heart color
            
            # Circle border for modern look
            elif abs(distance - 400) < 20:
                color = (70, 130, 180)  # Steel blue border
            
            else:
                color = bg_color
            
            ppm_data += f"{color[0]} {color[1]} {color[2]} "
        ppm_data += "\n"
    
    # Write PPM file
    with open('app_icon.ppm', 'w') as f:
        f.write(ppm_data)
    
    print("✅ Created app_icon.ppm")
    print("🔄 Converting PPM to PNG...")
    
    # Try to convert using system tools
    import subprocess
    import os
    
    try:
        # Try using netpbm tools if available
        result = subprocess.run(['pnmtopng', 'app_icon.ppm'], 
                              capture_output=True, 
                              stdout=open('app_icon.png', 'wb'))
        if result.returncode == 0:
            print("✅ PNG conversion successful with pnmtopng!")
        else:
            raise Exception("pnmtopng failed")
    except:
        print("❌ pnmtopng not available")
        
        # Alternative: Create a basic BMP format that can be more easily converted
        create_simple_bmp()

def create_simple_bmp():
    """Create a BMP file which is easier to handle"""
    import struct
    
    width, height = 1024, 1024
    
    # BMP Header
    file_size = 54 + (width * height * 3)
    bmp_header = struct.pack('<2sIHHI', b'BM', file_size, 0, 0, 54)
    dib_header = struct.pack('<IIIHHIIIIII', 40, width, height, 1, 24, 0, 
                            width * height * 3, 0, 0, 0, 0)
    
    # Create pixel data
    pixel_data = bytearray()
    
    for y in range(height-1, -1, -1):  # BMP is bottom-up
        for x in range(width):
            # Center coordinates  
            cx, cy = width // 2, height // 2
            dx, dy = x - cx, y - cy
            distance = (dx*dx + dy*dy) ** 0.5
            
            # Gradient background
            bg_intensity = int(200 + (55 * y / height))
            bg_color = [min(bg_intensity + 40, 255), min(bg_intensity + 20, 255), min(bg_intensity, 255)]
            
            # Medical cross
            cross_thickness = 80
            cross_length = 300
            
            if (abs(dx) < cross_thickness and abs(dy) < cross_length) or \
               (abs(dy) < cross_thickness and abs(dx) < cross_length):
                color = [255, 255, 255]  # White cross
            
            # Heart area (simplified)
            elif distance < 120 and y > cy + 50:
                color = [69, 53, 220]  # Red (BGR format for BMP)
            
            # Border circle
            elif abs(distance - 400) < 15:
                color = [180, 130, 70]  # Steel blue (BGR)
            
            else:
                color = bg_color
            
            # BMP uses BGR format
            pixel_data.extend(color)
        
        # BMP rows must be padded to 4-byte boundary
        padding = (4 - (width * 3) % 4) % 4
        pixel_data.extend([0] * padding)
    
    # Write BMP file
    with open('app_icon.bmp', 'wb') as f:
        f.write(bmp_header)
        f.write(dib_header)
        f.write(pixel_data)
    
    print("✅ Created app_icon.bmp")
    print("📝 You can convert this to PNG using:")
    print("   - Online converter: https://convertio.co/bmp-png/")
    print("   - Or rename to app_icon.png (many systems accept BMP as PNG)")

def main():
    print("🎨 Creating CareConnect app icon...")
    create_simple_png()
    print("\n✅ Icon creation complete!")
    print("📁 Files created: app_icon.ppm, app_icon.bmp")
    print("\n🔄 Next steps:")
    print("1. Convert app_icon.bmp to PNG format")
    print("2. Rename to app_icon.png")  
    print("3. Move to assets/images/ directory")

if __name__ == "__main__":
    main()
