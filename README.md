Todo App with BLoC
A feature-rich Todo application built with Flutter using BLoC for state management and Hive for local storage. Supports offline functionality, dark mode, and search.

🛠️ Setup Instructions
Prerequisites
Flutter SDK (latest stable version)

Dart SDK (included with Flutter)

Node.js (for backend API)

MongoDB (for database)

Frontend Setup
Clone the repository:
https://github.com/Gaurav905800/todo.git

Install dependencies:

flutter pub get

Backend Setup
Navigate to backend directory:

cd api
Install dependencies:

npm install
Start the server:

npm start

🌐 REST API Endpoints
Method Endpoint Description
GET /api/task Get all todos
GET /api/task/:id Get single todo
POST /api/task Create new todo
PUT /api/task/:id Update existing todo
DELETE /api/task/:id Delete todo

✨ Features Implemented
Core Features
✅ Create, read, update, and delete todos

✅ Mark todos as complete/incomplete

✅ Set priority levels (High/Medium/Low)

✅ Search todos with debounce

✅ Pull-to-refresh

✅ Swipe to delete with confirmation

Advanced Features
🌙 Dark/Light mode toggle

📱 Offline support with Hive

🔄 Automatic sync when online

🏗️ BLoC state management

🎨 Responsive UI design

🚦 Priority-based color coding

Error Handling
🛑 Network error handling

🔄 Retry failed operations

📦 Dependencies
flutter_bloc: State management

http: API calls

equatable: Value equality
