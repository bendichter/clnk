# Clnk Color Palette 🍹

Derived from the app icon (clinking glasses).

## Primary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Deep Teal** | `#035552` | rgb(3, 85, 82) | Primary background, main brand color |
| **Dark Teal** | `#0B443D` | rgb(11, 68, 61) | Secondary background, dark accents |
| **Midnight Teal** | `#0A3B38` | rgb(10, 59, 56) | Deepest shadows, text on light |

## Accent Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Vibrant Cyan** | `#09817B` | rgb(9, 129, 123) | Interactive elements, links, highlights |
| **Ocean Teal** | `#0C7F80` | rgb(12, 127, 128) | Buttons, CTAs |

## Secondary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Sage** | `#669B92` | rgb(102, 155, 146) | Secondary text, borders |
| **Seafoam** | `#52857A` | rgb(82, 133, 122) | Cards, subtle backgrounds |
| **Muted Teal** | `#47726B` | rgb(71, 114, 107) | Disabled states, dividers |

## Light Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Cream** | `#F4F7E8` | rgb(244, 247, 232) | Light backgrounds, text on dark |
| **Light Sage** | `#A1CAC0` | rgb(161, 202, 192) | Highlights, secondary light elements |

---

## SwiftUI Color Extension

```swift
import SwiftUI

extension Color {
    // Primary
    static let clnkDeepTeal = Color(red: 3/255, green: 85/255, blue: 82/255)
    static let clnkDarkTeal = Color(red: 11/255, green: 68/255, blue: 61/255)
    static let clnkMidnightTeal = Color(red: 10/255, green: 59/255, blue: 56/255)
    
    // Accent
    static let clnkVibrantCyan = Color(red: 9/255, green: 129/255, blue: 123/255)
    static let clnkOceanTeal = Color(red: 12/255, green: 127/255, blue: 128/255)
    
    // Secondary
    static let clnkSage = Color(red: 102/255, green: 155/255, blue: 146/255)
    static let clnkSeafoam = Color(red: 82/255, green: 133/255, blue: 122/255)
    static let clnkMutedTeal = Color(red: 71/255, green: 114/255, blue: 107/255)
    
    // Light
    static let clnkCream = Color(red: 244/255, green: 247/255, blue: 232/255)
    static let clnkLightSage = Color(red: 161/255, green: 202/255, blue: 192/255)
}
```

## CSS Variables

```css
:root {
    /* Primary */
    --clnk-deep-teal: #035552;
    --clnk-dark-teal: #0B443D;
    --clnk-midnight-teal: #0A3B38;
    
    /* Accent */
    --clnk-vibrant-cyan: #09817B;
    --clnk-ocean-teal: #0C7F80;
    
    /* Secondary */
    --clnk-sage: #669B92;
    --clnk-seafoam: #52857A;
    --clnk-muted-teal: #47726B;
    
    /* Light */
    --clnk-cream: #F4F7E8;
    --clnk-light-sage: #A1CAC0;
}
```

---

## Color Relationships

```
Darkest ←——————————————————————————————→ Lightest

#0A3B38  #0B443D  #035552  #09817B  #52857A  #669B92  #A1CAC0  #F4F7E8
   ▲         ▲        ▲        ▲        ▲        ▲        ▲        ▲
Midnight  Dark    Deep    Vibrant  Seafoam   Sage    Light   Cream
 Teal     Teal    Teal     Cyan                      Sage
```

## Suggested Pairings

- **Primary UI**: Deep Teal (`#035552`) background + Cream (`#F4F7E8`) text
- **Cards**: Dark Teal (`#0B443D`) background + Light Sage (`#A1CAC0`) text  
- **Buttons**: Ocean Teal (`#0C7F80`) background + Cream (`#F4F7E8`) text
- **Links/Interactive**: Vibrant Cyan (`#09817B`)
- **Subtle elements**: Sage (`#669B92`) or Muted Teal (`#47726B`)
