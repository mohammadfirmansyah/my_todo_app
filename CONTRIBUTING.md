# Contributing to My Todo App

Thank you for your interest in contributing to My Todo App! We welcome contributions from the community and appreciate your effort to make this project better.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. By participating in this project, you agree to:

- Be respectful and considerate in all interactions
- Welcome newcomers and help them get started
- Accept constructive criticism gracefully
- Focus on what is best for the community and the project
- Show empathy towards other community members

## Getting Started

### Prerequisites

Before you begin contributing, make sure you have the following installed:

- **Flutter SDK** (version 3.0.0 or higher)
  - Check your Flutter version: `flutter --version`
  - Update Flutter if needed: `flutter upgrade`
- **Git** (for version control)
  - Check Git installation: `git --version`
- **IDE** - One of the following:
  - Android Studio with Flutter plugin
  - Visual Studio Code with Flutter extension
  - IntelliJ IDEA with Flutter plugin
- **Dart SDK** (comes bundled with Flutter)

### Fork and Clone the Repository

1. **Fork the repository** by clicking the "Fork" button at the top right of the repository page

2. **Clone your forked repository** to your local machine:
   ```bash
   git clone https://github.com/YOUR_USERNAME/my_todo_app.git
   cd my_todo_app
   ```

3. **Add the upstream remote** to keep your fork synchronized:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/my_todo_app.git
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Verify your setup** by running the app:
   ```bash
   flutter run -d chrome
   ```

### Create a Feature Branch

Before making any changes, create a new branch for your feature or bug fix:

```bash
git checkout -b feature/your-feature-name
# or for bug fixes
git checkout -b fix/bug-description
```

**Branch naming conventions:**
- `feature/feature-name` - For new features
- `fix/bug-description` - For bug fixes
- `docs/documentation-update` - For documentation changes
- `refactor/code-improvement` - For code refactoring
- `test/test-addition` - For adding tests

### Make Changes and Test

1. **Make your changes** to the codebase

2. **Test your changes thoroughly** before submitting:
   ```bash
   # Run the app
   flutter run -d chrome

   # Run tests (if available)
   flutter test

   # Check for any analysis issues
   flutter analyze
   ```

3. **Format your code** to follow Dart conventions:
   ```bash
   dart format .
   ```

## Development Guidelines

### Code Style Rules

- **Follow Dart conventions** as outlined in the [Effective Dart](https://dart.dev/guides/language/effective-dart) guide
- **Use meaningful variable and function names** that clearly describe their purpose
- **Keep functions small and focused** - each function should do one thing well
- **Use proper indentation** (2 spaces for Dart/Flutter code)
- **Avoid deeply nested code** - prefer early returns and guard clauses
- **Use const constructors** where possible for better performance

### Comment Style

All code comments must be written in **English** with a tutorial-style approach:

- **Educational approach**: Explain concepts clearly and scientifically
- **Clarity**: Describe the purpose and benefits of each code section
- **Brevity**: Keep comments concise - avoid over-explaining obvious code
- **Language**: Always use English for comments

**Example of good comments:**

```dart
// Initialize the todo list from local storage
// This ensures todos persist across app restarts
void _loadTodos() async {
  final prefs = await SharedPreferences.getInstance();
  final todosJson = prefs.getStringList('todos') ?? [];

  // Parse JSON strings back into Todo objects
  setState(() {
    _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
  });
}
```

### Testing Requirements

- **Test your changes** before submitting a Pull Request
- **Verify the app works** on at least one platform (web, mobile, or desktop)
- **Check for console errors** during runtime
- **Test edge cases** - empty states, invalid input, network errors, etc.
- **Ensure existing features** still work after your changes

### Breaking Changes

- **Do not introduce breaking changes** without prior discussion
- If a breaking change is necessary:
  - Open an issue first to discuss the change
  - Document the breaking change clearly in your PR
  - Provide migration instructions if applicable

## Submitting Changes

### Git Workflow

1. **Stage your changes:**
   ```bash
   git add .
   ```

2. **Commit your changes** with a clear, descriptive message:
   ```bash
   git commit -m "feat: add dark mode support"
   # or
   git commit -m "fix: resolve todo deletion bug"
   ```

   **Commit message format:**
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `style:` - Code formatting

3. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** on GitHub

### Pull Request Description Template

When creating a Pull Request, please include:

```markdown
## Description
Brief description of what this PR does and why.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related Issues
Fixes #(issue number)

## Changes Made
- List of specific changes made
- Another change
- etc.

## Testing Done
- [ ] Tested on Web
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Desktop (Windows/macOS/Linux)
- [ ] All existing tests pass
- [ ] Added new tests for new features

## Screenshots (if applicable)
Add screenshots or GIFs showing the changes

## Checklist
- [ ] My code follows the project's code style guidelines
- [ ] I have commented my code where necessary
- [ ] I have tested my changes thoroughly
- [ ] My changes do not introduce new warnings or errors
- [ ] I have updated the documentation (if needed)
```

### What to Include in Your PR

- **Clear description** of the problem and solution
- **Reference to related issues** (use "Fixes #123" to auto-close issues)
- **Screenshots or GIFs** for UI changes
- **Test results** showing your changes work correctly
- **Documentation updates** if you changed functionality

## Pull Request Review Process

1. **Submission**: After you submit a PR, it will be reviewed by maintainers
2. **Review timeline**: PRs will be reviewed within **7 days**
3. **Feedback**: Maintainers may request changes or ask questions
4. **Revisions**: Make requested changes and push updates to your branch
5. **Approval**: Once approved, your PR will be merged into the main branch
6. **Recognition**: Your contribution will be acknowledged in release notes

## Questions or Need Help?

If you have questions or need help with your contribution:

- **Open an issue** in the [Issues tab](https://github.com/OWNER/my_todo_app/issues)
- **Describe your question** clearly with relevant context
- **Check existing issues** first to see if your question was already answered

We're here to help and want to make contributing as smooth as possible!

## Thank You!

Thank you for taking the time to contribute to My Todo App! Every contribution, whether it's a bug fix, feature addition, or documentation improvement, helps make this project better for everyone.

We appreciate your effort and look forward to your contributions!

---

**Happy Coding!** 🚀
