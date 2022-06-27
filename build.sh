#!/bin/bash

# Setup flutter
if cd flutter; 
then git pull && cd ..;
else git clone https://github.com/flutter/flutter.git; fi

FLUTTER=flutter/bin/flutter
export PATH="$PATH":"$FLUTTER"

# Configure flutter
FLUTTER_CHANNEL=stable
flutter channel $FLUTTER_CHANNEL
flutter config --enable-web

# Setup dart
DART=`echo $FLUTTER | sed 's/flutter$/cache\/dart-sdk\/bin\/dart/'`
export PATH="$PATH":"$DART"

echo "installing flutter_cors"
dart pub global activate flutter_cors
export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "disabling flutter cors"
fluttercors -db -p $FLUTTER

# Build flutter for web

flutter build web --release
echo "OK"