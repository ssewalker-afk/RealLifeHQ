# Launch Screen Setup Guide

## How to Add Your Launch Screen to the App

There are two main methods to add a launch screen in iOS:

## Method 1: Launch Screen Storyboard (Recommended for iOS 13+)

### Step 1: Add Your Launch Screen File

If you created a storyboard file (`.storyboard`):

1. **In Xcode Project Navigator** (left sidebar)
2. **Right-click** on your project folder
3. **Select** "Add Files to [Project Name]..."
4. **Navigate to** your launch screen file
5. **Select** your `.storyboard` file (e.g., `LaunchScreen.storyboard`)
6. **Check** "Copy items if needed"
7. **Make sure** your app target is selected
8. **Click** "Add"

### Step 2: Configure the Launch Screen

1. **Click on your project** in the Project Navigator (top item)
2. **Select your app target** from the list
3. **Go to the "General" tab**
4. **Scroll down** to "App Icons and Launch Screen"
5. Under **"Launch Screen File"**:
   - Select your `.storyboard` file from the dropdown
   - Should show: `LaunchScreen` (without .storyboard extension)

### Step 3: Clean and Build

1. **Clean Build Folder:** Product → Clean Build Folder (Shift+Cmd+K)
2. **Delete App** from simulator/device (important!)
3. **Build and Run:** Cmd+R
4. Your launch screen should appear!

---

## Method 2: Launch Screen with SwiftUI (iOS 14+)

If you want to use a SwiftUI view as your launch screen:

### Step 1: Create Launch Screen View

Create a new Swift file called `LaunchScreenView.swift`:

```swift
import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background color
            Color.blue.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App logo or icon
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                // App name
                Text("RealLifeHQ")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                // Tagline (optional)
                Text("Organize Your Life")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
```

### Step 2: Add Launch Screen Logic to App

Update your main app file (usually `@main` struct):

```swift
import SwiftUI

@main
struct RealLifeHQApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var themeManager = ThemeManager()
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(dataManager)
                    .environmentObject(themeManager)
                
                // Show launch screen overlay
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Hide launch screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
```

---

## Method 3: Launch Screen with Custom Image

If you have a static image (PNG/JPG):

### Step 1: Add Image to Assets

1. **Open Assets.xcassets** in Xcode
2. **Right-click** in the assets panel
3. **Select** "New Image Set"
4. **Name it** "LaunchImage" (or any name)
5. **Drag your image** into the 1x, 2x, or 3x slots
   - 1x: iPhone standard resolution
   - 2x: Retina displays
   - 3x: iPhone Plus/Pro Max displays

### Step 2: Create Launch Screen Storyboard

1. **File** → **New** → **File**
2. **Select** "Launch Screen" (under User Interface)
3. **Name it** "LaunchScreen"
4. **Click** "Create"

### Step 3: Design the Launch Screen

In the storyboard:

1. **Add UIImageView** to the view controller
2. **Set the image** to your launch image
3. **Set constraints:**
   - Leading: 0
   - Trailing: 0
   - Top: 0
   - Bottom: 0
4. **Content Mode:** Aspect Fill or Aspect Fit

### Step 4: Configure in Project Settings

Same as Method 1, Step 2.

---

## Recommended Approach for RealLifeHQ

Since you've already created a launch screen, I recommend **Method 1** (Launch Screen Storyboard):

### Quick Setup:

1. **Add your `.storyboard` file** to the project
2. **Project Settings** → **General** → **Launch Screen File** → Select your file
3. **Clean build folder** (Shift+Cmd+K)
4. **Delete app** from simulator/device
5. **Run app** (Cmd+R)

---

## Common Issues & Solutions

### Issue 1: Launch Screen Not Showing

**Solution:**
1. Delete app from simulator/device completely
2. Clean build folder (Shift+Cmd+K)
3. Restart Xcode
4. Rebuild and run

**Why:** iOS caches launch screens aggressively

### Issue 2: Old Launch Screen Showing

**Solution:**
1. Delete app from device
2. Reset simulator: Device → Erase All Content and Settings
3. Clean build folder
4. Rebuild

### Issue 3: Launch Screen File Not in Dropdown

**Solution:**
1. Make sure file is added to project
2. Check target membership (File Inspector → Target Membership)
3. Verify file type is `.storyboard`

### Issue 4: Black Screen Instead of Launch Screen

**Solution:**
1. Check Info.plist has correct launch screen entry
2. Verify Launch Screen File name is correct
3. Try Method 2 (SwiftUI) if storyboard issues persist

---

## Launch Screen Design Guidelines

### Apple's Requirements:

✅ **Do:**
- Use simple, static design
- Match app's design language
- Use your app icon or logo
- Keep it minimal
- Test on all device sizes

❌ **Don't:**
- Add animations (not supported in storyboard)
- Include text that needs localization (unless translated)
- Show splash screens with "Loading..." (bad UX)
- Make it too complex
- Use as advertising

### Recommended Elements:

1. **App Icon or Logo** (centered)
2. **App Name** (optional, below logo)
3. **Simple Background Color** (matching your theme)
4. **Minimal Design** (appears for < 1 second)

### Size Recommendations:

- **Simple is better** - shows for < 1 second
- **Use vector graphics** when possible
- **Test on all devices** (iPhone, iPad if supported)

---

## Code Implementation Example

If you want to create a custom launch screen programmatically:

### Create LaunchScreenView.swift:

```swift
import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.3),
                    themeManager.currentTheme.accentColor.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon/Logo
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(themeManager.currentTheme.primaryColor)
                
                // App Name
                Text("RealLifeHQ")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                // Tagline
                Text("Organize Your Life")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // Loading indicator (optional)
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
        .environmentObject(ThemeManager())
}
```

### Update Your App File:

Find your `@main` app struct (usually in a file like `RealLifeHQApp.swift`):

```swift
import SwiftUI

@main
struct RealLifeHQApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var themeManager = ThemeManager()
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app content
                ContentView()
                    .environmentObject(dataManager)
                    .environmentObject(themeManager)
                
                // Launch screen overlay
                if showLaunchScreen {
                    LaunchScreenView()
                        .environmentObject(themeManager)
                        .transition(.opacity)
                        .zIndex(2) // Above everything
                }
            }
            .onAppear {
                // Perform any initialization
                Task {
                    // Load products for StoreKit
                    await StoreManager.shared.loadProducts()
                    
                    // Hide launch screen after 1.5 seconds
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
```

---

## Testing Your Launch Screen

### Test on Simulator:
1. Build and run (Cmd+R)
2. Force quit and relaunch
3. Watch for launch screen

### Test on Device:
1. Install via Xcode
2. Force quit app
3. Tap app icon
4. Launch screen should appear

### Test Different Devices:
- iPhone SE (small screen)
- iPhone 15 Pro (standard)
- iPhone 15 Pro Max (large)
- iPad (if universal app)

---

## Info.plist Configuration

If your launch screen isn't showing, check your `Info.plist`:

```xml
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

Or add via Project Settings → Info → Custom iOS Target Properties

---

## Quick Decision Guide

**Choose Method 1 (Storyboard) if:**
- ✅ You already have a `.storyboard` file
- ✅ You want Apple's native approach
- ✅ You want fastest loading time
- ✅ You need maximum compatibility

**Choose Method 2 (SwiftUI) if:**
- ✅ You want to use custom fonts
- ✅ You want theme integration
- ✅ You want to show loading progress
- ✅ You prefer all-SwiftUI codebase

**Choose Method 3 (Image) if:**
- ✅ You have a designed splash image
- ✅ You want pixel-perfect design
- ✅ You don't need dynamic content

---

## Next Steps

1. **Choose your method** (I recommend Method 1 for simplicity)
2. **Add your file** to Xcode
3. **Configure project settings**
4. **Clean and rebuild**
5. **Test on multiple devices**

Let me know which method you'd like to use, and I can provide more specific instructions! 🚀

---

## Need Help?

**If your file is:**
- `.storyboard` → Use Method 1
- `.png` or `.jpg` → Use Method 3
- Want custom SwiftUI → Use Method 2

**Common file names:**
- `LaunchScreen.storyboard`
- `SplashScreen.storyboard`
- `Launch.storyboard`

Which method works best for your launch screen?
