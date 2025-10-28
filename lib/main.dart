// main.dart - Complete Todo Application with Real-time Sync
// This is a feature-complete CRUD application with Socket.IO real-time synchronization
// Feature parity with myTodoApp (React Native version)

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

// Model class for Todo items
// Provides type safety and JSON serialization
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  // Factory constructor to create Todo from JSON response
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  // Convert Todo to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }
}

// Main Todo List Screen with full CRUD and real-time sync
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Server Configuration State
  bool _useLocalServer = false;
  String _customServerUrl = 'https://todolist.220fii1j0spm.us-south.codeengine.appdomain.cloud';
  final String _localServerUrl = 'http://localhost:3000';
  bool _showSettings = false;

  // Todo List State
  List<Todo> _todos = [];
  final TextEditingController _newTodoController = TextEditingController();
  final TextEditingController _customServerController = TextEditingController();

  // Connection State
  io.Socket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;
  String? _connectionError;

  // Debug Logs State
  final List<String> _debugLogs = [];
  bool _showDebug = false;

  // Derived values based on current configuration
  String get _apiUrl => _useLocalServer
      ? '$_localServerUrl/todos'
      : '$_customServerUrl/todos';

  String get _socketUrl => _useLocalServer
      ? _localServerUrl
      : _customServerUrl;

  String get _environmentName => _useLocalServer
      ? 'Local Server'
      : 'Remote Server';

  @override
  void initState() {
    super.initState();
    _customServerController.text = _customServerUrl;
    _initializeConnection();
  }

  @override
  void dispose() {
    // Cleanup: disconnect socket and dispose controllers
    _addDebugLog('Cleaning up resources', 'system');
    _socket?.disconnect();
    _socket?.dispose();
    _newTodoController.dispose();
    _customServerController.dispose();
    super.dispose();
  }

  // Add debug log entry with timestamp and type
  void _addDebugLog(String message, String type) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    final logEntry = '[$timestamp] ${type.toUpperCase()}: $message';

    // Print to console for debugging
    debugPrint(logEntry);

    setState(() {
      // Keep last 50 logs
      if (_debugLogs.length >= 50) {
        _debugLogs.removeAt(0);
      }
      _debugLogs.add(logEntry);
    });
  }

  // Get color for log type
  Color _getLogColor(String log) {
    if (log.contains('ERROR:')) return const Color(0xFFf44336);
    if (log.contains('WARN:')) return const Color(0xFFff9800);
    if (log.contains('API:')) return const Color(0xFF2196F3);
    if (log.contains('SOCKET:')) return const Color(0xFF4caf50);
    if (log.contains('CONFIG:')) return const Color(0xFF9c27b0);
    if (log.contains('DATA:')) return const Color(0xFF00bcd4);
    if (log.contains('FALLBACK:')) return const Color(0xFFff5722);
    return const Color(0xFF333333);
  }

  // Initialize or reinitialize connection when server changes
  void _initializeConnection() {
    _addDebugLog('Configuration changed - Server: ${_useLocalServer ? 'Local' : 'Remote'}', 'config');
    _addDebugLog('API URL: $_apiUrl', 'config');
    _addDebugLog('Socket URL: $_socketUrl', 'config');

    // Disconnect existing socket if any
    if (_socket != null) {
      _addDebugLog('Disconnecting previous socket connection', 'socket');
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      setState(() {
        _isConnected = false;
      });
    }

    // Reset state when switching servers
    setState(() {
      _connectionError = null;
      _todos = [];
    });

    // Fetch initial todos
    _fetchTodos();

    // Establish WebSocket connection for real-time updates
    _addDebugLog('Creating socket connection to $_socketUrl', 'socket');

    // Configure socket based on server type
    final config = io.OptionBuilder()
        .setTransports(_useLocalServer ? ['websocket', 'polling'] : ['polling'])
        .enableReconnection()
        .setReconnectionAttempts(10)
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(10000)
        .setTimeout(30000)
        .enableForceNew()
        .enableAutoConnect()
        .build();

    _socket = io.io(_socketUrl, config);

    // Listen for real-time todo updates from server
    _socket!.on('todos-updated', (data) {
      _addDebugLog('Real-time update received: ${data?.length ?? 0} todos', 'socket');
      if (data != null && data is List) {
        setState(() {
          _todos = data.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
        });
      }
    });

    // Connection event handlers
    _socket!.on('connect', (_) {
      _addDebugLog('Connected! Socket ID: ${_socket!.id}', 'socket');
      _addDebugLog('Transport: WebSocket/Polling', 'socket');
      _addDebugLog('Transport: WebSocket/Polling', 'socket');
      _addDebugLog('Connected! Socket ID: ${_socket!.id}', 'socket');
      _addDebugLog('Transport: WebSocket/Polling', 'socket');
      setState(() {
        _isConnected = true;
        _connectionError = null;
      });
      // Refetch todos when reconnected to ensure sync
      _fetchTodos();
    });

    _socket!.on('disconnect', (reason) {
      _addDebugLog('Disconnected - Reason: $reason', 'socket');
      setState(() {
        _isConnected = false;
      });
    });

    _socket!.on('connect_error', (error) {
      _addDebugLog('Connection error: $error', 'error');
      _addDebugLog('Using fallback: manual polling via HTTP', 'warn');
      setState(() {
        _isConnected = false;
        _connectionError = error.toString();
      });
    });

    _socket!.on('reconnect_attempt', (attemptNumber) {
      _addDebugLog('Reconnection attempt #$attemptNumber', 'socket');
    });
  }

  // Retrieve all todos from the backend API
  Future<void> _fetchTodos() async {
    try {
      setState(() {
        _isLoading = true;
        _connectionError = null;
      });

      _addDebugLog('Fetching todos from: $_apiUrl', 'api');

      final response = await http.get(
        Uri.parse(_apiUrl),
      ).timeout(const Duration(seconds: 10));

      _addDebugLog('Fetch successful! Status: ${response.statusCode}', 'api');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _addDebugLog('Received ${jsonData.length} todos', 'api');

        // Log each todo for debugging
        for (var i = 0; i < jsonData.length; i++) {
          final todo = jsonData[i];
          _addDebugLog(
            'Todo ${i + 1}: ${todo['title']} (ID: ${todo['id']}, Completed: ${todo['completed']})',
            'data',
          );
        }

        setState(() {
          _todos = jsonData.map((json) => Todo.fromJson(json)).toList();
          _connectionError = null;
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (error) {
      final errorMessage = error.toString();
      _addDebugLog('Fetch error: $errorMessage', 'error');
      setState(() {
        _connectionError = errorMessage;
      });

      if (mounted) {
        _showErrorDialog('Connection Error', 'Unable to connect to API: $errorMessage');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Create a new todo item via POST request
  Future<void> _addTodo() async {
    final todoText = _newTodoController.text.trim();

    if (todoText.isEmpty) {
      _addDebugLog('Add todo skipped: empty input', 'warn');
      return;
    }

    try {
      _addDebugLog('Adding new todo: "$todoText"', 'api');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': todoText}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _addDebugLog('Todo added successfully! ID: ${responseData['id']}', 'api');

        // Clear input field after successful creation
        _newTodoController.clear();

        // If Socket.IO doesn't update, manually refetch as fallback
        Timer(const Duration(milliseconds: 300), () {
          _addDebugLog('Fallback: Refetching todos after add', 'fallback');
          _fetchTodos();
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (error) {
      _addDebugLog('Failed to add todo: $error', 'error');
      _showErrorDialog('Error', 'Failed to add todo');
    }
  }

  // Remove a todo item using DELETE request
  Future<void> _deleteTodo(int id) async {
    try {
      _addDebugLog('Deleting todo ID: $id', 'api');

      final response = await http.delete(Uri.parse('$_apiUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _addDebugLog('Todo deleted successfully! ID: $id', 'api');

        // If Socket.IO doesn't update, manually refetch as fallback
        Timer(const Duration(milliseconds: 300), () {
          _addDebugLog('Fallback: Refetching todos after delete', 'fallback');
          _fetchTodos();
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (error) {
      _addDebugLog('Failed to delete todo: $error', 'error');
      _showErrorDialog('Error', 'Failed to delete todo');
    }
  }

  // Toggle todo completion status via PUT request
  Future<void> _updateTodo(int id) async {
    final todo = _todos.firstWhere((t) => t.id == id, orElse: () {
      _addDebugLog('Update failed: Todo ID $id not found', 'error');
      return Todo(id: -1, title: '', completed: false);
    });

    if (todo.id == -1) return;

    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      completed: !todo.completed,
    );

    try {
      _addDebugLog(
        'Updating todo ID: $id to ${updatedTodo.completed ? 'completed' : 'active'}',
        'api',
      );

      final response = await http.put(
        Uri.parse('$_apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTodo.toJson()),
      );

      if (response.statusCode == 200) {
        _addDebugLog('Todo updated successfully! ID: $id', 'api');

        // If Socket.IO doesn't update, manually refetch as fallback
        Timer(const Duration(milliseconds: 300), () {
          _addDebugLog('Fallback: Refetching todos after update', 'fallback');
          _fetchTodos();
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (error) {
      _addDebugLog('Failed to update todo: $error', 'error');
      _showErrorDialog('Error', 'Failed to update todo');
    }
  }

  // Show error dialog to user
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe3f2fd), Color(0xFFbbdefb)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header title
                const Text(
                  'To-Do List',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Settings toggle button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSettings = !_showSettings;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _showSettings ? '▼ Hide Settings' : '▶ Show Settings',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // Server Configuration Settings
                if (_showSettings) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Server Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle between Local and Remote Server
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf5f5f5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _useLocalServer ? '🏠 Local Server' : '☁️ Remote Server',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: _useLocalServer,
                                onChanged: (value) {
                                  setState(() {
                                    _useLocalServer = value;
                                  });
                                  debugPrint('🔄 Switching to: ${value ? 'Local' : 'Remote'}');
                                  _initializeConnection();
                                },
                                activeTrackColor: const Color(0xFF4caf50),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Custom Server URL Input (only for remote)
                        if (!_useLocalServer) ...[
                          const Text(
                            'Remote Server URL:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _customServerController,
                            decoration: InputDecoration(
                              hintText: 'https://your-server.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1976d2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (value) {
                              _customServerUrl = value;
                            },
                            onSubmitted: (_) {
                              _initializeConnection();
                            },
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Local Server URL Display (read-only)
                        if (_useLocalServer) ...[
                          const Text(
                            'Local Server URL:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4caf50),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _localServerUrl,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4caf50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Current Active URL
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe3f2fd),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF2196F3),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACTIVE API',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _apiUrl,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1976d2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Connection status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _isConnected
                              ? const Color(0xFF4caf50)
                              : const Color(0xFFf44336),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_isConnected ? 'Connected' : 'Disconnected'} - $_environmentName',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Debug Panel Toggle Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDebug = !_showDebug;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '${_showDebug ? '▼ Hide Debug Logs' : '▶ Show Debug Logs'} (${_debugLogs.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // Debug Logs Panel
                if (_showDebug) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFdddddd)),
                    ),
                    child: Column(
                      children: [
                        // Debug header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFe0e0e0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFbdbdbd)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🔍 Debug Logs (Last 50)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _debugLogs.clear();
                                  });
                                  _addDebugLog('Debug logs cleared', 'system');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFf44336),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Debug logs list (newest first)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            reverse: false,
                            itemCount: _debugLogs.reversed.length,
                            itemBuilder: (context, index) {
                              final log = _debugLogs.reversed.toList()[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: _getLogColor(log),
                                    height: 1.4,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Show error message and retry button if connection fails
                if (_connectionError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFffebee),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFFf44336),
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Error: $_connectionError',
                          style: const TextStyle(
                            color: Color(0xFFc62828),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchTodos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf44336),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'Retry Connection',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Loading indicator
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF2196F3),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading todos...',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input field for new todo
                TextField(
                  controller: _newTodoController,
                  decoration: InputDecoration(
                    hintText: 'Enter new todo...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addTodo(),
                ),
                const SizedBox(height: 12),

                // Add button
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add To-Do',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Todo counter
                Text(
                  'Total Todos: ${_todos.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),

                // Todo list
                Expanded(
                  child: _todos.isEmpty && !_isLoading
                      ? const Center(
                          child: Text(
                            'No todos yet. Add one above!',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final todo = _todos[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Todo text
                                  Expanded(
                                    child: Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: todo.completed
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: todo.completed
                                            ? const Color(0xFF999999)
                                            : const Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Complete/Unmark button
                                  TextButton(
                                    onPressed: () => _updateTodo(todo.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      todo.completed ? 'Unmark' : 'Complete',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button
                                  TextButton(
                                    onPressed: () => _deleteTodo(todo.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
