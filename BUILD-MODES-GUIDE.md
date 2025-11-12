# Build Modes & Environment Configuration

## ✨ How It Works Now - Automatic Detection!

The app **automatically** detects if it's running in development or production based on Flutter's build mode. **No manual switching needed!**

```dart
// The logic (already implemented in environment.dart):
static String get backendBaseUrl {
  if (isProduction) {
    // Release build → Production URL
    return _productionBackendUrl;  // https://api.brainleap.com
  }
  
  // Debug build → Development URL
  return dotenv.env['BACKEND_BASE_URL'];  // http://192.168.1.4:4000
}
```

## 🔄 Three Build Modes

| Mode | When | Backend URL | Use Case |
|------|------|-------------|----------|
| **Debug** | `flutter run` | `.env` file (your Mac's IP) | Daily development |
| **Profile** | `flutter run --profile` | `.env` file | Performance testing |
| **Release** | `flutter run --release` or `flutter build` | Production URL | App Store/Play Store |

## 🚀 Development Workflow

### Daily Development (Debug Mode)
```bash
# Just run normally - uses .env file
flutter run

# Backend URL: http://192.168.1.4:4000 (from .env)
```

### Testing Release Build Locally
```bash
# Test the release build on your phone
flutter run --release

# Backend URL: https://api.brainleap.com (production URL)
```

### Building for Store
```bash
# Android
flutter build apk --release --dart-define=BACKEND_URL=https://your-backend.railway.app
flutter build appbundle --release --dart-define=BACKEND_URL=https://your-backend.railway.app

# iOS
flutter build ios --release --dart-define=BACKEND_URL=https://your-backend.railway.app
```

## 📱 Network Configuration per Device Type

### Your Current Setup (Development)

**Physical Android Device (WiFi debugging):**
```bash
# .env file:
BACKEND_BASE_URL=http://192.168.1.4:4000  # Your Mac's local IP
```

**Android Emulator:**
```bash
# .env file:
BACKEND_BASE_URL=http://10.0.2.2:4000  # Emulator's special IP for host
```

**iOS Simulator:**
```bash
# .env file:
BACKEND_BASE_URL=http://localhost:4000
```

## 🌐 Production Backend URL Options

### Option 1: Railway (Recommended - Easiest)

**Why Railway:**
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Easy deployment from GitHub
- ✅ Auto-scaling
- ✅ Great for Node.js

**Steps:**
1. Sign up at https://railway.app
2. Create new project from GitHub
3. Select `brainleap-server` directory
4. Railway auto-detects Node.js and deploys
5. You get: `https://brainleap-backend.up.railway.app`

**Build command:**
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://brainleap-backend.up.railway.app
```

### Option 2: Heroku

**Why Heroku:**
- ✅ Well-documented
- ✅ Many add-ons
- ⚠️ Free tier removed (starts ~$5/month)

**Steps:**
```bash
cd brainleap-server
heroku login
heroku create brainleap-backend
git push heroku main
# URL: https://brainleap-backend.herokuapp.com
```

**Build command:**
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://brainleap-backend.herokuapp.com
```

### Option 3: Custom Domain (Professional)

**Why Custom Domain:**
- ✅ Professional look
- ✅ Brand consistency
- ✅ Easier to change hosting later

**Steps:**
1. Buy domain: `brainleap.com`
2. Deploy backend to Railway/Heroku/DigitalOcean
3. Point subdomain: `api.brainleap.com` → your hosting
4. SSL automatically configured

**Build command:**
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://api.brainleap.com
```

### Option 4: Render.com

**Why Render:**
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Good performance
- ✅ PostgreSQL included

**Steps:**
1. Sign up at https://render.com
2. New Web Service from GitHub
3. Select your backend repo
4. Auto-deploy
5. URL: `https://brainleap-backend.onrender.com`

**Build command:**
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://brainleap-backend.onrender.com
```

### Option 5: DigitalOcean App Platform

**Why DigitalOcean:**
- ✅ Reliable infrastructure
- ✅ $5/month basic tier
- ✅ Good scaling options

**Steps:**
1. Create account at https://digitalocean.com
2. Create new App
3. Connect GitHub repo
4. Deploy
5. URL: `https://brainleap-backend-xxxxx.ondigitalocean.app`

**Build command:**
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://brainleap-backend-xxxxx.ondigitalocean.app
```

## 🎯 Recommended Approach

### For MVP/Testing (Free):
```
Railway or Render
└─> https://brainleap-backend.up.railway.app
```

### For Production (Professional):
```
Railway + Custom Domain
└─> https://api.brainleap.com
```

## 📝 Complete Production Example

Let's say you choose Railway:

### 1. Deploy Backend to Railway
```bash
# Push your code to GitHub
cd brainleap-server
git add .
git commit -m "Prepare for deployment"
git push origin main

# In Railway dashboard:
# - Create new project
# - Connect GitHub repo
# - Select brainleap-server
# - Deploy
# - Get URL: https://brainleap-backend.up.railway.app
```

### 2. Build Android Release
```bash
cd brainleap-app

# Build APK
flutter build apk --release \
  --dart-define=BACKEND_URL=https://brainleap-backend.up.railway.app

# Build App Bundle (for Play Store)
flutter build appbundle --release \
  --dart-define=BACKEND_URL=https://brainleap-backend.up.railway.app
```

### 3. Build iOS Release
```bash
flutter build ios --release \
  --dart-define=BACKEND_URL=https://brainleap-backend.up.railway.app

# Then archive in Xcode
```

## 🔧 Update Default Production URL

If you want to change the default production URL in the code:

```dart
// lib/config/environment.dart
static const String _productionBackendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'https://your-actual-backend.railway.app', // Update this
);
```

Or always provide it at build time:
```bash
flutter build apk --release --dart-define=BACKEND_URL=https://your-backend.com
```

## 🧪 Testing Different Modes

### Test Debug Mode (Development)
```bash
# Uses .env file with your local IP
flutter run
```

### Test Release Mode Locally
```bash
# Uses production URL (make sure it's accessible!)
flutter run --release --dart-define=BACKEND_URL=https://your-backend.railway.app
```

### Test on Real Production
```bash
# Build and install on phone
flutter build apk --release --dart-define=BACKEND_URL=https://your-backend.com
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 💡 Pro Tips

### 1. Environment Variable Aliases

Create aliases in your `~/.zshrc`:
```bash
alias flutter-build-dev='flutter build apk --release --dart-define=BACKEND_URL=https://dev-backend.railway.app'
alias flutter-build-prod='flutter build apk --release --dart-define=BACKEND_URL=https://api.brainleap.com'
```

### 2. Build Script

Create `build-release.sh`:
```bash
#!/bin/bash
BACKEND_URL=${1:-https://api.brainleap.com}

echo "🔨 Building release with backend: $BACKEND_URL"

flutter build apk --release --dart-define=BACKEND_URL=$BACKEND_URL
flutter build appbundle --release --dart-define=BACKEND_URL=$BACKEND_URL

echo "✅ Build complete!"
echo "📦 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 Bundle: build/app/outputs/bundle/release/app-release.aab"
```

Usage:
```bash
./build-release.sh https://your-backend.railway.app
```

### 3. Multiple Environments

If you need staging + production:
```bash
# Staging
flutter build apk --release --dart-define=BACKEND_URL=https://staging-backend.railway.app

# Production
flutter build apk --release --dart-define=BACKEND_URL=https://api.brainleap.com
```

## ✅ Summary

| Scenario | Command | Backend URL |
|----------|---------|-------------|
| **Daily dev** | `flutter run` | `http://192.168.1.4:4000` (.env) |
| **Test release locally** | `flutter run --release --dart-define=...` | Provided URL |
| **Build for store** | `flutter build apk --release --dart-define=...` | Provided URL |

**No more manual environment switching!** 🎉

The app automatically uses:
- ✅ **Debug mode** → Your `.env` file (local development)
- ✅ **Release mode** → Production URL (App Store/Play Store)

---

**Questions?** The code detects the build mode and uses the appropriate backend URL automatically!

