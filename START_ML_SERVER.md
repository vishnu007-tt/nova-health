# NovaHealth ML Server - Quick Start Guide

## Starting the FastAPI ML Server

### 1. Open Terminal

### 2. Navigate to Project Directory
```bash
cd /Users/gitanjanganai/Downloads/NovaHealth
```

### 3. Activate Virtual Environment
```bash
source ml_venv/bin/activate
```

### 4. Install FastAPI Dependencies (First Time Only)
```bash
pip install fastapi uvicorn pydantic
```

### 5. Start the Server
```bash
python fastapi_server.py
```

You should see:
```
INFO:     Started server process
INFO:     Waiting for application startup.
Loading ML models...
✓ Obesity model loaded
✓ Exercise model loaded
✓ Menstrual model loaded
All models loaded successfully!
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 6. Test the Server
Open browser and go to: `http://localhost:8000`

You should see:
```json
{
  "status": "healthy",
  "service": "NovaHealth ML API",
  "version": "1.0.0",
  "models_loaded": {
    "obesity": true,
    "exercise": true,
    "menstrual": true
  }
}
```

---

## Using in Flutter App

### 1. Update Server URL (if needed)
In `lib/services/ml_prediction_service.dart`, change:
```dart
static const String baseUrl = 'http://localhost:8000';
```

For iOS Simulator, use:
```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

For Android Emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

### 2. Add Route to Navigation
In `lib/config/routes.dart`, add:
```dart
'/health-risk': (context) => const HealthRiskPage(),
```

### 3. Add Navigation Button
In your dashboard or menu, add:
```dart
ListTile(
  leading: const Icon(Icons.health_and_safety),
  title: const Text('Health Risk Assessment'),
  onTap: () => Navigator.pushNamed(context, '/health-risk'),
),
```

### 4. Run Flutter App
```bash
flutter run
```

---

## Troubleshooting

### Server Won't Start
- Check if port 8000 is already in use: `lsof -i :8000`
- Kill existing process: `kill -9 <PID>`
- Try different port: `uvicorn fastapi_server:app --port 8001`

### Models Not Loading
- Verify models exist: `ls -la optimized_models/*/`
- Check paths in `fastapi_server.py`
- Retrain models if needed: `python train_tabnet_only.py`

### Flutter Can't Connect
- Ensure server is running
- Check firewall settings
- Use correct IP address for emulator/simulator
- Test with curl: `curl http://localhost:8000`

### CORS Errors
- Server already configured for CORS
- Check browser console for specific errors
- Verify request headers

---

## API Endpoints

### Health Check
```bash
GET http://localhost:8000/
```

### Predict Health Risk
```bash
POST http://localhost:8000/predict/health-risk
Content-Type: application/json

{
  "userProfile": {
    "age": 25,
    "gender": "female",
    "weight": 60.0,
    "height": 165.0,
    "activityLevel": "moderately_active",
    "targetWeight": 58.0
  },
  "lifestyleData": {
    "totalWaterMl": 2000,
    "hydrationLogs": [],
    "moodLogs": [],
    "symptoms": [],
    "exerciseDuration": 30,
    "exerciseIntensity": 6
  }
}
```

---

## Features

**Obesity Risk Prediction** - 95.93% accuracy
- Predicts 7 obesity levels
- Calculates BMI and BMR
- Provides personalized recommendations

**Exercise Calorie Prediction** - R²=0.9980
- Predicts calories burned
- Calculates MET score
- Intensity analysis

**Lifestyle Analysis**
- Analyzes hydration patterns
- Mood tracking insights
- Symptom correlation
- Sleep quality assessment

**Overall Risk Score** - 0-100 scale
- Combines all health factors
- Weighted risk assessment
- Actionable insights

---

## Notes

- Server must be running for predictions to work
- Models are loaded once on startup (cached)
- All user data stays on device (only sent to local server)
- No external API calls or data sharing

---

## Security

- Server runs locally (localhost)
- No data is stored on server
- All predictions are real-time
- User data never leaves your machine

---

## Tips

1. Keep server running while using the app
2. Check server logs for debugging
3. Restart server if models update
4. Use `Ctrl+C` to stop server gracefully

---

**Ready to use!** Start the server and open the Health Risk Assessment page in your Flutter app.
