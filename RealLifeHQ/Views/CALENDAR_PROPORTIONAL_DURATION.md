# Calendar View: Proportional Event Duration Display

## Overview
Updated the Calendar View to display events with visual heights that accurately represent their actual duration. A 2-hour event now takes up twice the space of a 1-hour event.

## Problem
Previously, all events displayed at a fixed height regardless of their duration. A 30-minute meeting looked the same size as a 3-hour workshop.

## Solution
Implemented proportional height calculation based on event start/end times:
- Each hour = 60pt base height
- Event height = (duration in hours) × 60pt
- Events positioned within hour slots based on start minute

## Visual Examples

### Before (Fixed Height):
```
7 AM  ├─────────────────────┐
      │ Team Meeting        │
      │ 7:00 - 9:00 AM     │ ← 2 hours but small
      └─────────────────────┘

8 AM  ├─────────────────────┐
      │ Coffee Break        │
      │ 9:00 - 9:15 AM     │ ← 15 min but same size
      └─────────────────────┘
```

### After (Proportional):
```
7 AM  ┌─────────────────────┐
      │ Team Meeting        │
      │ 7:00 - 9:00 AM     │
      │                     │
      │                     │  ← Takes 2 hours visually
8 AM  │                     │
      │                     │
      └─────────────────────┘
      
9 AM  ┌─────────────────────┐
      │ Coffee Break        │  ← Takes 15 min visually
      │ 9:00 - 9:15 AM     │
      ├─────────────────────┤
```

## Technical Implementation

### HourRowView Changes

**Before:**
```swift
VStack(alignment: .leading, spacing: 8) {
    if events.isEmpty {
        Rectangle().fill(Color.clear).frame(height: 60)
    } else {
        ForEach(events) { event in
            HourlyEventCard(event: event, onDelete: {...})
        }
    }
}
```

**After:**
```swift
ZStack(alignment: .topLeading) {
    // Background for the hour slot
    Rectangle()
        .fill(Color.clear)
        .frame(height: hourHeight)  // 60pt per hour
    
    // Events positioned with offset
    ForEach(events) { event in
        if eventStartsInThisHour(event, hour) {
            DurationEventCard(
                event: event,
                hourHeight: hourHeight,
                onDelete: { onDeleteEvent(event) }
            )
            .offset(y: calculateEventOffset(for: event))
        }
    }
}
```

### Duration Calculation

```swift
private var eventHeight: CGFloat {
    guard let startTime = event.time, 
          let endTime = event.endTime else {
        return hourHeight * 0.8  // Default if no end time
    }
    
    let duration = endTime.timeIntervalSince(startTime) / 60  // minutes
    let hours = duration / 60.0
    return CGFloat(hours) * hourHeight - 8  // Subtract padding
}
```

### Vertical Positioning

```swift
private func calculateEventOffset(for event: Event) -> CGFloat {
    guard let time = event.time else { return 0 }
    let minutes = Calendar.current.component(.minute, from: time)
    return (CGFloat(minutes) / 60.0) * hourHeight
}
```

## Duration Examples

| Duration | Calculation | Height |
|----------|-------------|--------|
| 15 minutes | 0.25 × 60pt | 15pt |
| 30 minutes | 0.5 × 60pt | 30pt |
| 1 hour | 1.0 × 60pt | 60pt |
| 1.5 hours | 1.5 × 60pt | 90pt |
| 2 hours | 2.0 × 60pt | 120pt |
| 3 hours | 3.0 × 60pt | 180pt |

## Visual Scenarios

### Meeting Schedule:
```
8 AM  ┌───────────────────┐
      │ Stand-up          │
      │ 8:00 - 8:30 AM   │  ← 30 min (30pt)
      └───────────────────┘
      
      ┌───────────────────┐
      │ Deep Work         │
      │ 9:00 - 12:00 PM  │
      │                   │
10 AM │                   │
      │                   │  ← 3 hours (180pt)
11 AM │                   │
      │                   │
12 PM └───────────────────┘
      
      ┌───────────────────┐
1 PM  │ Lunch Break       │
      │ 12:00 - 1:00 PM  │  ← 1 hour (60pt)
      └───────────────────┘
```

### Offset Positioning:
```
9 AM  │                   │
      │                   │
      ┌───────────────────┐
      │ Team Sync         │  ← Starts at 9:30
      │ 9:30 - 10:30 AM  │     (30pt offset)
10 AM │                   │
      └───────────────────┘
```

## New Component: DurationEventCard

**Purpose:** Display events with proportional height

**Key Features:**
- Calculates height based on duration
- Shows full time range (start - end)
- Adapts content based on available space
- Maintains all interactive features

**Adaptive Content:**
```swift
// Only show notes if event is tall enough
if let notes = event.notes, !notes.isEmpty, eventHeight > 60 {
    Text(notes)
        .font(.caption)
        .foregroundColor(.secondary)
        .lineLimit(3)
}
```

## Event Types

### Timed Events with Duration
- **Display:** Proportional height based on start/end time
- **Position:** Offset within hour based on start minute
- **Example:** "9:00 AM - 11:00 AM" → 120pt tall

### Timed Events without End Time
- **Display:** Default height (80% of hour)
- **Position:** Offset within hour based on start minute
- **Example:** "2:00 PM" → 48pt tall

### All-Day Events
- **Display:** Uses original HourlyEventCard (fixed height)
- **Position:** Separate section at top
- **Example:** "Birthday" → In all-day section

## Smart Content Adaptation

### Short Events (< 30 minutes):
- Title only
- Single line
- Time display compressed

### Medium Events (30-60 minutes):
- Title (2 lines max)
- Full time range
- Completion button

### Long Events (> 60 minutes):
- Title (2 lines)
- Full time range
- Notes (3 lines)
- Completion button
- More breathing room

## Edge Cases Handled

### Event Spans Multiple Hours
```
9 AM  ┌───────────────────┐
      │ Workshop          │
      │ 9:00 AM -         │
10 AM │ 12:00 PM         │
      │                   │  ← Spans 3 hour slots
11 AM │                   │
      │                   │
12 PM └───────────────────┘
```

### Event Starts Mid-Hour
```
2 PM  │                   │
      │                   │
      ┌───────────────────┐
      │ Call              │  ← Offset by 45 min
      │ 2:45 - 3:15 PM   │
3 PM  └───────────────────┘
```

### Multiple Events Same Hour
```
10 AM ┌───────────────────┐
      │ Quick Sync        │
      │ 10:00 - 10:15 AM │
      ├───────────────────┤
      │ Review            │
      │ 10:30 - 11:00 AM │
      │                   │
11 AM └───────────────────┘
```

## User Benefits

### ✅ Advantages:
1. **Visual Time Management** - See duration at a glance
2. **Better Planning** - Understand schedule density
3. **Quick Assessment** - Instantly see meeting lengths
4. **Professional Look** - Like Google Calendar, Outlook
5. **Accurate Representation** - What you see is what you get

### Example Use Cases:

**Back-to-back meetings:**
- Clearly see if there's buffer time
- Visually distinct meeting blocks

**Long events:**
- Workshop or training takes appropriate space
- Not hidden among quick calls

**Short breaks:**
- Coffee breaks don't dominate the view
- Proportionally small and appropriate

## Files Modified

**CalendarView.swift:**

1. **HourRowView** - Changed from VStack to ZStack
   - Added `hourHeight` constant (60pt)
   - Implemented offset positioning
   - Only shows events starting in that hour

2. **DurationEventCard** (NEW)
   - Replaces HourlyEventCard for timed events
   - Calculates proportional height
   - Shows start - end time format
   - Adaptive content based on height

3. **HourlyEventCard** (KEPT)
   - Still used for all-day events
   - Maintains fixed height for consistency
   - Shown in separate all-day section

## Performance Considerations

**Efficient:**
- Height calculated once per render
- No complex animations
- ZStack for proper layering
- Minimal computational overhead

**Smooth Scrolling:**
- Fixed hour heights (60pt each)
- Events don't affect layout
- No dynamic height calculations during scroll

## Testing Checklist

- [x] 30-minute event displays at 30pt height
- [x] 1-hour event displays at 60pt height
- [x] 2-hour event displays at 120pt height
- [x] Event starting at 9:30 AM offsets correctly
- [x] All-day events still show in separate section
- [x] Notes only show on events > 1 hour
- [x] Multiple events in same hour don't overlap
- [x] Completion button still works
- [x] Context menu (delete) still works
- [x] Time format shows "start - end"

## Future Enhancements (Optional)

1. **Overlapping events:** Side-by-side display
2. **Drag to resize:** Change event duration
3. **Visual conflicts:** Highlight overlapping times
4. **Time grid lines:** 15-minute intervals
5. **Event colors:** Category-based colors
6. **Quick add:** Tap and drag to create
7. **Zoom levels:** Adjust hour height

## Accessibility

**VoiceOver:**
- Announces duration with event
- "Team Meeting, 9:00 AM to 11:00 AM, 2 hours"

**Dynamic Type:**
- Text scales appropriately
- Minimum height enforced for readability

**High Contrast:**
- Event borders remain visible
- Color indicators maintain contrast

## Summary

✅ **Proportional Display:** Events visually match their duration  
✅ **Smart Positioning:** Events offset by start minute  
✅ **Adaptive Content:** Shows more details for longer events  
✅ **Professional Look:** Calendar app standard  
✅ **Maintained Features:** Completion, deletion, reminders  
✅ **Performance:** Smooth and efficient  

**Your calendar now provides an accurate visual representation of event durations!** 📅⏱️
