#!/bin/bash

# Build Error Fix Script
# This script helps identify and optionally remove duplicate files causing build errors

echo "🔍 Checking for duplicate files..."
echo ""

# Find duplicate Swift files
echo "Duplicate Swift files found:"
duplicates=$(find . -name "*2.swift" -o -name "* 2.swift")
if [ -z "$duplicates" ]; then
    echo "  ✅ No duplicate Swift files found"
else
    echo "$duplicates"
fi

echo ""

# Find duplicate documentation files
echo "Duplicate documentation files found:"
dup_docs=$(find . -name "*2.md" -o -name "* 2.md")
if [ -z "$dup_docs" ]; then
    echo "  ✅ No duplicate documentation files found"
else
    echo "$dup_docs"
fi

echo ""
echo "───────────────────────────────────────"
echo ""

# Check for old AI implementation
if [ -f "./AIRecipeViews.swift" ]; then
    echo "⚠️  Old AI implementation found: AIRecipeViews.swift"
    echo "   This may conflict with new AI views"
fi

echo ""
echo "📋 Files to delete to fix build errors:"
echo ""

# List files that should be deleted
if [ -f "./AISettingsView 2.swift" ]; then
    echo "  ❌ AISettingsView 2.swift (duplicate)"
fi

if [ -f "./AIRecipeViews.swift" ]; then
    echo "  ❌ AIRecipeViews.swift (old implementation)"
fi

if [ -f "./AI_INTEGRATION_GUIDE 2.md" ]; then
    echo "  📄 AI_INTEGRATION_GUIDE 2.md (duplicate doc)"
fi

echo ""
echo "───────────────────────────────────────"
echo ""
echo "Would you like to delete these files? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "🗑️  Deleting duplicate files..."
    
    # Delete duplicate AISettingsView
    if [ -f "./AISettingsView 2.swift" ]; then
        rm "./AISettingsView 2.swift"
        echo "  ✅ Deleted: AISettingsView 2.swift"
    fi
    
    # Delete old AI implementation
    if [ -f "./AIRecipeViews.swift" ]; then
        rm "./AIRecipeViews.swift"
        echo "  ✅ Deleted: AIRecipeViews.swift"
    fi
    
    # Delete duplicate documentation
    if [ -f "./AI_INTEGRATION_GUIDE 2.md" ]; then
        rm "./AI_INTEGRATION_GUIDE 2.md"
        echo "  ✅ Deleted: AI_INTEGRATION_GUIDE 2.md"
    fi
    
    # Delete any other duplicates
    find . -name "*2.swift" -delete 2>/dev/null
    find . -name "* 2.swift" -delete 2>/dev/null
    
    echo ""
    echo "✅ Cleanup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode"
    echo "2. Clean Build Folder (⇧⌘K)"
    echo "3. Build (⌘B)"
    echo ""
else
    echo ""
    echo "❌ Cancelled - no files deleted"
    echo ""
    echo "To delete manually in Xcode:"
    echo "1. Find the duplicate files in Project Navigator"
    echo "2. Right-click → Delete"
    echo "3. Choose 'Move to Trash'"
    echo "4. Clean Build Folder (Product → Clean Build Folder)"
    echo "5. Build again"
    echo ""
fi

echo "📖 For more details, see BUILD_FIXES.md"
