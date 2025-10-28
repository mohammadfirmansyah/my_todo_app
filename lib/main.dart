import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material Design 3 color scheme with seed color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Apply rounded corners to cards and buttons
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Backend configuration - easy to change for cloud deployment
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';
  static const Duration requestTimeout = Duration(seconds: 10);

  // State management
  List<Map<String, dynamic>> todos = [];
  bool isLoading = false;
  String? errorMessage;
  bool isSocketConnected = false;

  // Socket.IO client instance for real-time updates
  late io.Socket socket;

  // Text controller for input field
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize Socket.IO connection for real-time sync
    _initializeSocket();
    // Load initial todos from REST API
    fetchTodos();
  }

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    _todoController.dispose();
    // Disconnect socket to prevent memory leaks
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  // Initialize Socket.IO connection with event listeners
  void _initializeSocket() {
    // Configure Socket.IO client with auto-connect and reconnection
    socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .disableAutoConnect() // Manual connection control
          .setReconnectionDelay(1000) // Wait 1s before reconnecting
          .setReconnectionAttempts(5) // Try 5 times before giving up
          .build(),
    );

    // Listen for connection success
    socket.onConnect((_) {
      if (mounted) {
        setState(() {
          isSocketConnected = true;
        });
        debugPrint('Socket.IO: Connected to server');
      }
    });

    // Listen for connection errors
    socket.onConnectError((error) {
      if (mounted) {
        setState(() {
          isSocketConnected = false;
        });
        debugPrint('Socket.IO: Connection error - $error');
      }
    });

    // Listen for disconnection
    socket.onDisconnect((_) {
      if (mounted) {
        setState(() {
          isSocketConnected = false;
        });
        debugPrint('Socket.IO: Disconnected from server');
      }
    });

    // Listen for 'todos-updated' event broadcast from server
    // When any client modifies todos, server broadcasts this event
    // This enables real-time synchronization across all connected clients
    socket.on('todos-updated', (data) {
      debugPrint('Socket.IO: Received todos-updated event');
      if (mounted) {
        // Refresh UI automatically when server broadcasts changes
        fetchTodos();
        _showSnackBar('Todos updated in real-time');
      }
    });

    // Establish connection to server
    socket.connect();
  }

  // Fetch all todos from REST API with timeout handling
  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/todos'))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          todos = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timeout. Please check your connection.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading todos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Add new todo with validation
  // Server will broadcast 'todos-updated' event to all clients after creation
  Future<void> addTodo() async {
    final title = _todoController.text.trim();

    // Input validation - prevent empty todos
    if (title.isEmpty) {
      _showSnackBar('Please enter a todo title', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/todos'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'title': title}),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 201) {
        _todoController.clear();
        _showSnackBar('Todo added successfully');
        // Server broadcasts 'todos-updated', all clients will refresh
        await fetchTodos();
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timeout. Please try again.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error adding todo: ${e.toString()}';
        isLoading = false;
      });
      _showSnackBar('Failed to add todo', isError: true);
    }
  }

  // Toggle todo completion status via PUT endpoint
  // Server will broadcast 'todos-updated' event after update
  Future<void> toggleTodo(int id, bool completed) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .put(
            Uri.parse('$apiBaseUrl/todos/$id'),
            headers: {'Content-Type': 'application/json'},
            // Send opposite of current state to toggle
            body: json.encode({'completed': !completed}),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        _showSnackBar('Todo updated');
        // Server broadcasts 'todos-updated', all clients will refresh
        await fetchTodos();
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timeout. Please try again.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating todo: ${e.toString()}';
        isLoading = false;
      });
      _showSnackBar('Failed to update todo', isError: true);
    }
  }

  // Delete todo with confirmation dialog
  // Server will broadcast 'todos-updated' event after deletion
  Future<void> deleteTodo(int id) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .delete(Uri.parse('$apiBaseUrl/todos/$id'))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        _showSnackBar('Todo deleted');
        // Server broadcasts 'todos-updated', all clients will refresh
        await fetchTodos();
      } else {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timeout. Please try again.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error deleting todo: ${e.toString()}';
        isLoading = false;
      });
      _showSnackBar('Failed to delete todo', isError: true);
    }
  }

  // Show delete confirmation dialog with rounded corners
  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show snackbar notification for user feedback
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        // Modern gradient background using Material Design 3 colors
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.3),
              colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header section with title and task counter
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Todos',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${todos.length} ${todos.length == 1 ? 'task' : 'tasks'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                        // Real-time sync status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSocketConnected
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSocketConnected
                                    ? Icons.sync
                                    : Icons.sync_disabled,
                                size: 14,
                                color: isSocketConnected
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSocketConnected
                                    ? 'Real-time sync enabled'
                                    : 'Reconnecting...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSocketConnected
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error message banner with dismiss button
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade900),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                errorMessage = null;
                              });
                            },
                            color: Colors.red.shade900,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (errorMessage != null) const SizedBox(height: 16),

              // Input field section with Add button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          hintText: 'Add a new todo...',
                          prefixIcon: const Icon(Icons.add_task),
                          suffixIcon: _todoController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _todoController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => setState(() {}),
                        onSubmitted: (value) => addTodo(),
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: isLoading ? null : addTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Todo list section with loading/empty states
              Expanded(
                child: isLoading && todos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading todos...'),
                          ],
                        ),
                      )
                    : todos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 80,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No todos yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first todo to get started',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchTodos,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              itemCount: todos.length,
                              itemBuilder: (context, index) {
                                final todo = todos[index];
                                // Type conversion: API returns int (0/1) or bool
                                // Convert to bool for Checkbox compatibility
                                final isCompleted = todo['completed'] == true ||
                                                   todo['completed'] == 1;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      // Checkbox to toggle completion status
                                      leading: Checkbox(
                                        value: isCompleted,
                                        onChanged: isLoading
                                            ? null
                                            : (value) => toggleTodo(
                                                  todo['id'],
                                                  isCompleted,
                                                ),
                                        shape: const CircleBorder(),
                                      ),
                                      title: Text(
                                        todo['title'] ?? '',
                                        style: TextStyle(
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isCompleted
                                              ? colorScheme.onSurfaceVariant
                                                  .withValues(alpha: 0.6)
                                              : null,
                                        ),
                                      ),
                                      // Delete button with confirmation
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                        onPressed: isLoading
                                            ? null
                                            : () => deleteTodo(todo['id']),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
