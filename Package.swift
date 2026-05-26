// swift-tools-version: 5.10
import PackageDescription

// On CLT-only installations (no Xcode.app), Testing.framework is not on the
// default search path. The linkerSettings below cover the link step. The
// compile step additionally needs -Xswiftc -F -Xswiftc <path> passed to
// swift test so the auto-generated runner sees canImport(Testing) = true.
// Use `make test` (or the equivalent swift test invocation from Makefile)
// instead of running swift test bare.
//
// The -disable-cross-import-overlays flag suppresses the automatic import of
// _Testing_Foundation, which ships as a binary-only framework in CLT builds
// and has no swiftmodule. Without this flag, any test file that imports both
// Testing and Foundation triggers a compile error. The overlay is unused in
// these tests.
//
// On a standard Xcode installation all of this is handled automatically.
let testSwiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
        "-Xfrontend", "-disable-cross-import-overlays",
    ]),
]
let testLinkerSettings: [LinkerSetting] = [
    .unsafeFlags([
        "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
        "-framework", "Testing",
        "-Xlinker", "-rpath",
        "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
    ]),
]

let package = Package(
    name: "pidhound",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Sensors", targets: ["Sensors"]),
        .library(name: "Processes", targets: ["Processes"]),
        .library(name: "Grouping", targets: ["Grouping"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "PIDhoundCore", targets: ["PIDhoundCore"]),
        .library(name: "Shortcuts", targets: ["Shortcuts"]),
        .executable(name: "pidhound", targets: ["PIDhound"]),
        .executable(name: "pidhound-cli", targets: ["pidhound-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0"),
    ],
    targets: [
        .target(name: "Sensors"),
        .target(
            name: "Processes",
            dependencies: [
                "Sensors",
                .product(name: "Yams", package: "Yams"),
            ],
            resources: [.process("Resources")]
        ),
        .target(name: "Grouping", dependencies: ["Processes"]),
        .target(
            name: "Persistence",
            dependencies: [
                "Sensors",
                "Processes",
                "Shortcuts",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .target(name: "Shortcuts", dependencies: ["Processes"]),
        .target(name: "PIDhoundCore", dependencies: ["Sensors", "Processes", "Grouping", "Persistence"]),
        .executableTarget(name: "pidhound-cli", dependencies: ["PIDhoundCore"]),
        .executableTarget(
            name: "PIDhound",
            dependencies: ["PIDhoundCore", "Sensors", "Processes", "Grouping", "Persistence", "Shortcuts"]
        ),
        .testTarget(name: "SensorsTests", dependencies: ["Sensors"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "ProcessesTests", dependencies: ["Processes"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "GroupingTests", dependencies: ["Grouping"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "PIDhoundCoreTests", dependencies: ["PIDhoundCore", "Persistence"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "ShortcutsTests", dependencies: ["Shortcuts", "Processes"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
        .testTarget(name: "PIDhoundTests", dependencies: ["PIDhound", "PIDhoundCore", "Persistence", "Sensors", "Processes", "Shortcuts"],
            swiftSettings: testSwiftSettings, linkerSettings: testLinkerSettings),
    ]
)
