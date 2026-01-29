# Adding PNG Launch Screen - Step by Step Guide

## 🎨 Your PNG Launch Screen Setup

You have a PNG file - great! Here's exactly how to add it to your app.

## 📋 Quick Setup (5-10 Minutes)

### Step 1: Add PNG to Assets (2 minutes)

1. **Open Xcode**
2. **In Project Navigator** (left sidebar), find `Assets.xcassets`
3. **Click on** `Assets.xcassets` to open it
4. **In the assets panel**, right-click in empty space
5. **Select** "New Image Set"
6. **Name it** "LaunchImage" (or "SplashScreen")
7. **Drag your PNG file** into one of the boxes:
   - If image is designed for standard iPhone: Drag to **2x**
   - If image is designed for Plus/Pro Max: Drag to **3x**
   - If unsure: Drag to **Universal** (top box)

**Image Slot Guide:**
- **1x** = 320px wide (older devices)
- **2x** = 640px wide (standard Retina)
- **3x** = 960px wide (Plus/Pro Max)
- **Universal** = Works for all (Xcode scales automatically)

### Step 2: Create Launch Screen Storyboard (3 minutes)

1. **File** → **New** → **File** (or Cmd+N)
2. **Scroll down** to "User Interface" section
3. **Select** "Launch Screen"
4. **Name it** "LaunchScreen" (no extension needed)
5. **Click** "Create"

A new storyboard opens with a blank view controller.

### Step 3: Add Image to Storyboard (3 minutes)

#### In the Storyboard Editor:

1. **Click the "+" button** in top right (or Cmd+Shift+L)
2. **Search for** "Image View"
3. **Drag** Image View onto the view controller
4. **Select the Image View** you just added

#### Configure the Image View:

**In the Attributes Inspector** (right sidebar, first icon):

1. **Image:** Select "LaunchImage" (your image from Assets)
2. **Content Mode:** Choose one:
   - **Aspect Fill** - Fills entire screen (may crop edges)
   - **Aspect Fit** - Shows entire image (may have bars)
   - **Scale to Fill** - Stretches to fit (may distort)

**Recommended:** Aspect Fill for full-screen splash

#### Set Constraints (Important!):

**With Image View selected:**

1. **Click the Align button** (bottom right, looks like |—|)
2. **Check** "Horizontally in Container"
3. **Check** "Vertically in Container"
4. **Click** "Add 2 Constraints"

**Then:**

1. **Click the Pin button** (next to Align, looks like |-|-|)
2. **Add these constraints:**
   - Width: Equal to Superview
   - Height: Equal to Superview
3. **Click** "Add Constraints"

**Alternative Quick Method:**
1. Select Image View
2. Click Pin button
3. **Set all 4 sides to 0** (top, bottom, left, right)
4. Uncheck "Constrain to margins"
5. Click "Add 4 Constraints"

### Step 4: Configure Project Settings (1 minute)

1. **Click your project** in Project Navigator (top item)
2. **Select your app target** from the list
3. **Go to "General" tab**
4. **Scroll to** "App Icons and Launch Screen"
5. **Launch Screen File:** Select "LaunchScreen" from dropdown

### Step 5: Clean and Test (1 minute)

**This is crucial because iOS caches launch screens!**

1. **Clean Build Folder:** Product → Clean Build Folder (Shift+Cmd+K)
2. **Delete app** from simulator/device (long-press, tap X)
3. **Build and Run:** Cmd+R
4. **Force quit** and reopen to see launch screen

**Your PNG launch screen should now appear!** 🎉

---

## 🎨 Image Specifications

### Recommended PNG Dimensions:

**For best results, create images at these sizes:**

#### iPhone Portrait:
- **iPhone 15 Pro Max / Plus:** 1290 x 2796 pixels
- **iPhone 15 Pro / Standard:** 1179 x 2556 pixels
- **iPhone SE:** 750 x 1334 pixels

#### Universal Approach:
- **Safe Area Design:** 1242 x 2688 pixels
- This works well across all devices
- Design important content in center

### Design Tips:

✅ **Do:**
- Use high-resolution PNG (2x or 3x)
- Center important elements
- Use simple design
- Match your app's branding
- Test on multiple device sizes

❌ **Don't:**
- Include text that needs translation
- Make it too busy/complex
- Use low resolution
- Forget safe areas
- Add "Loading..." text (bad UX)

---

## 🐛 Troubleshooting

### Problem 1: Launch Screen Not Showing

**Solution A: Clear Cache**
```
1. Delete app from device/simulator completely
2. Simulator → Device → Erase All Content and Settings
3. Clean Build Folder (Shift+Cmd+K)
4. Quit Xcode completely
5. Reopen Xcode
6. Build and run again
```

**Solution B: Check File**
```
1. Make sure PNG is in Assets.xcassets
2. Image set name matches what you used in storyboard
3. Check storyboard has constraints set
4. Verify Launch Screen File is set in project settings
```

### Problem 2: Image Looks Stretched or Cropped

**Solution:**
1. Select Image View in storyboard
2. Attributes Inspector → Content Mode
3. Try different options:
   - **Aspect Fill:** Full screen, may crop
   - **Aspect Fit:** Shows all, may have bars
4. Adjust constraints if needed

### Problem 3: Old Launch Screen Still Shows

**This is iOS caching!**

**Solution:**
```
1. Delete app
2. Reset simulator content
3. Restart device
4. Wait 10 seconds
5. Rebuild
```

### Problem 4: Image Not Appearing in Storyboard

**Solution:**
```
1. Check image is in Assets.xcassets
2. Image set name is correct
3. Try dragging image directly into storyboard
4. Check file is actually PNG (not renamed JPG)
```

### Problem 5: Black Screen Instead of Launch Screen

**Solution:**
1. Check Info.plist has launch screen entry
2. Project Settings → General → Launch Screen File is set
3. Storyboard is added to app target
4. Image view has proper constraints

---

## 📱 Testing Checklist

Test your launch screen on:

- [ ] iPhone SE (small screen)
- [ ] iPhone 15 Pro (standard)
- [ ] iPhone 15 Pro Max (large)
- [ ] Light mode
- [ ] Dark mode (if your image supports it)
- [ ] Portrait orientation
- [ ] Landscape (if supported)

---

## 🎨 Alternative: If You Want Better Control

If you're having issues with the storyboard approach, I can create a SwiftUI launch screen that uses your PNG:

```swift
struct LaunchScreenView: View {
    var body: some View {
        Image("LaunchImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
```

This gives you more control and avoids storyboard caching issues.

Would you like me to create this version instead?

---

## 📊 Quick Reference

### File Locations:
- **PNG File:** `Assets.xcassets/LaunchImage.imageset/`
- **Storyboard:** `LaunchScreen.storyboard`
- **Config:** Project Settings → General → Launch Screen File

### Common Mistakes:
1. ❌ Forgetting to delete app before testing
2. ❌ Not setting constraints on image view
3. ❌ Wrong image set name
4. ❌ Not cleaning build folder

### Success Checklist:
- [x] PNG added to Assets.xcassets
- [x] Named "LaunchImage" (or remember name)
- [x] LaunchScreen.storyboard created
- [x] Image View added to storyboard
- [x] Image set to "LaunchImage"
- [x] Constraints added (all 4 edges or center + size)
- [x] Project Settings → Launch Screen File → "LaunchScreen"
- [x] Clean build folder
- [x] Delete app
- [x] Rebuild and test

---

## 🎯 Visual Guide

### Xcode Layout When Done:

```
Project Navigator          Storyboard                Right Panel
├── RealLifeHQ            ┌────────────────┐        Attributes Inspector
├── Assets.xcassets       │                │        ├── Image: LaunchImage
│   └── LaunchImage       │  [Your PNG]    │        ├── Content Mode: Aspect Fill
├── LaunchScreen.storyboard│               │        └── Constraints: 0,0,0,0
├── ContentView.swift     │                │
└── ...                   └────────────────┘
```

---

## ⚡ Super Quick Version (If You're in a Hurry)

1. Drag PNG into `Assets.xcassets` → Name it "LaunchImage"
2. File → New → Launch Screen → Name "LaunchScreen"
3. Add Image View to storyboard → Set image to "LaunchImage"
4. Pin all 4 edges to 0
5. Project Settings → General → Launch Screen File → "LaunchScreen"
6. Clean (Shift+Cmd+K), delete app, run (Cmd+R)

Done! 🎉

---

## 🆘 Still Having Issues?

If you're stuck, I can:

1. **Create a SwiftUI version** - Uses your PNG programmatically
2. **Help troubleshoot** - Walk through each step
3. **Alternative approach** - Use different method

Just let me know your PNG filename and any error messages you see!

---

## 💡 Pro Tip

**For iOS 14+**, you can also use just the PNG without a storyboard by configuring in Info.plist, but the storyboard method is more reliable and gives you more design control.

---

**You're almost done!** Follow Steps 1-5, and your PNG launch screen will be ready. Most common issue is forgetting to delete the app before testing. 🚀

Let me know if you hit any snags!
