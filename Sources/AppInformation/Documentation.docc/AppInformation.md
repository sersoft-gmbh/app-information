# ``AppInformation``

A simple package for storing as well as showing app infos.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/app-information", from: "1.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

To use this package, you can use the ``AppInfo`` and ``AppInfo/AppleID`` models to store app information.
For SwiftUI applications, there's an environment value ``SwiftUICore/EnvironmentValues/appInfo`` that by default returns the current app's information.

The following information is stored in the ``AppInfo`` (incl. where it's read from):

-   ``AppInfo/identifier``: `Bundle.bundleIdentifier` or `ProcessInfo.processIdentifier`
-   ``AppInfo/names``:
    -   ``AppInfo/Naming/unlocalized``:
        -   `base`: `Bundle.infoDictionary["CFBundleName"]` or `ProcessInfo.processName`
        -   `display`: `Bundle.infoDictionary["CFBundleDisplayName"]`
    -   ``AppInfo/Naming/localized``:
        -   `base`: `Bundle.localizedInfoDictionary["CFBundleName"]`
        -   `display`: `Bundle.localizedInfoDictionary["CFBundleDisplayName"]`
-   ``AppInfo/versioning``:
    -   ``AppInfo/Versioning/version``: `Bundle.infoDictionary["CFBundleShortVersionString"]` or `"1.0.0"`
    -   ``AppInfo/Versioning/build``: `Bundle.infoDictionary["CFBundleVersion"]` or `"1"`
-   ``AppInfo/copyright``: `"NSHumanReadableCopyright"` in either the localized or unlocalized info dictionary of the `Bundle`.
-   ``AppInfo/appleID``: `Bundle.infoDictionary["AppInformationAppleID"]`

The ``AppInfo/AppleID`` model can be used to e.g. generate app store page urls for showing the app in the app store or directly linking to the page where the user can write a review.
