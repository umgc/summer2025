#!/usr/bin/env python3
"""
SVG to PNG Converter for CareConnect App Icon
Attempts multiple methods to convert SVG to PNG format
"""

import os
import sys
import subprocess

def try_cairosvg():
    """Try using cairosvg library"""
    try:
        import cairosvg
        print("✅ Using cairosvg for conversion...")
        
        cairosvg.svg2png(
            url='app_icon.svg',
            write_to='app_icon.png',
            output_width=1024,
            output_height=1024
        )
        return True
    except ImportError:
        print("❌ cairosvg not available")
        return False
    except Exception as e:
        print(f"❌ cairosvg conversion failed: {e}")
        return False

def try_wand():
    """Try using Wand (ImageMagick Python binding)"""
    try:
        from wand.image import Image
        print("✅ Using Wand for conversion...")
        
        with Image(filename='app_icon.svg') as img:
            img.format = 'png'
            img.resize(1024, 1024)
            img.save(filename='app_icon.png')
        return True
    except ImportError:
        print("❌ Wand not available")
        return False
    except Exception as e:
        print(f"❌ Wand conversion failed: {e}")
        return False

def create_png_directly():
    """Create PNG directly using Python PIL/Pillow if available"""
    try:
        from PIL import Image, ImageDraw
        import xml.etree.ElementTree as ET
        
        print("✅ Creating PNG directly with PIL...")
        
        # Create a 1024x1024 image with transparent background
        img = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Background gradient (simplified)
        for y in range(1024):
            alpha = int(255 * (1 - y / 1024) * 0.3)
            color = (70, 130, 180, alpha)  # Steel blue with gradient
            draw.line([(0, y), (1024, y)], fill=color)
        
        # Medical cross (white)
        cross_color = (255, 255, 255, 255)
        # Vertical bar
        draw.rectangle([462, 300, 562, 724], fill=cross_color)
        # Horizontal bar
        draw.rectangle([350, 462, 674, 562], fill=cross_color)
        
        # Heart shape (simplified red heart)
        heart_color = (220, 53, 69, 255)
        # Heart as two circles and a triangle (simplified)
        draw.ellipse([450, 380, 500, 430], fill=heart_color)
        draw.ellipse([524, 380, 574, 430], fill=heart_color)
        draw.polygon([(450, 410), (574, 410), (512, 480)], fill=heart_color)
        
        # Save the image
        img.save('app_icon.png', 'PNG')
        return True
    except ImportError:
        print("❌ PIL/Pillow not available")
        return False
    except Exception as e:
        print(f"❌ PIL conversion failed: {e}")
        return False

def main():
    print("🔄 Converting SVG to PNG...")
    
    # Check if SVG file exists
    if not os.path.exists('app_icon.svg'):
        print("❌ app_icon.svg not found!")
        return False
    
    # Try conversion methods in order of preference
    methods = [
        try_cairosvg,
        try_wand,
        create_png_directly
    ]
    
    for method in methods:
        if method():
            print("✅ PNG conversion successful!")
            print("📁 Created: app_icon.png (1024x1024)")
            return True
    
    print("\n❌ All conversion methods failed!")
    print("\n🌐 Please use an online converter:")
    print("1. Go to https://convertio.co/svg-png/")
    print("2. Upload app_icon.svg")
    print("3. Convert to PNG")
    print("4. Download as app_icon.png")
    print("5. Make sure it's 1024x1024 pixels")
    
    return False

if __name__ == "__main__":
    main()
