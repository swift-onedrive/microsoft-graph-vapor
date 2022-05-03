#  OneDriveAPI

```swift
dependencies: [
        //...
        .package(path: "../microsoft-graph")
    ],
    targets: [
        .target(name: "MyAppName", dependencies: [
            //...
            .product(name: "OneDrive", package: "microsoft-graph"),
        ]),
    ]
```

In `configure.swift`

```

```
