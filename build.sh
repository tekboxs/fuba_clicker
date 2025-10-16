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

# Build the project
flutter build web --release --wasm --base-href /

echo "Build completed successfully!"
