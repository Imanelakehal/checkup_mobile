# 🌿 Paramap — Morocco's First AI Parapharmacy Marketplace

Paramap connects Moroccan consumers to parapharmacies — search, compare prices, order and get delivered. Phase 2 adds a free AI skin diagnosis in 30 seconds.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — version 3.x+
- [Dart](https://dart.dev/get-dart) — comes with Flutter
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Node.js](https://nodejs.org/) — version 18+ (for backend)
- [Firebase CLI](https://firebase.google.com/docs/cli) — `npm install -g firebase-tools`
- Git

---

## ⚙️ Environment Setup

### 1. Clone the repository
```bash
git clone https://github.com/Imanelakehal/checkup_mobile.git
cd paramap
```

### 2. Set up Flutter (Mobile App)
```bash
# Install dependencies
flutter pub get

# Check everything is working
flutter doctor
```

### 3. Set up Firebase

- Go to [Firebase Console](https://console.firebase.google.com/)
- Ask Imane to add your Google account to the Paramap Firebase project
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place them in the correct folders:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`

> ⚠️ These files are NOT in the repo for security reasons. 

### 4. Environment Variables

Create a `.env` file at the root of the project:
```env



> ⚠️ Never commit your `.env` file. It's already in `.gitignore`.

### 5. Run the app
```bash
# Run on connected device or emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome
```

---

## 🌿 Branch Structure

| Branch | Purpose |
|--------|---------|
| `main` | Production only — never push directly |
| `dev` | Active development — merge features here |
| `feature/...` | New features — branch from dev |
| `fix/...` | Bug fixes — branch from dev |

### How to create your feature branch
```bash
git checkout dev
git pull origin dev
git checkout -b feature/your-feature-name
```

### How to submit your work
```bash
git add .
git commit -m "feat: describe what you built"
git push origin feature/your-feature-name
```

Then open a **Pull Request** on GitHub → target branch: `dev`

---

## 📁 Project Structure
```
paramap/
├── lib/
│   ├── features/          # Feature-based clean architecture
│   │   ├── home/
│   │   ├── onboarding/
│   │   ├── parapharmacy/
│   │   └── auth/
│   ├── core/              # Shared utilities, theme, constants
│   └── main.dart
├── assets/
│   └── images/
├── android/
├── ios/
└── pubspec.yaml
```



## 📌 Commit Convention

Please follow this format for all commits:
```
feat: add new feature
fix: fix a bug
refactor: code change without new feature
style: formatting only
docs: documentation update
test: adding tests
```

---

## ⚠️ Important

- Never commit `google-services.json`, `.env`, or any API keys
- Always pull from `dev` before starting new work
- One Pull Request per feature keep them small and focused

---

Built with ❤️ in Morocco 🇲🇦