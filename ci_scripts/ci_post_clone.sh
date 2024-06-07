#!/bin/sh

#  ci_post_clone.sh
#  Incomes
#
#  Created by Hiromu Nakano on 2024/03/24.
#  Copyright © 2024 Hiromu Nakano. All rights reserved.

mkdir ../Incomes/Sources/Configuration/
mkdir ../Incomes/Configuration/Package/
mkdir ../Incomes/Configuration/Package/Firebase/
echo $SECRET_BASE64 | base64 -d -o ../Incomes/Sources/Configuration/Secret.swift
echo $GOOGLESERVICE_BASE64 | base64 -d -o ../Incomes/Configuration/Package/Firebase/GoogleService-Info.plist
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
