#!/bin/bash

# Setup flutter
if cd flutter; 
then git pull && cd ..;
else git clone https://github.com/flutter/flutter.git; fi

FLUTTER=flutter/bin/flutter

# Configure flutter
FLUTTER_CHANNEL=stable
$FLUTTER channel $FLUTTER_CHANNEL
$FLUTTER config --enable-web

# Setup dart
DART=`echo $FLUTTER | sed 's/flutter$/cache\/dart-sdk\/bin\/dart/'`
echo $DART

echo "installing flutter_cors"
$DART pub global activate flutter_cors
export PATH="$PATH":"$HOME/.pub-cache/bin"
fluttercors -db -p $FLUTTER

# Build flutter for web

$FLUTTER build web --release
echo "OK"