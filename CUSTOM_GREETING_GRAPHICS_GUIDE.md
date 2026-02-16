# Custom Time-of-Day Graphics Guide

## 🎨 Overview

The home screen greeting header now supports custom images that change based on time of day:
- **Morning** (12am - 12pm): morning-icon
- **Afternoon** (12pm - 5pm): afternoon-icon
- **Evening** (5pm - 12am): evening-icon

## 📱 Step-by-Step Setup

### Step 1: Prepare Your Images

**Recommended Specifications:**
- **Size:** 120x120 points
  - @1x: 120x120 pixels
  - @2x: 240x240 pixels (most important)
  - @3x: 360x360 pixels
- **Format:** PNG with transparency
- **Style:** Flat, simple designs work best
- **Colors:** Consider your app's theme colors

**Image Ideas:**
- Morning: Sun, sunrise, coffee cup, rooster
- Afternoon: Partly cloudy sun, lunch, productivity icon
- Evening: Moon, stars, sunset, relaxation icon

### Step 2: Add Images to Xcode

1. **Open Xcode**
2. **Project Navigator** (left sidebar) → **Assets.xcassets**
3. **Right-click** in the assets area → **New Image Set**
4. **Rename** the image set:
   - First set: `morning-icon`
   - Second set: `afternoon-icon`
   - Third set: `evening-icon`

5. **Drag your images** into the appropriate slots:
   - If you have one image, drag it to "Universal"
   - If you have multiple resolutions, drag to 1x, 2x, 3x

### Step 3: Verify in Code

The code has been updated in `ContentView.swift`:
```swift
private var greetingImageName: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<12: return "morning-icon"
    case 12..<17: return "afternoon-icon"
    default: return "evening-icon"
    }
}
```

### Step 4: Build and Test

1. **Run your app** (Cmd+R)
2. The greeting header should show your custom image
3. To test different times:
   - Change your Mac's system time
   - Or wait for the time to change naturally

## 🎨 Styling Options

### Option 1: Simple Image (Current)
```swift
Image(greetingImageName)
    .resizable()
    .scaledToFit()
    .frame(width: 60, height: 60)
```

### Option 2: Circular Background
```swift
Circle()
    .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
    .frame(width: 70, height: 70)
    .overlay(
        Image(greetingImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
    )
```

### Option 3: Rounded Rectangle Background
```swift
RoundedRectangle(cornerRadius: 12)
    .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
    .frame(width: 70, height: 70)
    .overlay(
        Image(greetingImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 45, height: 45)
    )
```

### Option 4: Gradient Background
```swift
Circle()
    .fill(
        LinearGradient(
            colors: [
                themeManager.currentTheme.primaryColor.opacity(0.3),
                themeManager.currentTheme.accentColor.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
    .frame(width: 70, height: 70)
    .overlay(
        Image(greetingImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
    )
```

### Option 5: Shadow Effect
```swift
Image(greetingImageName)
    .resizable()
    .scaledToFit()
    .frame(width: 60, height: 60)
    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
```

### Option 6: Animated (Subtle Pulse)
```swift
Image(greetingImageName)
    .resizable()
    .scaledToFit()
    .frame(width: 60, height: 60)
    .scaleEffect(isAnimating ? 1.05 : 1.0)
    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
    .onAppear { isAnimating = true }

// Add this state variable to HomeView:
@State private var isAnimating = false
```

## 🖼️ Image Templates

### Using SF Symbols (Apple's Built-in Icons)

If you don't have custom images yet, you can use SF Symbols:

```swift
private var greetingHeader: some View {
    HStack {
        VStack(alignment: .leading) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
            Text("Here's what's happening today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        Spacer()
        
        // Use SF Symbol instead
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        greetingColor.opacity(0.3),
                        greetingColor.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 70, height: 70)
            .overlay(
                Image(systemName: greetingSFSymbol)
                    .font(.system(size: 30))
                    .foregroundColor(greetingColor)
            )
    }
}

private var greetingSFSymbol: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<12: return "sun.max.fill"
    case 12..<17: return "cloud.sun.fill"
    default: return "moon.stars.fill"
    }
}

private var greetingColor: Color {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<12: return .orange
    case 12..<17: return .blue
    default: return .purple
    }
}
```

## 🎨 Design Resources

### Free Icon Sources
- **SF Symbols** (built into Xcode) - Free
- **Icons8** - https://icons8.com (Free with attribution)
- **Flaticon** - https://www.flaticon.com (Free with attribution)
- **Noun Project** - https://thenounproject.com
- **Freepik** - https://www.freepik.com

### Design Tips
1. **Keep it simple** - Simple, recognizable shapes work best
2. **Match your theme** - Use colors that complement your app's themes
3. **Consistent style** - All three icons should have a similar design style
4. **High contrast** - Ensure icons are visible on light and dark backgrounds
5. **Test on device** - Check how they look on actual iPhone screens

## 📐 Image Creation Guide

### Using Figma (Free)
1. Create a 240x240 px artboard
2. Design your icon centered
3. Export as PNG @2x
4. Create @1x (120x120) and @3x (360x360) versions

### Using Sketch
1. Create a 120x120 pt artboard
2. Design your icon
3. Export with 1x, 2x, 3x options checked

### Using Adobe Illustrator
1. Create 120x120 pt artboard
2. Design your icon
3. Export for iOS (automatically creates all sizes)

## 🔄 Switching Between Emojis and Images

### Keep Both Options

You can let users choose in Settings:

```swift
// In HomeView
private var greetingHeader: some View {
    HStack {
        VStack(alignment: .leading) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
            Text("Here's what's happening today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        Spacer()
        
        // Show image or emoji based on setting
        if dataManager.settings.useCustomGreetingIcons {
            Image(greetingImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        } else {
            Circle()
                .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(greetingEmoji)
                        .font(.largeTitle)
                )
        }
    }
}
```

Then add a toggle in Settings to switch between them.

## 🐛 Troubleshooting

### Images Not Showing?

**Check Asset Names:**
- Ensure they're named exactly: `morning-icon`, `afternoon-icon`, `evening-icon`
- Names are case-sensitive

**Check Target Membership:**
1. Select image set in Assets
2. Show File Inspector (right sidebar)
3. Verify your app target is checked

**Check Image Format:**
- Use PNG format
- RGB color space
- Include transparency (alpha channel)

**Clean Build:**
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Run again (Cmd+R)

### Images Look Blurry?

- Provide @2x and @3x versions
- Use higher resolution source images
- Ensure PNG export quality is set to maximum

### Images Wrong Color?

If you want the image to adapt to the theme color:
```swift
Image(greetingImageName)
    .resizable()
    .scaledToFit()
    .frame(width: 60, height: 60)
    .foregroundColor(themeManager.currentTheme.primaryColor)
    // Note: This only works with template rendering mode
    .renderingMode(.template)
```

## ✅ Checklist

- [ ] Created three image sets in Assets.xcassets
- [ ] Named them: morning-icon, afternoon-icon, evening-icon
- [ ] Added images to each set (at least @2x)
- [ ] Code updated in ContentView.swift
- [ ] Tested in simulator/device
- [ ] Images display at correct times
- [ ] Images look good with all theme colors
- [ ] Images work on light and dark mode (if applicable)

## 🎯 Quick Test

To test all three images quickly:

**Test Morning Icon** (12am-12pm):
- Set Mac system time to 10:00 AM
- Run app

**Test Afternoon Icon** (12pm-5pm):
- Set Mac system time to 2:00 PM
- Run app

**Test Evening Icon** (5pm-12am):
- Set Mac system time to 8:00 PM
- Run app

---

**Note:** Remember to set your system time back to automatic after testing!
