#!/bin/bash

BUILD_TARGET="build/app/outputs/flutter-apk/app-standard-release.apk"

read -p "Did you update the version before running this? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    
    echo "Creating production release"
    
    if [ "$1" != "--skip-build" ] || [ ! -f "$BUILD_TARGET" ]; then
        flutter build apk --release --flavor standard
    fi
    
    firebase appdistribution:distribute \
        "$BUILD_TARGET" \
        --app '1:768052448622:android:e967ec35bee4945700457f' \
        --groups 'alpha-testers'
    
fi
