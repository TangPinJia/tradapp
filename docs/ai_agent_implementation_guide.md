# AI Agent Implementation Guide - Step by Step

## 🚀 Quick Start Implementation

### 1. Flutter Project Setup

```bash
# Create new Flutter project
flutter create ai_agent_app
cd ai_agent_app

# Add dependencies to pubspec.yaml
```

**pubspec.yaml:**
```yaml
name: ai_agent_app
description: Cross-platform AI agent application

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Real-time Communication
  socket_io_client: ^2.0.3+1
  web_socket_channel: ^2.4.0
  
  # HTTP & API
  http: ^1.1.0
  dio: ^5.3.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  cupertino_icons: ^1.0.2
  flutter_markdown: ^0.6.18
  url_launcher: ^6.1.14
  
  # Audio & Speech
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.5
  
  # Camera & Image
  camera: ^0.10.5+5
  image_picker: ^1.0.4
  
  # File Handling
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 2. Backend Setup (Node.js)

```bash
# Create backend directory
mkdir ai_agent_backend
cd ai_agent_backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express socket.io langchain openai cors dotenv multer jsonwebtoken bcryptjs mongoose
npm install --save-dev nodemon
```

**package.json:**
```json
{
  "name": "ai-agent-backend",
  "version": "1.0.0",
  "description": "AI Agent Backend Server",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.7.4",
    "langchain": "^0.1.0",
    "openai": "^4.20.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "multer": "^1.4.5-lts.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "mongoose": "^8.0.3"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

## 📱 Flutter Implementation

### 1. Project Structure
```
lib/
├── main.dart
├── models/
│   ├── message.dart
│   ├── user.dart
│   └── agent_response.dart
├── providers/
│   ├── chat_provider.dart
│   ├── auth_provider.dart
│   └── agent_provider.dart
├── services/
│   ├── socket_service.dart
│   ├── api_service.dart
│   └── storage_service.dart
├── screens/
│   ├── chat_screen.dart
│   ├── login_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── message_bubble.dart
    ├── chat_input.dart
    └── loading_indicator.dart
```

### 2. Core Models

**lib/models/message.dart:**
```dart
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final bool isUser;

  Message({
    String? id,
    required this.content,
    required this.senderId,
    required this.senderName,
    DateTime? timestamp,
    this.type = MessageType.text,
    required this.isUser,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      isUser: json['isUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'isUser': isUser,
    };
  }
}

enum MessageType { text, image, audio, file }
```

### 3. State Management

**lib/providers/chat_provider.dart:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/socket_service.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return ChatNotifier(socketService);
});

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final bool isTyping;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SocketService _socketService;

  ChatNotifier(this._socketService) : super(ChatState()) {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socketService.onMessageReceived((message) {
      addMessage(message);
    });

    _socketService.onTypingStatus((isTyping) {
      state = state.copyWith(isTyping: isTyping);
    });
  }

  void addMessage(Message message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  Future<void> sendMessage(String content) async {
    final message = Message(
      content: content,
      senderId: 'user',
      senderName: 'User',
      isUser: true,
    );

    addMessage(message);
    state = state.copyWith(isLoading: true);

    try {
      await _socketService.sendMessage(content);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
```

### 4. Socket Service

**lib/services/socket_service.dart:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;
  Function(Message)? _onMessageReceived;
  Function(bool)? _onTypingStatus;

  void connect(String serverUrl) {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to server');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });

    _socket!.on('message', (data) {
      final message = Message.fromJson(data);
      _onMessageReceived?.call(message);
    });

    _socket!.on('typing', (data) {
      final isTyping = data['isTyping'] as bool;
      _onTypingStatus?.call(isTyping);
    });
  }

  void sendMessage(String content) {
    _socket?.emit('message', {
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void onMessageReceived(Function(Message) callback) {
    _onMessageReceived = callback;
  }

  void onTypingStatus(Function(bool) callback) {
    _onTypingStatus = callback;
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
```

### 5. Chat Screen

**lib/screens/chat_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.error != null
                ? _buildErrorWidget(context, ref, chatState.error!)
                : _buildMessageList(chatState),
          ),
          if (chatState.isTyping) _buildTypingIndicator(),
          ChatInput(
            onSendMessage: (message) {
              ref.read(chatProvider.notifier).sendMessage(message);
            },
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[chatState.messages.length - 1 - index];
        return MessageBubble(message: message);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearError();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.smart_toy, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('AI is typing...'),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Backend Implementation

### 1. Server Setup

**server.js:**
```javascript
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');
const { AgentManager } = require('./services/agentManager');
const { DatabaseService } = require('./services/databaseService');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());

// Services
const agentManager = new AgentManager();
const databaseService = new DatabaseService();

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('message', async (data) => {
    try {
      // Store message in database
      await databaseService.saveMessage({
        socketId: socket.id,
        content: data.content,
        timestamp: new Date(),
        isUser: true
      });

      // Emit typing indicator
      socket.emit('typing', { isTyping: true });

      // Process with AI agent
      const response = await agentManager.processMessage(data.content, socket.id);

      // Store AI response
      await databaseService.saveMessage({
        socketId: socket.id,
        content: response,
        timestamp: new Date(),
        isUser: false
      });

      // Send response
      socket.emit('message', {
        id: Date.now().toString(),
        content: response,
        senderId: 'ai',
        senderName: 'AI Agent',
        timestamp: new Date().toISOString(),
        type: 'text',
        isUser: false
      });

      // Stop typing indicator
      socket.emit('typing', { isTyping: false });

    } catch (error) {
      console.error('Error processing message:', error);
      socket.emit('error', { message: 'Failed to process message' });
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

app.get('/api/conversations/:userId', async (req, res) => {
  try {
    const conversations = await databaseService.getConversations(req.params.userId);
    res.json(conversations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 2. AI Agent Manager

**services/agentManager.js:**
```javascript
const { ChatOpenAI } = require('langchain/chat_models/openai');
const { ConversationChain } = require('langchain/chains');
const { BufferMemory } = require('langchain/memory');
const { HumanMessage, AIMessage } = require('langchain/schema');

class AgentManager {
  constructor() {
    this.llm = new ChatOpenAI({
      openAIApiKey: process.env.OPENAI_API_KEY,
      modelName: 'gpt-3.5-turbo',
      temperature: 0.7,
    });

    this.conversations = new Map();
  }

  async processMessage(content, socketId) {
    try {
      // Get or create conversation memory
      let memory = this.conversations.get(socketId);
      if (!memory) {
        memory = new BufferMemory({
          returnMessages: true,
          memoryKey: 'history',
        });
        this.conversations.set(socketId, memory);
      }

      // Create conversation chain
      const chain = new ConversationChain({
        llm: this.llm,
        memory: memory,
      });

      // Process message
      const response = await chain.call({
        input: content,
      });

      return response.response;

    } catch (error) {
      console.error('Error in AgentManager:', error);
      return 'I apologize, but I encountered an error processing your message. Please try again.';
    }
  }

  async addTool(tool) {
    // Add custom tools to the agent
    // Implementation depends on specific tools needed
  }

  clearConversation(socketId) {
    this.conversations.delete(socketId);
  }
}

module.exports = { AgentManager };
```

### 3. Database Service

**services/databaseService.js:**
```javascript
const mongoose = require('mongoose');

// Message Schema
const messageSchema = new mongoose.Schema({
  socketId: String,
  content: String,
  timestamp: { type: Date, default: Date.now },
  isUser: Boolean,
  conversationId: String,
});

const Message = mongoose.model('Message', messageSchema);

// User Schema
const userSchema = new mongoose.Schema({
  socketId: String,
  name: String,
  email: String,
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema);

class DatabaseService {
  constructor() {
    this.connect();
  }

  async connect() {
    try {
      await mongoose.connect(process.env.MONGODB_URI);
      console.log('Connected to MongoDB');
    } catch (error) {
      console.error('MongoDB connection error:', error);
    }
  }

  async saveMessage(messageData) {
    try {
      const message = new Message(messageData);
      await message.save();
      return message;
    } catch (error) {
      console.error('Error saving message:', error);
      throw error;
    }
  }

  async getConversations(socketId) {
    try {
      const messages = await Message.find({ socketId })
        .sort({ timestamp: 1 })
        .limit(100);
      return messages;
    } catch (error) {
      console.error('Error getting conversations:', error);
      throw error;
    }
  }

  async saveUser(userData) {
    try {
      const user = new User(userData);
      await user.save();
      return user;
    } catch (error) {
      console.error('Error saving user:', error);
      throw error;
    }
  }
}

module.exports = { DatabaseService };
```

## 🌐 Environment Configuration

**.env (Backend):**
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/ai_agent
OPENAI_API_KEY=your_openai_api_key_here
JWT_SECRET=your_jwt_secret_here
NODE_ENV=development
```

## 🚀 Deployment Steps

### 1. Backend Deployment (Heroku)
```bash
# Create Heroku app
heroku create your-ai-agent-app

# Set environment variables
heroku config:set OPENAI_API_KEY=your_key
heroku config:set MONGODB_URI=your_mongodb_uri
heroku config:set JWT_SECRET=your_secret

# Deploy
git push heroku main
```

### 2. Flutter App Deployment

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

**iOS:**
```bash
# Build iOS
flutter build ios --release
```

**Web:**
```bash
# Build web
flutter build web --release
```

## 📱 Platform-Specific Configurations

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application
        android:label="AI Agent"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of configuration ... -->
    </application>
</manifest>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice input.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera for image input.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library for image selection.</string>
```

This implementation provides a complete foundation for a cross-platform AI agent with real-time communication, state management, and proper error handling. 