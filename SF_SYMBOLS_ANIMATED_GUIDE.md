# SF Symbols Animated Greeting Guide

## ✅ Current Setup - Pulse Animation

Your home screen now uses animated SF Symbols that change based on time of day!

### 🎨 What You Get:

**Morning (12am - 12pm):**
- Icon: `sun.max.fill` ☀️
- Color: Orange gradient
- Animation: Gentle pulse

**Afternoon (12pm - 5pm):**
- Icon: `cloud.sun.fill` ☁️☀️
- Color: Blue gradient
- Animation: Gentle pulse

**Evening (5pm - 12am):**
- Icon: `moon.stars.fill` 🌙✨
- Color: Purple gradient
- Animation: Gentle pulse

### ✨ Features:

- ✅ No custom images needed - uses Apple's SF Symbols
- ✅ Gradient backgrounds that match time of day
- ✅ Smooth pulse animation (1.5 second cycle)
- ✅ Subtle shadow effects
- ✅ Automatic color scheme
- ✅ Starts animating when view appears

## 🎭 Animation Options

Want different animations? Here are some alternatives:

### Option 1: Bounce Animation (Current - Pulse)
```swift
.scaleEffect(isAnimating ? 1.1 : 1.0)
.animation(
    .easeInOut(duration: 1.5)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 2: Rotate Animation (Spinning)
```swift
.rotationEffect(.degrees(isAnimating ? 360 : 0))
.animation(
    .linear(duration: 20)
        .repeatForever(autoreverses: false),
    value: isAnimating
)
```
*Great for sun icon!*

### Option 3: Fade In/Out (Breathing)
```swift
.opacity(isAnimating ? 1.0 : 0.6)
.animation(
    .easeInOut(duration: 2)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 4: Shake Animation (Attention-Grabbing)
```swift
.offset(x: isAnimating ? 2 : -2)
.animation(
    .easeInOut(duration: 0.1)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 5: Float Up and Down
```swift
.offset(y: isAnimating ? -5 : 5)
.animation(
    .easeInOut(duration: 2)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 6: Combined Effect (Scale + Opacity)
```swift
.scaleEffect(isAnimating ? 1.15 : 1.0)
.opacity(isAnimating ? 1.0 : 0.7)
.animation(
    .easeInOut(duration: 1.5)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 7: Spring Animation (Bouncy)
```swift
.scaleEffect(isAnimating ? 1.1 : 1.0)
.animation(
    .spring(response: 0.6, dampingFraction: 0.3, blendDuration: 0)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

### Option 8: One-Time Welcome Animation
```swift
// Only animates once when user first opens app
.scaleEffect(isAnimating ? 1.0 : 0.5)
.opacity(isAnimating ? 1.0 : 0.0)
.animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimating)
.onAppear {
    withAnimation {
        isAnimating = true
    }
}
```

## 🎨 Customizing SF Symbol Icons

Want different icons? Here are great alternatives:

### Morning Options:
```swift
case 0..<12: 
    return "sun.max.fill"           // Current - bright sun
    // Or try:
    // return "sunrise.fill"         // Sunrise
    // return "sun.horizon.fill"     // Sun on horizon
    // return "sun.and.horizon.fill" // Sun with horizon
    // return "mug.fill"             // Coffee mug
```

### Afternoon Options:
```swift
case 12..<17:
    return "cloud.sun.fill"         // Current - sun with cloud
    // Or try:
    // return "sun.dust.fill"        // Sun with rays
    // return "sun.haze.fill"        // Hazy sun
    // return "sun.max.fill"         // Bright sun
    // return "sun.rain.fill"        // Sun and rain
```

### Evening Options:
```swift
default:
    return "moon.stars.fill"        // Current - moon with stars
    // Or try:
    // return "moon.fill"            // Simple moon
    // return "moon.zzz.fill"        // Moon with zzz
    // return "sparkles"             // Sparkles
    // return "sunset.fill"          // Sunset
    // return "moon.circle.fill"     // Moon in circle
```

## 🌈 Customizing Colors

### Current Color Scheme:
```swift
case 0..<12: return .orange  // Warm morning
case 12..<17: return .blue   // Cool afternoon
default: return .purple      // Evening/night
```

### Alternative Color Schemes:

**Warm Theme:**
```swift
case 0..<12: return .yellow      // Bright morning
case 12..<17: return .orange     // Warm afternoon
default: return .red             // Sunset evening
```

**Cool Theme:**
```swift
case 0..<12: return .cyan        // Fresh morning
case 12..<17: return .blue       // Calm afternoon
default: return .indigo          // Night sky
```

**Nature Theme:**
```swift
case 0..<12: return .yellow      // Sunrise
case 12..<17: return .green      // Daytime
default: return .purple          // Twilight
```

**Match App Theme:**
```swift
// Use your app's theme colors instead
case 0..<12: return themeManager.currentTheme.primaryColor
case 12..<17: return themeManager.currentTheme.accentColor
default: return themeManager.currentTheme.primaryColor.opacity(0.8)
```

## 🎬 Advanced Animations

### Combination Animation Example:

Replace the greeting header with this for a more complex effect:

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
        
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    greetingColor.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0 : 1)
                .animation(
                    .easeOut(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Main icon circle
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
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    greetingColor,
                                    greetingColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .rotationEffect(.degrees(isAnimating ? 5 : -5))
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                )
                .shadow(color: greetingColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
```

This creates:
- A pulsing glow ring that expands outward
- Icon that scales and gently rotates
- Multiple gradient effects

### Particle Effect (Advanced):

For a really fancy effect, you can add floating particles:

```swift
// Add to HomeView state variables
@State private var particles: [Particle] = []

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

// In greetingHeader
ZStack {
    // Existing icon code...
    
    // Add particles
    ForEach(particles) { particle in
        Circle()
            .fill(greetingColor.opacity(particle.opacity))
            .frame(width: 4, height: 4)
            .offset(x: particle.x, y: particle.y)
    }
}
.onAppear {
    createParticles()
}

private func createParticles() {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
        let particle = Particle(
            x: CGFloat.random(in: -30...30),
            y: CGFloat.random(in: -30...30),
            opacity: Double.random(in: 0.3...0.8)
        )
        particles.append(particle)
        
        // Remove old particles
        if particles.count > 10 {
            particles.removeFirst()
        }
    }
}
```

## 🎯 Animation Speed Control

Adjust animation speeds to match your preference:

**Slow and Relaxed:**
```swift
.animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
```

**Medium (Current):**
```swift
.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
```

**Fast and Energetic:**
```swift
.animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
```

**Random/Playful:**
```swift
.animation(
    .easeInOut(duration: Double.random(in: 1...2))
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

## 🌙 Time-Based Animation Variations

Make animations match the mood of the time of day:

```swift
private var animationDuration: Double {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<12: return 1.0    // Morning - energetic
    case 12..<17: return 1.5   // Afternoon - moderate
    default: return 2.5        // Evening - slow & calm
    }
}

// Then use it:
.animation(
    .easeInOut(duration: animationDuration)
        .repeatForever(autoreverses: true),
    value: isAnimating
)
```

## 🎨 Creating Custom SF Symbol Variants

You can also create multicolor variants:

```swift
Image(systemName: greetingSFSymbol)
    .font(.system(size: 32))
    .symbolRenderingMode(.multicolor)  // Use SF Symbol's built-in colors
    .foregroundColor(greetingColor)
```

Or hierarchical (layers of opacity):

```swift
Image(systemName: greetingSFSymbol)
    .font(.system(size: 32))
    .symbolRenderingMode(.hierarchical)
    .foregroundColor(greetingColor)
```

Or palette (custom colors for each layer):

```swift
Image(systemName: greetingSFSymbol)
    .font(.system(size: 32))
    .symbolRenderingMode(.palette)
    .foregroundStyle(greetingColor, greetingColor.opacity(0.5))
```

## 🔧 Performance Tips

Animations can impact battery life. Here are optimization tips:

### Stop Animation When App Backgrounds:
```swift
@Environment(\.scenePhase) var scenePhase

// In body
.onChange(of: scenePhase) { oldPhase, newPhase in
    if newPhase == .active {
        isAnimating = true
    } else {
        isAnimating = false
    }
}
```

### Only Animate on First Launch:
```swift
@State private var hasAnimated = false

.onAppear {
    if !hasAnimated {
        isAnimating = true
        hasAnimated = true
    }
}
```

### Use Reduced Motion Accessibility:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In animation
.animation(
    reduceMotion ? .none : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
    value: isAnimating
)
```

## 📋 Quick Reference

**Current Implementation:**
- ✅ SF Symbols (sun, cloud, moon)
- ✅ Time-based colors (orange, blue, purple)
- ✅ Pulse animation (1.5s cycle)
- ✅ Gradient backgrounds
- ✅ Shadow effects
- ✅ Auto-starts on appear

**To Change Animation:**
Replace the `.animation()` modifier in ContentView.swift

**To Change Icons:**
Update `greetingSFSymbol` switch statement

**To Change Colors:**
Update `greetingColor` switch statement

**To Stop Animation:**
Set `isAnimating = false`

## 🎉 Have Fun!

Experiment with different combinations! SF Symbols has 5000+ icons to choose from. Open the SF Symbols app (comes with Xcode) to browse all available icons.

**Pro Tip:** Search for these categories in SF Symbols app:
- Weather: cloud, sun, moon, snowflake, etc.
- Time: clock, timer, alarm
- Nature: leaf, tree, water.drops
- Celebration: sparkles, party.popper, balloon

---

**Note:** All animations respect system accessibility settings for reduced motion automatically when using SwiftUI's animation modifiers.
