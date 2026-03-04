# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FORME is an iOS research browser application focused on deep, sustained research projects. It helps users manage long-term research workflows with features for saving materials, cross-referencing, built-in analysis models, and indexing systems.

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open iOS/FORME.xcodeproj

# Build from command line
cd iOS && xcodebuild -scheme FORME -configuration Debug build

# Run tests
cd iOS && xcodebuild -scheme FORME -configuration Debug test
```

### Package Management
The project uses Swift Package Manager (SPM). Dependencies are defined in `iOS/Package.swift`:
- Alamofire (5.8.0+): Networking
- SnapKit (5.7.0+): Auto Layout
- Kingfisher (7.10.0+): Image loading
- swift-markdown: Markdown parsing
- RealmSwift (10.50.0+): Local data storage

## Architecture

### App Structure
- **Entry Point**: `AppDelegate.swift` and `SceneDelegate.swift` in `iOS/FORME/FORME/App/`
- **Root Controller**: `MainTabBarController.swift` manages 5-tab navigation
- **Navigation**: Each tab uses `UINavigationController` for hierarchical navigation

### Tab Structure
1. **首页 (Home)**: `HomeViewController.swift` - Dashboard with recent research and quick actions
2. **研究 (Research)**: `ResearchViewController.swift` - Research project management
3. **资料库 (Library)**: `LibraryViewController.swift` - Saved materials management
4. **分析 (Analysis)**: `AnalysisViewController.swift` - AI analysis tools
5. **我的 (Profile)**: `ProfileViewController.swift` - User settings and statistics

### Data Models
Located in `iOS/FORME/FORME/Models/`:
- `Message.swift`: Chat message model for AI interactions
- `Research.swift`: Research project model
- `Material.swift`: Saved content model
- `Insight.swift`: Analysis results model
- `Tag.swift`: Tagging system
- `UserSettings.swift`: User preferences
- `CoreDataStack.swift`: Core Data setup

### View Architecture
- **MVVM Pattern**: Models, Views, and ViewModels separation
- **UIKit-based**: Uses UIKit with programmatic Auto Layout (SnapKit)
- **Markdown Rendering**: Two renderer implementations:
  - WebView-based: `iOS/FORME/FORME/Views/WebViewRenderer/`
  - Native-based: `iOS/FORME/FORME/Views/NativeRenderer/`

### Key Features
1. **Research Workflow**: 5-step process (Boost, Pick Target, Schedule, Work-Feedback-Loop, Output-Feedback-Loop)
2. **Material Management**: Save web content, documents, and notes with tagging
3. **AI Analysis**: Integration with DeepSeek API and local models
4. **Indexing System**: Full-text and semantic search
5. **Agent System**: Personalized research assistance and motivation

### Data Storage Strategy
- **Local-first**: All user data stored locally on device
- **Core Data**: Primary local storage for structured data
- **Realm**: Alternative/experimental storage
- **No server dependency**: Core functionality works offline
- **Optional sync**: Future iCloud or custom server sync planned

### DeepSeek Integration
- API-based deep analysis of research materials
- Text understanding, association discovery, Q&A, insight generation
- User-configured API keys with usage monitoring
- Fallback to local models when API unavailable

## Development Notes

### Code Style
- Chinese comments and UI labels mixed with English code
- Programmatic UI with SnapKit for Auto Layout
- SF Symbols for icons
- System fonts (SF Pro) with custom color scheme (#1A365D primary)

### Testing
- Unit tests in `iOS/FORMETests/`
- Target: `FORMETests` in Xcode project
- Test with `xcodebuild test` or Xcode test navigator

### Recent Changes
Based on git status:
- File reorganization (AppDelegate, SceneDelegate, MainTabBarController moved to `App/` folder)
- New markdown rendering system (NativeRenderer and WebViewRenderer)
- Message model and UI updates
- HomeViewController layout improvements

### Project Configuration
- Minimum iOS 15.0
- Swift 5.9+
- Xcode 15+ required
- SPM dependencies only (no CocoaPods)