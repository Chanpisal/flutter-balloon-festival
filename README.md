# 🎈 Flutter Balloon Festival Animation

A Flutter animation project demonstrating how to use **AnimationController** and other Flutter animation tools to create an interactive animated scene.

This project was developed based on the **“Using Animation Controller” exercise** and extended with additional visual effects, user interaction, and sound.

---

# 📱 Project Overview

The application displays a **balloon festival scene** with animated balloons floating upward in the sky.  
Each balloon has multiple animation effects such as floating, growing, rotating, and pulsing.

When the balloon reaches the top of the screen, it **bursts and restarts from the bottom**, creating a continuous animation sequence.

The background includes **moving clouds** to add depth and realism.

---

# ✨ Features

- Balloon floating animation
- Balloon rotation animation
- Balloon pulse (breathing) animation
- Balloon burst sequence animation
- Animated cloud background
- Multiple balloons with different behaviors
- User interaction:
  - Tap balloon
  - Drag balloon
  - Pinch to resize
- Sound effects
  - Wind background sound
  - Balloon inflate sound
  - Balloon pop sound

---

# 🧠 Flutter Concepts Used

This project demonstrates several important Flutter concepts:

- `AnimationController`
- `Tween`
- `CurvedAnimation`
- `AnimatedBuilder`
- `GestureDetector`
- `TickerProviderStateMixin`
- `Stack` and `Positioned`
- `MediaQuery`
- `CustomPainter`
- `Transform widgets`
- `AudioPlayer`

These concepts are used to create smooth animations, user interaction, and responsive layouts.

---

# 🗂 Project Structure
lib/
├── main.dart
├── pages/
│ └── home.dart
└── widgets/
└── animated_balloon.dart

**main.dart**  
Entry point of the Flutter application.

**home.dart**  
Creates the main screen layout and loads the balloon scene.

**animated_balloon.dart**  
Contains the animation logic for balloons, background animation, interaction, and sound effects.

---

# ▶️ How to Run the Project

1. Clone the repository
git clone https://github.com/Chanpisal/flutter-balloon-festival.git

2. Navigate to the project folder
cd flutter-balloon-festival

3. Install dependencies
flutter pub get

4. Run the application
flutter run

---

# 👤 Author

Chanpisal

---

# 🔗 GitHub Repository

https://github.com/Chanpisal/flutter-balloon-festival
