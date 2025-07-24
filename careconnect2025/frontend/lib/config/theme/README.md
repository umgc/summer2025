# CareConnect App Theme Guide

## Overview

This document provides guidelines on using the centralized theme system in the CareConnect app. Following these guidelines ensures visual consistency across all screens and components.

## Theme System

The app theme has been centralized to ensure consistent colors, typography, and component styles. The main theme files are:

- `config/theme/app_theme.dart`: Contains the core theme definitions
- `config/theme/color_utils.dart`: Provides utility functions for accessing theme colors

## Using the Theme System

### Colors

Instead of using direct color references like `Colors.blue.shade700`, use the ColorUtils class:

```dart
// AVOID
Container(
  color: Colors.green.shade600,
  child: Text('Hello'),
)

// RECOMMENDED
Container(
  color: ColorUtils.success,  // or other semantic color names
  child: Text('Hello'),
)
```

### Color Variations

For color variations with opacity or lighter shades:

```dart
// Lighter variants
ColorUtils.getPrimaryLight()
ColorUtils.getSuccessLight()
ColorUtils.getInfoLight()

// With opacity
ColorUtils.getPrimaryWithOpacity(0.1)
ColorUtils.getSuccessWithOpacity(0.2)
```

### Typography

Use the predefined text styles:

```dart
Text(
  'Heading',
  style: Theme.of(context).textTheme.displayMedium,
)

// Or directly from AppTheme
Text(
  'Body text',
  style: AppTheme.bodyLarge,
)
```

### Button Styles

```dart
ElevatedButton(
  style: AppTheme.primaryButtonStyle,
  onPressed: () {},
  child: Text('Primary Action'),
)

ElevatedButton(
  style: AppTheme.secondaryButtonStyle,
  onPressed: () {},
  child: Text('Secondary Action'),
)
```

## Accessibility Guidelines

1. Maintain sufficient contrast between text and background
2. Use a minimum font size of 14 for body text
3. Use the semantic color system (primary, success, warning, error)
4. Avoid using green and red as the only differentiators

## Component Guidelines

### Cards

```dart
Card(
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```

### Input Fields

```dart
TextField(
  decoration: AppTheme.inputDecoration('Label', hint: 'Hint text'),
)
```

## Adding New Components

When adding new components or screens, refer to this guide and the existing theme files to ensure consistency.
