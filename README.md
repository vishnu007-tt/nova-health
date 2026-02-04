# NovaHealth

A comprehensive health and wellness tracking application built with Flutter, featuring ML-powered health predictions, AI chatbot, and cross-platform support.

## Features

### Health Tracking
- **Workout Logging** - Track exercises, duration, and calories burned
- **Hydration Tracking** - Monitor daily water intake with reminders
- **Period Tracking** - Menstrual cycle tracking with symptom logging
- **Mood Tracking** - Daily mood logging and pattern analysis
- **Symptom Tracking** - Log and monitor health symptoms
- **Nutrition Tracking** - Food logging with calorie counting

### ML-Powered Health Analysis
- **Obesity Risk Prediction** - 95.93% accuracy using TabNet neural networks
- **Exercise Calorie Prediction** - R²=0.9980 for accurate calorie burn estimates
- **Menstrual Health Analysis** - 91.06% accuracy for cycle irregularity detection
- **Health Insights Engine** - Rule-based pattern detection across all health metrics

### AI Features
- **Health Chatbot** - Gemini-powered conversational AI for health guidance
- **Personalized Recommendations** - Based on user profile and health data
- **Multi-language Support** - 40+ languages supported

### Security
- **Firebase Authentication** - Secure email/password login
- **Multi-Factor Authentication (MFA)** - SMS-based 2FA support
- **Cloud Sync** - Supabase integration for data backup

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: FastAPI (Python)
- **ML Models**: TabNet Neural Networks (PyTorch)
- **Database**: SQLite (local), Supabase (cloud)
- **Authentication**: Firebase Auth
- **AI**: Google Gemini API

## Platforms

- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode (for mobile builds)
- Chrome (for web development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vishnu007-tt/nova-health.git
cd nova-health
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API keys:
   - Add your Gemini API key in `lib/services/chatbot_service.dart`
   - Get a free key at: https://aistudio.google.com/app/apikey

4. Run the app:
```bash
flutter run
```

### Running on Different Platforms

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

## Project Structure

```
lib/
├── config/          # App configuration (routes, theme, etc.)
├── models/          # Data models
├── pages/           # UI screens
│   ├── auth/        # Authentication pages
│   ├── chatbot/     # AI chatbot
│   ├── dashboard/   # Main dashboard
│   ├── nutrition/   # Nutrition tracking
│   ├── profile/     # User profile
│   ├── settings/    # App settings
│   ├── tracking/    # Health tracking pages
│   └── wellness/    # Wellness features
├── providers/       # State management (Riverpod)
├── services/        # Business logic and API services
├── utils/           # Helper functions
└── widgets/         # Reusable UI components

backend/
├── fastapi_server.py    # ML API server
├── optimized_models/    # Trained ML models
└── requirements.txt     # Python dependencies
```

## ML Backend

The ML backend is hosted on Render.com and provides health predictions via REST API.

**Live API**: https://novahealth-backend.onrender.com

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check |
| `/predict/health-risk` | POST | Comprehensive health risk assessment |
| `/predict/obesity` | POST | Obesity risk prediction |
| `/predict/exercise` | POST | Exercise calorie prediction |
| `/predict/menstrual` | POST | Menstrual health analysis |

### Running Locally

```bash
cd backend
pip install -r requirements.txt
uvicorn fastapi_server:app --host 0.0.0.0 --port 8000
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
GEMINI_API_KEY=your_gemini_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Email/Password authentication
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the respective platform folders

## ML Model Performance

| Model | Metric | Score |
|-------|--------|-------|
| Obesity Risk | Accuracy | 95.93% |
| Exercise Calories | R² Score | 0.9980 |
| Menstrual Health | Accuracy | 91.06% |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Google for Gemini AI
- PyTorch and TabNet for ML capabilities
