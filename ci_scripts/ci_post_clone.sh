#!/bin/sh

#  ci_post_clone.sh
#  Incomes
#
#  Created by Hiromu Nakano on 2024/03/24.
#  Copyright © 2024 Hiromu Nakano. All rights reserved.

mkdir ../Incomes/Configuration/Package/Firebase/
echo $GOOGLESERVICE_BASE64 | base64 -d -o ../Incomes/Configuration/Package/Firebase/GoogleService-Info.plist
echo $SECRET_BASE64 | base64 -d -o ../Incomes/Configuration/Secret.swift
echo $STOREKIT_BASE64 | base64 -d -o ../Incomes/Configuration/Package/StoreKit/StoreKitTestCertificate.cer
