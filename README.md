# Việt Wander 🇻🇳

Việt Wander is a modern Flutter desktop application designed to visualize interactive maps and geographic statistics of Vietnam. Beyond being a comprehensive mapping tool for provinces, communes, and administrative committees, Việt Wander integrates an innovative **AI-powered Hand Gesture Control** system using Python and MediaPipe, allowing users to navigate the map without a mouse or keyboard.

## 🌟 Key Features

* **Interactive Map of Vietnam**: Seamlessly explore Vietnam's geography with high-performance rendering.
* **Geographic Statistics**: View detailed data for provinces, communes, and local committees with an interactive sidebar.
* **Smart Search System**: Fast, responsive search for locations with Vietnamese language support (Tiếng Việt).
* **AI Hand Gesture Control**: 
  * Integrated local Python AI server powered by OpenCV & MediaPipe.
  * Real-time WebSocket communication.
  * Control the map using intuitive hand gestures (Pan, Zoom, Switch, Click).
* **Desktop-First Experience**: Optimized for Windows with custom window management, sizing, and styling.
* **Modern UI/UX**: Smooth transitions, Lottie animations, and a polished dark-themed interface built with Riverpod and GoRouter.

## 🏗️ Architecture & Tech Stack

The project is divided into two main components:

### 1. Flutter Client (`viet-wander/`)
* **Framework**: Flutter (Desktop - Windows)
* **State Management**: Riverpod (`flutter_riverpod`)
* **Routing**: GoRouter
* **Map Engine**: `flutter_map` with `latlong2`
* **Networking/Sockets**: `web_socket_channel`, `dio`
* **UI/Animations**: `lottie`, `flutter_svg`, `window_manager`

### 2. Gesture Server (`python_gesture_server/`)
* **Language**: Python 3
* **Computer Vision**: OpenCV (`opencv-python`)
* **Machine Learning**: Google MediaPipe (Hand Landmarker)
* **Communication**: `websockets`, `asyncio`

## 📁 Project Structure

```text
VietWander/
├── python_gesture_server/      # Python AI Hand Tracking Server
│   ├── hand_server.py          # Main server script
│   └── hand_landmarker.task    # MediaPipe AI Model (Auto-downloaded)
│
└── viet-wander/                # Flutter Desktop Application
    ├── assets/                 # GeoJSON data, fonts, Lottie animations, images
    ├── lib/
    │   ├── app/                # App config, routes, styles, themes
    │   ├── data/               # Models, repositories, local data providers
    │   ├── domain/             # Entities (Provinces, Communes, Committees)
    │   └── presentation/       # UI layer (Screens, Widgets, Controllers)
    └── windows/                # Windows native build configuration
```

## 🚀 Getting Started

### Prerequisites

* **Flutter SDK** (`^3.11.5` or compatible stable version)
* **Python** (3.8+ recommended)
* **Visual Studio 2022** (with "Desktop development with C++" workload for Flutter Windows build)

### 1. Setup Python Gesture Server

The Flutter app automatically spawns the Python server, but you need to prepare the Python environment first.

```bash
cd python_gesture_server

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows:
.\venv\Scripts\activate
# On macOS/Linux:
# source venv/bin/activate

# Install required dependencies
pip install opencv-python mediapipe websockets asyncio
```
*(The `hand_landmarker.task` model will be downloaded automatically on first run).*

### 2. Setup Flutter Application

```bash
cd ../viet-wander

# Get Flutter dependencies
flutter pub get

# Run the app (Windows)
flutter run -d windows
```

## ✋ Hand Gesture Controls Guide

When the AI Gesture Mode is activated via the UI, the webcam will turn on. Ensure your hand is clearly visible to the camera.

| Gesture / Hand Pose | Action |
| :--- | :--- |
| **All Fingers Closed (Fist)** | **PAN**: Click and drag the map. |
| **Index & Thumb Open (Pinch)** | **SWITCH/CLICK**: Pinch your index and thumb together to simulate a cursor click or switch mode. |
| **Index & Middle Fingers Open** | **CURSOR**: Move the virtual cursor around the screen. |
| **IDLE (Open Hand)** | **IDLE**: Release dragging or interactions. |

*(Note: The gesture configurations are processed in `hand_server.py` and translated to map actions in `map_gesture_mixin.dart`).*

## 🤝 Contributing
Feel free to open issues or submit pull requests if you want to improve Việt Wander!

## 📜 License
[MIT License](LICENSE) (or specify your license here)

---
*Developed with ❤️ for exploring Vietnam.*