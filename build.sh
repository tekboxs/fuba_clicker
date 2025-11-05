#!/bin/bash
set -e

echo "Setting up Flutter environment..."

# Clone or update Flutter
if cd flutter; then
  git pull && cd ..
else
  git clone https://github.com/flutter/flutter.git
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Configure Flutter
flutter doctor
flutter config --enable-web
flutter create . --platforms web
flutter pub get

# # Generate Hive files
# dart run build_runner build --delete-conflicting-outputs

# Build the project
if [ -z "$FUBA_SECRET_KEY" ]; then
  echo "Error: FUBA_SECRET_KEY environment variable is required but not set"
  echo "Please set FUBA_SECRET_KEY in your Vercel environment variables"
  exit 1
fi

flutter build web --release --base-href / --dart-define=FUBA_SECRET_KEY="$FUBA_SECRET_KEY"

echo "Build completed successfully!"
