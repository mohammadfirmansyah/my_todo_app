# 📝 Flutter Todo App

[![GitHub](https://img.shields.io/badge/GitHub-my__todo__app-blue?logo=github)](https://github.com/username/my_todo_app)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, feature-rich Todo application built with Flutter and Material Design 3. This application demonstrates clean architecture, comprehensive error handling, and responsive design patterns while providing an excellent user experience for managing daily tasks.

## 📚 Documentation

- **[Contributing Guide](CONTRIBUTING.md)** - Learn how to contribute
- **[Build Information](BUILD_INFO.md)** - Build instructions and platform details

## ✨ Key Features

- **Material Design 3**: Modern UI with beautiful animations and transitions
- **Error Handling**: Comprehensive error messages and graceful failure recovery
- **Loading States**: Visual feedback during asynchronous operations
- **Responsive Design**: Adapts seamlessly to different screen sizes and orientations
- **Input Validation**: Smart validation for user inputs with helpful error messages
- **Delete Confirmation**: Modal dialogs to prevent accidental deletions
- **Empty States**: Informative placeholders when no tasks are available
- **User Feedback**: Snackbars and visual indicators for user actions
- **Task Management**: Create, read, update, and delete tasks with ease
- **Clean Architecture**: Well-organized code structure following Flutter best practices

## 📱 App Preview

```
┌─────────────────────────────────┐
│  📝 My Todo App          ⚙️     │
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────────┐ │
│  │ ✓ Complete Flutter tutorial│ │
│  │   Status: Completed         │ │
│  │                      [🗑️]   │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ ○ Build Todo App           │ │
│  │   Status: Pending           │ │
│  │                      [🗑️]   │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ + Add new task...          │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

## 🛠️ Technologies Used

- **Flutter** - v3.9.2+ (Cross-platform UI framework)
- **Dart** - v3.9.2+ (Programming language)
- **Material Design 3** - Modern design system
- **HTTP Package** - v0.13.3+ (REST API communication)
- **Cupertino Icons** - iOS-style icons for cross-platform consistency

## 📂 Project Structure

```
my_todo_app/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── models/
│   │   └── todo.dart          # Todo data model
│   ├── services/
│   │   └── api_service.dart   # API communication layer
│   ├── screens/
│   │   └── todo_screen.dart   # Main todo list screen
│   └── widgets/
│       └── todo_item.dart     # Reusable todo item widget
├── test/                      # Unit and widget tests
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── web/                       # Web platform files
├── pubspec.yaml               # Dependencies and metadata
├── README.md                  # Project documentation
├── CONTRIBUTING.md            # Contribution guidelines
├── BUILD_INFO.md              # Build instructions
└── LICENSE                    # MIT License

```

## 🚀 Setup & Installation

Before you begin, make sure you have the following installed:
- **Flutter SDK** - v3.9.2 or higher
- **Dart SDK** - v3.9.2 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

Follow these steps to get your development environment running:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/username/my_todo_app.git
   cd my_todo_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation:**
   ```bash
   flutter doctor
   ```

4. **Check available devices:**
   ```bash
   flutter devices
   ```

## 💻 Usage / How to Run

1. **Run the app in development mode:**
   ```bash
   # Run on default device
   flutter run

   # Run on specific device
   flutter run -d chrome          # Web browser
   flutter run -d android         # Android emulator
   flutter run -d ios             # iOS simulator (macOS only)
   ```

2. **Run with hot reload enabled:**
   - Press `r` to hot reload
   - Press `R` to hot restart
   - Press `q` to quit

3. **Build for production:**
   ```bash
   # Android APK
   flutter build apk --release

   # iOS app (macOS only)
   flutter build ios --release

   # Web app
   flutter build web --release
   ```

## 📝 Code Highlights

### Material Design 3 Theme
The app uses Material Design 3's color scheme and components for a modern, cohesive look:

```dart
// lib/main.dart

// Configure Material Design 3 theme with custom color scheme
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
),
```

*This ensures consistent styling across all widgets and automatic dark mode support.*

### Error Handling Pattern
Comprehensive error handling provides users with meaningful feedback:

```dart
// lib/services/api_service.dart

// Handle HTTP errors with user-friendly messages
try {
  final response = await http.get(Uri.parse('$baseUrl/todos'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load todos: ${response.statusCode}');
  }
} catch (e) {
  throw Exception('Network error: $e');
}
```

*This pattern catches both HTTP errors and network issues, displaying appropriate messages to users.*

### Card-based UI Design
Each todo item is rendered as a Material Card with elevation and rounded corners:

```dart
// lib/widgets/todo_item.dart

// Create visually appealing card layout for each todo
Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ListTile(
    leading: Checkbox(
      value: todo.completed,
      onChanged: (bool? value) => onToggle(),
    ),
    title: Text(todo.title),
    trailing: IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => onDelete(),
    ),
  ),
)
```

*This creates a clean, touchable interface with clear visual hierarchy.*

## 📖 Learning Outcomes

This project is an excellent resource for learning and practicing:

- ✅ **Flutter Fundamentals**: Widget composition, state management, and lifecycle methods
- ✅ **Material Design 3**: Implementing modern design patterns and theming
- ✅ **Async Programming**: Using `async`/`await` for API calls and data fetching
- ✅ **HTTP Requests**: Making RESTful API calls with the HTTP package
- ✅ **Error Handling**: Implementing try-catch blocks and user-friendly error messages
- ✅ **State Management**: Using `setState()` for local component state
- ✅ **Data Modeling**: Creating Dart classes and JSON serialization
- ✅ **User Feedback**: Displaying loading indicators, snackbars, and dialogs
- ✅ **Responsive Design**: Building UIs that work across different screen sizes
- ✅ **Clean Code**: Following Flutter best practices and code organization

## 🤝 Contributing

We welcome contributions! Please see our **[Contributing Guide](CONTRIBUTING.md)** for more details on how to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the **[LICENSE](LICENSE)** file for details.

## 👨‍💻 Developer

- **Mohammad Firman Syah**
- **Project Link:** [https://github.com/username/my_todo_app](https://github.com/username/my_todo_app)

---

Built with ❤️ using Flutter & Dart

**Note**: For production use, consider implementing state management solutions like Provider, Riverpod, or BLoC for more complex applications, and add comprehensive testing coverage.
