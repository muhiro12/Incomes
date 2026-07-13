# Privacy Policy

Effective July 13, 2026.

Incomes is a personal budget app provided by Hiromu Nakano. This policy
describes how the current app handles information.

## Information stored by Incomes

Budget records, tags, calculated balances, preferences, and app-maintenance
state are stored locally using SwiftData and UserDefaults. Incomes does not
operate an account system or app backend that receives this content.

## Optional private iCloud sync

Premium users can choose to enable iCloud sync. When enabled, the app syncs its
SwiftData database through a private CloudKit database associated with the
user's Apple Account. Incomes does not copy these records to a
developer-operated server. Apple processes iCloud data under the
[Apple Privacy Policy](https://www.apple.com/legal/privacy/).

## Receipt capture and on-device intelligence

When a user chooses the camera or a photo, Incomes uses Apple's VisionKit to
recognize text. On supported devices, the recognized text and budget data can
also be processed by Apple's on-device Foundation Models to suggest form values
or generate a monthly summary.

Incomes does not send receipt images, recognized text, budget records, prompts,
or generated summaries to a developer-operated AI service.

## Advertising and privacy messaging SDKs

The iOS app integrates the Google Mobile Ads SDK and Google User Messaging
Platform (UMP). At startup, Incomes asks UMP to update the applicable consent
information. When a premium subscription is not active, Incomes presents a
privacy message when required. Google Mobile Ads is initialized, and native ad
requests are enabled, only after UMP reports that ads may be requested and the
user is eligible to see ads.

According to Google's SDK documentation and the privacy manifests bundled with
the current SDKs, Google may process information such as IP-derived coarse
location, device identifiers, advertising data, product interactions, crash
data, performance data, and other diagnostics for advertising, analytics, and
SDK functionality. The information processed can vary by SDK version, device,
region, Google configuration, and the user's privacy choices.

Incomes does not provide budget records, receipt images, or recognized text to
the advertising SDKs. For details, review Google's
[Mobile Ads data disclosure](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/privacy/data-disclosure),
[UMP documentation](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/privacy),
and [Privacy Policy](https://policies.google.com/privacy).

## Purchases and subscriptions

Subscriptions are offered through Apple's StoreKit. Apple processes payments
and purchase history. Incomes receives the product identifiers and entitlement
state needed to determine whether premium features are active.

## Remote configuration and product website

At startup, Incomes downloads a small JSON file from `raw.githubusercontent.com`
that contains the minimum supported app version. The request does not include
budget records or other app content. GitHub may receive standard network request
information, such as an IP address, under the
[GitHub General Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement).

GitHub Pages also hosts this privacy policy and the Incomes product page.

## Diagnostics

Incomes keeps a bounded set of application log snapshots in local UserDefaults
for in-app diagnostics. The app does not transmit those snapshots to an
Incomes-operated analytics or crash-reporting service. Diagnostics handled by
the Google advertising SDKs are described in the advertising section above.

## Choices and retention

Users can delete budget records in the app, disable iCloud sync in Incomes,
manage camera access in system Settings, review privacy choices from the
Incomes Settings screen when required, and purchase premium access to remove ad
presentation. Local and iCloud retention are otherwise controlled through the
app and Apple's device and iCloud settings.

## Children's privacy

Incomes is not directed to children under 13. The app does not knowingly ask
children to submit personal information to an Incomes-operated server.

## Security

Incomes relies on Apple's platform protections and encrypted HTTPS connections
for the external services described above. No method of electronic storage or
network transmission can be guaranteed to be completely secure.

## Changes to this policy

This policy may be updated when app features, SDKs, or data practices change.
The effective date at the top of this page will be updated with any revision.

## Contact

For privacy questions, contact
[@muhiro_12 on X](https://x.com/muhiro_12). Do not include private financial
information in a public message.
