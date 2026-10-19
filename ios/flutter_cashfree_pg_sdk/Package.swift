// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_cashfree_pg_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-cashfree-pg-sdk", targets: ["flutter_cashfree_pg_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Keep in sync with the CashfreePG version in flutter_cashfree_pg_sdk.podspec
        .package(url: "https://github.com/cashfree/core-ios-sdk", exact: "2.5.3")
    ],
    targets: [
        .target(
            name: "flutter_cashfree_pg_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // core-ios-sdk ships independent binary targets with no declared
                // inter-dependencies, so every framework in the chain must be linked
                // explicitly or the app fails at launch with "Library not loaded".
                .product(name: "CashfreePG", package: "core-ios-sdk"),
                .product(name: "CashfreePGUISDK", package: "core-ios-sdk"),
                .product(name: "CashfreePGCoreSDK", package: "core-ios-sdk"),
                .product(name: "CashfreeAnalyticsSDK", package: "core-ios-sdk"),
                .product(name: "CFNetworkSDK", package: "core-ios-sdk")
            ]
        )
    ]
)
