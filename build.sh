#!/bin/bash

# Setup flutter
if cd flutter; 
then git pull && cd ..;
else git clone https://github.com/flutter/flutter.git; fi

FLUTTER=flutter/bin/flutter
echo "export PATH='$PATH':'$FLUTTER'" >> ~/.bashrc && source ~/.bashrc
echo "$(cat ~/.bashrc)"

# Configure flutter
FLUTTER_CHANNEL=stable
flutter channel $FLUTTER_CHANNEL
flutter config --enable-web

# Setup dart
DART=`echo $FLUTTER | sed 's/flutter$/cache\/dart-sdk\/bin\/dart/'`
echo "export PATH='$PATH':'$DART'" >> ~/.bashrc && source ~/.bashrc


echo "installing flutter_cors"
dart pub global activate flutter_cors
echo "export PATH='$PATH':'$HOME/.pub-cache/bin'" >> ~/.bashrc && source ~/.bashrc
echo "disabling flutter cors"
fluttercors -db -p $FLUTTER

# Build flutter for web

flutter build web --release
echo "OK"