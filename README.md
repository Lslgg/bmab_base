# Rhythm Chess (节奏象棋)

A revolutionary 3D rhythm-based chess game that combines traditional Chinese chess with music synchronization, featuring innovative delay standardization architecture and predictive timing systems.

## 🎵 Core Innovation

**Revolutionary Delay Standardization**: Instead of minimizing audio latency, Rhythm Chess standardizes all latency to a consistent 50ms target across all platforms, providing a predictable and consistent timing experience.

**Time Prophet Architecture**: Predictive timeline generation replaces reactive beat detection, enabling smooth gameplay even when audio analysis fails.

**Human-Machine Collaboration**: Users participate in calibration to create personalized timing profiles, making the system adaptive to individual rhythm perception.

## 🚀 Features

- **3D Multi-Layer Chess Board**: Three-dimensional chess with sky, standard, and ground layers
- **Beat Synchronization**: All piece movements must align with music beats (±120ms tolerance)
- **Color Matching System**: Real-time color generation based on audio spectrum analysis
- **Skill & Energy System**: Rhythm accuracy affects special piece abilities
- **Multi-Difficulty AI**: 5 difficulty levels with beat synchronization capabilities
- **Cross-Platform**: Windows, macOS, and Linux support

## 🏗️ Architecture

### Layered Architecture Design

```
rhythm_chess/
├── autoload/                  # Global singletons
│   ├── event_bus.gd          # EventBus communication system
│   ├── game_manager.gd       # Core game state management
│   ├── audio_manager.gd      # Audio system coordination
│   └── settings_manager.gd   # Configuration management
├── scripts/
│   ├── timing_core/          # Time synchronization layer
│   ├── game_core/           # Game logic layer
│   ├── rendering/           # 3D rendering layer
│   └── user_experience/     # UI and accessibility
├── scenes/                  # Godot scene files
├── assets/                  # Game resources
└── testing/                 # Test infrastructure
```

### Core Components

- **LatencyNormalizer**: Implements delay standardization (50ms target)
- **EventBus**: Unified communication system for all components
- **AudioManager**: Coordinates audio processing and spectrum analysis
- **GameManager**: Handles game state and performance monitoring
- **SettingsManager**: Manages configuration and user preferences

## 🛠️ Technical Requirements

### Mandatory Technical Stack
- **Game Engine**: Godot 4.x (latest stable)
- **Renderer**: Forward+ (required for 3D effects)
- **Audio Configuration**: 512 sample buffer, 44.1kHz sample rate
- **Programming**: GDScript primary, C# optional for performance-critical parts

### System Requirements
- **OS**: Windows 10+, macOS 10.14+, Ubuntu 18.04+
- **GPU**: GTX 960/RX 570 or equivalent (DirectX 11/12, Metal, Vulkan)
- **RAM**: 2GB minimum
- **Audio**: Standard sound card with DirectSound support

## 🎯 Performance Targets

- **Frame Rate**: Stable 60 FPS
- **Audio Latency**: <20ms (standardized to 50ms)
- **Memory Usage**: <2GB RAM
- **Beat Detection**: >95% accuracy
- **Cross-Platform**: >99% compatibility

## 🧪 Testing

### Running Tests

The project includes comprehensive testing infrastructure:

```bash
# Run all tests (when Godot is available in PATH)
godot --headless --script testing/test_scene.gd

# Or run individual test components
godot --headless --script testing/test_runner.gd
```

### Test Categories

- **Project Structure**: Validates folder organization and file existence
- **Autoload Systems**: Tests singleton initialization and communication
- **Audio System**: Validates audio processing and latency management
- **Data Models**: Tests core data structures and serialization
- **Event System**: Validates EventBus communication patterns

## 🎮 Development Setup

### Prerequisites

1. **Godot 4.x**: Download from [godotengine.org](https://godotengine.org/)
2. **Git**: For version control
3. **Audio Device**: For testing rhythm synchronization

### Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd rhythm_chess
   ```

2. Open in Godot:
   - Launch Godot 4.x
   - Click "Import" and select the project.godot file
   - Configure Forward+ renderer if prompted

3. Run the project:
   - Press F5 or click the play button
   - Select the main scene when prompted

### Development Workflow

1. **Architecture Compliance**: Follow the layered architecture patterns
2. **EventBus Communication**: Use EventBus for all inter-component communication
3. **Naming Conventions**: PascalCase classes, snake_case files/variables
4. **Testing**: Write tests for new components using the testing framework
5. **Documentation**: Update README and code comments for new features

## 🎨 Audio System

### Revolutionary Delay Standardization

Instead of trying to minimize audio latency, Rhythm Chess standardizes all latency to 50ms:

- **Consistent Experience**: Same timing feel across all hardware
- **Predictable Behavior**: Eliminates platform-specific timing variations
- **User Calibration**: Personal timing adjustments for individual preferences
- **Graceful Degradation**: Visual metronome backup when audio fails

### Audio Configuration

- **Buffer Size**: 512 samples (balance of latency vs stability)
- **Sample Rate**: 44.1kHz (standard for rhythm games)
- **FFT Size**: 1024 (compromise between latency and accuracy)
- **Spectrum Analysis**: Real-time frequency analysis for color matching

## 🎯 Game Design

### Chess Rules
- Traditional Chinese chess rules with 3D layer extensions
- 14 piece types with unique movement patterns
- Vertical movement between layers
- Inter-layer attack capabilities

### Rhythm Mechanics
- Beat synchronization window: ±120ms tolerance
- Color matching based on audio spectrum (Low→Red, Mid→Green, High→Blue)
- Energy accumulation through rhythm accuracy
- Special skills activated by precise timing

## 📊 Project Status

**Current Phase**: Foundation Setup (Story 1.1)
- ✅ Project structure created
- ✅ Core autoload systems implemented
- ✅ EventBus communication established
- ✅ Audio system foundation ready
- ✅ Testing infrastructure in place
- ✅ Documentation completed

**Next Steps**: Chess engine implementation, 3D board rendering, basic UI framework

## 🤝 Contributing

This project follows the Ultimate BMad Method development workflow:

1. **Story-Driven Development**: All work organized into user stories
2. **Test-Driven Implementation**: Red-Green-Refactor cycle
3. **Architecture Compliance**: Strict adherence to layered design
4. **Code Review**: Peer review using different LLM contexts

## 📄 License

[License information to be added]

## 🙏 Acknowledgments

- **Godot Engine**: Open-source game engine
- **BMad Method**: Development methodology and workflow
- **Traditional Chinese Chess**: Cultural heritage and game rules
- **Rhythm Game Community**: Inspiration for timing mechanics

---

**Project**: bmab_base  
**Author**: sanan  
**Date**: 2025-12-16  
**Version**: 1.0.0-alpha
