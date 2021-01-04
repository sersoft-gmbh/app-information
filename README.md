# Application Info

[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/app-information.svg?style=flat)](https://github.com/sersoft-gmbh/app-information/releases/latest)
![Tests](https://github.com/sersoft-gmbh/app-information/workflows/Tests/badge.svg)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/020ff9462b534d5fb12c128c7f547ebd)](https://www.codacy.com/gh/sersoft-gmbh/app-information/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/app-information&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/app-information/branch/main/graph/badge.svg?token=YG42CV07HM)](https://codecov.io/gh/sersoft-gmbh/app-information)
[![jazzy](https://raw.githubusercontent.com/sersoft-gmbh/app-information/gh-pages/badge.svg?sanitize=true)](https://sersoft-gmbh.github.io/app-information)

A simple package for storing as well as showing app infos.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/app-information.git", from: "1.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

To use this package, you can use the `AppInfo` and `AppInfo.AppleID` models to store app information.
For SwiftUI applications, there's an environment value `appInfo` that by default returns the current app's information.

The following information is stored in the `AppInfo` (incl. where it's read from):

-   `identifier`: -> `Bundle.bundleIdentifier` or `ProcessInfo.processIdentifier`
-   `names.unlocalized.base` -> `Bundle.infoDictionary["CFBundleName"]` or `ProcessInfo.processName`
-   `names.unlocalized.display` -> `Bundle.infoDictionary["CFBundleDisplayName"]`
-   `names.localized.base` -> `Bundle.localizedInfoDictionary["CFBundleName"]`
-   `names.localized.display` -> `Bundle.localizedInfoDictionary["CFBundleDisplayName"]`
-   `versioning.version` -> `Bundle.infoDictionary["CFBundleShortVersionString"]` or `"1.0.0"`
-   `versioning.build` -> `Bundle.infoDictionary["CFBundleVersion"]` or `"1"`
-   `copyright` -> `"NSHumanReadableCopyright"` in either the localized or unlocalized info dictionary of the `Bundle`.
-   `appleID` -> `Bundle.infoDictionary["AppInformationAppleID"]`

The `AppInfo.AppleID` model can be used to e.g. generate app store page urls for showing the app in the app store or directly linking to the page where the user can write a review.

## Possible Features

While not yet integrated, the following features might provide added value and could make it into this package in the future:

-   Potentially read more values.

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, there is an [online version](https://sersoft-gmbh.github.io/app-information) available for you.

## Contributing

If you find a bug / like to see a new feature in this package there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR.
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.
