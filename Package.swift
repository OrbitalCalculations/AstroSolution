// swift-tools-version:5.5
import PackageDescription
let package = Package(
  name: "TokamakHTML",
  platforms: [.macOS("12.0")],
  products: [
    .executable(name: "TokamakApp", targets: ["TokamakHTML"])
  ],
  dependencies: [
    .package(name: "JavaScriptKit",
             url: "https://github.com/swiftwasm/JavaScriptKit.git",
             from: "0.11.1"),
    .package(name: "OpenCombineJS",
             url: "https://github.com/swiftwasm/OpenCombineJS.git",
             from: "0.1.2"),
    .package(name: "CommonCoding",
             url: "https://github.com/OrbitalCalculations/CommonCoding.git",
             from: "0.0.1"),
    .package(name: "Tokamak",
             url: "https://github.com/TokamakUI/Tokamak",
             from: "0.9.0"),
    //.package(name: "Plotly",
    //         url: "https://github.com/vojtamolda/Plotly.swift.git",
    //         .exact("0.5.0"))
      .package(name: "Plotly", path: "../Plotly.swift")
  ],
  targets: [
    .executableTarget(
        name: "TokamakHTML",
        dependencies: [
            .product(name: "TokamakShim", package: "Tokamak"),
            "JavaScriptKit",
            .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
            .product(name: "LNTBinaryCoding", package: "CommonCoding"),
            "Plotly"
        ],
        resources: [
          .copy("Resources/precomputedList.json"),
          .copy("Resources/astroSolutionList.json")
        ]
    ),
    .testTarget(
        name: "TokamakHTMLTests",
        dependencies: ["TokamakHTML"])
  ]
)
