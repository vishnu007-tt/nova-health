# Deploy NovaHealth Backend to Render.com

**Render.com has NO size limits** - perfect for ML models!

---

## Why Render.com?

- No image size limits (Railway has 4GB limit)
- Free tier with 750 hours/month
- Automatic HTTPS
- Easy Python deployment
- Perfect for ML apps

---

## Deploy in 5 Minutes

### Step 1: Go to Render Dashboard

Open: https://render.com/

Click **"Get Started"** or **"Sign Up"** (use GitHub login)

---

### Step 2: Create New Web Service

1. Click **"New +"** button (top right)
2. Select **"Web Service"**
3. Click **"Connect account"** to link GitHub
4. Find and select **"novahealth-backend"** repository
5. Click **"Connect"**

---

### Step 3: Configure Service

Fill in these settings:

**Basic Settings:**
- **Name:** `novahealth-ml` (or any name you like)
- **Region:** Choose closest to you (e.g., Oregon, Frankfurt)
- **Branch:** `main`
- **Root Directory:** Leave blank
- **Runtime:** `Python 3`

**Build Settings:**
- **Build Command:**
  ```
  pip install -r requirements.txt
  ```

**Start Settings:**
- **Start Command:**
  ```
  uvicorn fastapi_server:app --host 0.0.0.0 --port $PORT
  ```

**Instance Type:**
- Select **"Free"** (750 hours/month)

---

### Step 4: Deploy

1. Click **"Create Web Service"** at the bottom
2. Render will start building (takes 5-10 minutes for ML packages)
3. Watch the build logs in real-time

---

### Step 5: Get Your URL

Once deployed, you'll see:
- **Status:** "Live" with green dot
- **URL:** `https://novahealth-ml.onrender.com`

Copy this URL!

---

### Step 6: Test the API

```bash
curl https://novahealth-ml.onrender.com/
```

Expected response:
```json
{
  "message": "NovaHealth ML API",
  "version": "1.0.0",
  "status": "running",
  "models": {
    "obesity": true,
    "exercise": true,
    "menstrual": true
  }
}
```

---

### Step 7: Update Flutter App

Edit `lib/services/ml_prediction_service.dart`:

```dart
class MLPredictionService {
  // Replace with your Render URL
  static const String baseUrl = 'https://novahealth-ml.onrender.com';

  // ... rest of code
}
```

---

## Auto-Deploy on Git Push

Every time you push to GitHub, Render automatically redeploys:

```bash
cd backend
git add .
git commit -m "Update models"
git push origin main
# Render auto-deploys!
```

---

## Monitor Your Service

In Render dashboard:
- **Logs:** View real-time application logs
- **Metrics:** CPU, memory, request stats
- **Events:** Deployment history

---

## Pricing

**Free Tier:**
- 750 hours/month (enough for 24/7 if only one service)
- 512MB RAM
- Shared CPU
- **No size limits!**

**Paid Plans (if needed):**
- **Starter ($7/month):** 1GB RAM, more CPU
- **Standard ($25/month):** 2GB RAM, dedicated CPU

---

## Important Notes

### Cold Starts (Free Tier)
- Free tier services spin down after 15 minutes of inactivity
- First request after sleep takes ~30 seconds to wake up
- Subsequent requests are fast

**Solution:** Upgrade to paid plan ($7/month) for always-on

### Build Time
- First build: 8-10 minutes (installing PyTorch, etc.)
- Subsequent builds: 2-3 minutes (cached dependencies)

---

## Troubleshooting

### Build Failed

Check build logs for errors:
- Missing dependencies? Update `requirements.txt`
- Python version issues? Render uses Python 3.11 by default

### Service Not Starting

Check logs for:
- Port binding issues (use `$PORT` environment variable)
- Model loading errors (check file paths)

### Out of Memory

Free tier has 512MB RAM. If models are too large:
- Upgrade to Starter plan (1GB RAM)
- Or optimize models (quantization, pruning)

---

## Advantages Over Railway

| Feature | Render | Railway |
|---------|--------|---------|
| **Size Limit** | None | 4GB |
| **Free Tier** | 750 hrs | $5 credit |
| **Setup** | Easy | Medium |
| **ML Models** | Perfect | Limited |
| **Always On** | Paid only | Yes |

---

## Quick Start Commands

Already have GitHub repo? Just:

1. Go to https://render.com/
2. New Web Service
3. Connect `novahealth-backend`
4. Build: `pip install -r requirements.txt`
5. Start: `uvicorn fastapi_server:app --host 0.0.0.0 --port $PORT`
6. Deploy!

---

## Environment Variables (Optional)

In Render dashboard, add variables:
- `PYTHON_VERSION=3.11`
- `MODEL_PATH=/opt/render/project/src/optimized_models`

---

**Deployment time: ~10 minutes**
**Cost: Free**
**Perfect for ML models with no size limits!**
