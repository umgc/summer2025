#!/usr/bin/env python3
"""
Create a CareConnect app icon with love and connection theme
This script creates an SVG that can be converted to PNG
"""

def create_svg_icon():
    svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Gradient for main background -->
    <radialGradient id="mainGradient" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#5C9EFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#407BFF;stop-opacity:1" />
    </radialGradient>
    
    <!-- Gradient for heart -->
    <linearGradient id="heartGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#FF8A80;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FF5252;stop-opacity:1" />
    </linearGradient>
    
    <!-- Drop shadow filter -->
    <filter id="dropshadow" x="-50%" y="-50%" width="200%" height="200%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-color="#000000" flood-opacity="0.3"/>
    </filter>
  </defs>
  
  <!-- Main circle background -->
  <circle cx="512" cy="512" r="450" fill="url(#mainGradient)" filter="url(#dropshadow)"/>
  
  <!-- Outer ring for connection -->
  <circle cx="512" cy="512" r="420" fill="none" stroke="#FFFFFF" stroke-width="3" opacity="0.3"/>
  
  <!-- Medical cross in center -->
  <rect x="462" y="362" width="100" height="30" rx="5" fill="#FFFFFF"/>
  <rect x="482" y="342" width="60" height="130" rx="5" fill="#FFFFFF"/>
  
  <!-- Heart symbol -->
  <g transform="translate(512, 600)">
    <!-- Heart shape using paths -->
    <path d="M0,15 C0,15 -25,-10 -45,5 C-55,15 -45,35 0,55 C45,35 55,15 45,5 C25,-10 0,15 0,15 Z" 
          fill="url(#heartGradient)" filter="url(#dropshadow)"/>
  </g>
  
  <!-- Connecting people around the circle -->
  <!-- Person 1 - Top Right -->
  <g transform="translate(650, 300)" opacity="0.9">
    <circle cx="0" cy="0" r="15" fill="#FFFFFF"/>
    <rect x="-8" y="15" width="16" height="25" rx="3" fill="#FFFFFF"/>
    <!-- Arms reaching toward center -->
    <rect x="-12" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(-30)"/>
    <rect x="4" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(30)"/>
  </g>
  
  <!-- Person 2 - Top Left -->
  <g transform="translate(374, 300)" opacity="0.9">
    <circle cx="0" cy="0" r="15" fill="#FFFFFF"/>
    <rect x="-8" y="15" width="16" height="25" rx="3" fill="#FFFFFF"/>
    <!-- Arms reaching toward center -->
    <rect x="-12" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(30)"/>
    <rect x="4" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(-30)"/>
  </g>
  
  <!-- Person 3 - Bottom Right -->
  <g transform="translate(650, 724)" opacity="0.9">
    <circle cx="0" cy="0" r="15" fill="#FFFFFF"/>
    <rect x="-8" y="15" width="16" height="25" rx="3" fill="#FFFFFF"/>
    <!-- Arms reaching toward center -->
    <rect x="-12" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(30)"/>
    <rect x="4" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(-30)"/>
  </g>
  
  <!-- Person 4 - Bottom Left -->
  <g transform="translate(374, 724)" opacity="0.9">
    <circle cx="0" cy="0" r="15" fill="#FFFFFF"/>
    <rect x="-8" y="15" width="16" height="25" rx="3" fill="#FFFFFF"/>
    <!-- Arms reaching toward center -->
    <rect x="-12" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(-30)"/>
    <rect x="4" y="20" width="8" height="3" rx="1" fill="#FFFFFF" transform="rotate(30)"/>
  </g>
  
  <!-- Connection lines between people and center -->
  <g opacity="0.4" stroke="#FFFFFF" stroke-width="2" fill="none">
    <line x1="512" y1="400" x2="650" y2="315"/>
    <line x1="512" y1="400" x2="374" y2="315"/>
    <line x1="512" y1="600" x2="650" y2="715"/>
    <line x1="512" y1="600" x2="374" y2="715"/>
  </g>
  
  <!-- Small hearts floating around -->
  <g fill="#FF8A80" opacity="0.6">
    <path d="M200,200 C200,200 190,190 180,195 C175,200 180,210 200,220 C220,210 225,200 220,195 C210,190 200,200 200,200 Z" transform="scale(0.5)"/>
    <path d="M800,300 C800,300 790,290 780,295 C775,300 780,310 800,320 C820,310 825,300 820,295 C810,290 800,300 800,300 Z" transform="scale(0.4)"/>
    <path d="M300,800 C300,800 290,790 280,795 C275,800 280,810 300,820 C320,810 325,800 320,795 C310,790 300,800 300,800 Z" transform="scale(0.3)"/>
    <path d="M750,750 C750,750 740,740 730,745 C725,750 730,760 750,770 C770,760 775,750 770,745 C760,740 750,750 750,750 Z" transform="scale(0.6)"/>
  </g>
  
  <!-- Text "CC" in elegant font (optional - can be removed for pure icon) -->
  <text x="512" y="420" font-family="Arial, sans-serif" font-size="60" font-weight="bold" 
        text-anchor="middle" fill="#FFFFFF" opacity="0.3">CC</text>
</svg>'''
    
    return svg_content

def main():
    svg_content = create_svg_icon()
    
    # Save SVG file
    with open('app_icon.svg', 'w') as f:
        f.write(svg_content)
    
    print("✅ CareConnect app icon SVG created successfully!")
    print("📁 Created: app_icon.svg")
    print("\n🔄 To convert to PNG, you can:")
    print("1. Use online converter: https://convertio.co/svg-png/")
    print("2. Use Inkscape: inkscape app_icon.svg --export-png=app_icon.png --export-width=1024")
    print("3. Use ImageMagick: convert app_icon.svg -resize 1024x1024 app_icon.png")
    print("\n🎨 Icon features:")
    print("- Medical cross for healthcare")
    print("- Heart symbol for love and care")
    print("- Connected people showing community")
    print("- Soft blue gradient background")
    print("- Floating hearts for warmth")

if __name__ == "__main__":
    main()
