# UI Loader System - Usage Guide

## 🎯 How to Use the UI Loader

### Quick Start:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/loader.lua"))()
```

### What You'll See:
1. **Interactive UI Selection Menu**
2. **Performance Metrics** for each UI library  
3. **Auto-detection** of available local files
4. **Smart Loading** with progress indicators

## 🎨 Available UI Libraries:

### 🏆 Rayfield UI (95/100)
- **Features**: Ultra Fast, 60fps Smooth, Minimal Memory
- **Best For**: Maximum performance and responsiveness
- **Load Time**: 0.2-0.5 seconds

### 🎨 UIv2 Library (90/100) 
- **Features**: Modern Design, Smooth Animations, Lightweight
- **Best For**: Aesthetic design with good performance
- **Load Time**: 0.3-0.7 seconds

### 🛡️ OrionLib (80/100)
- **Features**: Most Compatible, Well Documented, Stable
- **Best For**: Stability and compatibility
- **Load Time**: 1.2-2.5 seconds

### 🎯 Kavo UI (88/100)
- **Features**: Minimalist, Clean Design, Good Performance  
- **Best For**: Simple, clean interfaces
- **Load Time**: 0.5-1.0 seconds

## 🔧 How It Works:

1. **Auto-Detection**: Scans for local UI files
2. **User Choice**: Shows interactive selection menu
3. **Smart Loading**: Downloads if needed, uses cache if available
4. **Preference Memory**: Remembers your choice for next time
5. **Script Launch**: Automatically loads auto-fishing script with chosen UI

## 📁 File Structure:
```
📁 Your Folder/
├── 📄 loader.lua (UI Selector)
├── 📄 auto-fishing.lua (Main Script)
├── 📄 uiv2.lua (Optional)
├── 📄 uiv2-wrapper.lua (Auto-created)
├── 📄 ui.lua (Optional)
└── 📄 ui-preference.txt (Auto-created)
```

## ⚡ Smart Features:

- **🔄 Auto-Resume**: If you chose a UI before, it auto-loads
- **📱 Responsive Design**: Works on any screen size
- **🎭 Hover Effects**: Beautiful animations and feedback
- **⚠️ Error Handling**: Fallbacks if downloads fail
- **💾 Caching**: Saves downloaded UIs for faster loading

## 🚀 Performance Comparison:

| UI Library | Load Time | Memory | Responsiveness | Overall |
|------------|-----------|--------|----------------|---------|
| Rayfield   | 0.2s     | 95/100 | 96/100        | 95/100  |
| UIv2       | 0.3s     | 95/100 | 90/100        | 90/100  |
| Kavo       | 0.5s     | 92/100 | 88/100        | 88/100  |
| OrionLib   | 1.2s     | 75/100 | 85/100        | 80/100  |
