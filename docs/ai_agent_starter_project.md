# AI Agent Starter Project - Immediate Action Plan

## 🎯 What You Need to Do Right Now

### **Step 1: Choose Your Development Approach**

**Option A: Full-Stack Development (Recommended)**
- **Frontend:** Flutter (Android/iOS/Web)
- **Backend:** Node.js + Express
- **AI:** LangChain + OpenAI
- **Database:** MongoDB
- **Real-time:** Socket.IO

**Option B: Rapid Prototyping**
- **Frontend:** Flutter Web (browser only first)
- **Backend:** Firebase Functions
- **AI:** Direct OpenAI API
- **Database:** Firebase Firestore

## 🚀 Quick Start (Option A - Full Stack)

### **1. Backend Setup (Start Here)**

```bash
# Create backend directory
mkdir ai-agent-backend
cd ai-agent-backend

# Initialize project
npm init -y

# Install core dependencies
npm install express socket.io cors dotenv
npm install langchain openai
npm install mongoose jsonwebtoken bcryptjs
npm install --save-dev nodemon
```

**Create server.js:**
```javascript
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: { origin: "*" }
});

app.use(cors());
app.use(express.json());

// Simple AI response (replace with LangChain later)
const simpleAIResponse = async (message) => {
  // For now, return a simple response
  return `I received your message: "${message}". This is a basic AI response.`;
};

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('message', async (data) => {
    try {
      // Show typing indicator
      socket.emit('typing', { isTyping: true });

      // Process with AI
      const response = await simpleAIResponse(data.content);

      // Send response
      socket.emit('message', {
        id: Date.now().toString(),
        content: response,
        senderId: 'ai',
        senderName: 'AI Agent',
        timestamp: new Date().toISOString(),
        isUser: false
      });

      // Stop typing
      socket.emit('typing', { isTyping: false });

    } catch (error) {
      socket.emit('error', { message: 'Failed to process message' });
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Create .env:**
```env
PORT=3000
OPENAI_API_KEY=your_openai_api_key_here
```

### **2. Flutter Frontend Setup**

```bash
# Create Flutter project
flutter create ai_agent_app
cd ai_agent_app

# Add dependencies to pubspec.yaml
```

**Update pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  socket_io_client: ^2.0.3+1
  http: ^1.1.0
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.2
```

**Create lib/main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Agent',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
```

**Create lib/screens/chat_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[chatState.messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (chatState.isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['content'] as String,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white, size: 20),
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

**Create lib/providers/chat_provider.dart:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatState {
  final List<Map<String, dynamic>> messages;
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
    List<Map<String, dynamic>>? messages,
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
  IO.Socket? _socket;

  ChatNotifier() : super(ChatState()) {
    _connectToServer();
  }

  void _connectToServer() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to server');
    });

    _socket!.on('message', (data) {
      addMessage(data);
    });

    _socket!.on('typing', (data) {
      state = state.copyWith(isTyping: data['isTyping']);
    });
  }

  void addMessage(Map<String, dynamic> message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  void sendMessage(String content) {
    final message = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': content,
      'senderId': 'user',
      'senderName': 'User',
      'timestamp': DateTime.now().toIso8601String(),
      'isUser': true,
    };

    addMessage(message);
    _socket?.emit('message', {'content': content});
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}
```

## 🚀 Quick Test

### **1. Start Backend**
```bash
cd ai-agent-backend
npm run dev
```

### **2. Start Flutter App**
```bash
cd ai_agent_app
flutter run -d chrome  # For web testing
# or
flutter run  # For mobile testing
```

## 📱 Next Steps After Basic Setup

### **Phase 1: Add Real AI (Week 1)**
1. **Integrate OpenAI API**
2. **Add LangChain for better responses**
3. **Implement conversation memory**

### **Phase 2: Add Features (Week 2)**
1. **Voice input/output**
2. **Image processing**
3. **File uploads**

### **Phase 3: Platform Optimization (Week 3)**
1. **Android-specific features**
2. **iOS-specific features**
3. **Web optimizations**

### **Phase 4: Production Ready (Week 4)**
1. **Authentication**
2. **Database integration**
3. **Deployment**

## 🛠️ Tools You'll Use

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **Flutter** | Cross-platform UI | Always - main framework |
| **Node.js** | Backend server | Always - API and AI processing |
| **Socket.IO** | Real-time communication | Always - live chat |
| **LangChain** | AI agent framework | Week 1 - advanced AI features |
| **OpenAI API** | Language model | Week 1 - AI responses |
| **MongoDB** | Database | Week 4 - data persistence |
| **Firebase** | Deployment | Week 4 - production hosting |

## 🎯 Success Checklist

- [ ] Backend server running on port 3000
- [ ] Flutter app connects to backend
- [ ] Messages sent and received
- [ ] Real-time typing indicators
- [ ] Basic AI responses working
- [ ] Cross-platform testing (web/mobile)

This starter project gives you a working foundation that you can build upon. Start with this basic setup, then gradually add more advanced features! 