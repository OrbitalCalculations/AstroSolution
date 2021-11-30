//
//  Views.swift
//  
//
//  Created by Heiko Pälike on 11/11/2021.
//

import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

import Foundation

final class AppEnvironment: ObservableObject {
  @Published var solution: AstroSolutionEnum = .La1993
  @Published var startMyr: Double = 10.0
  @Published var fgam: Double = 1.0
  @Published var cmar: Double = 1.0
  
  @Published var throughput = 0.0
  @Published var overallProgress = 0
  @Published var computationProgress = 0.0
  
  @Published var maxAvailableStartMyr = 50.0
  @Published var isComputing = false
  @Published var isDownloading = false
  @Published var isProcessing = false
  
  @Published var solutionName = ""
  @Published var shouldShowSolutionName = true
  
  @Published var verbosity_option = true
  @Published var binary_option = true

  public func fileName() -> String {
    let solutionName = solution.rawValue
    var maxAge: Double = startMyr
    if solution == .La1993 {
      maxAge = min(50.0, maxAge)
      startMyr = maxAge
    }
    
    if ((solution == .ZB2017e) ||
        (solution == .ZB2018a)) {
      maxAge = min(99.979, maxAge)
      startMyr = maxAge
    }
    
    if ((solution == .La2004) ||
        (solution == .La2011)) {
      maxAge = min(0.0, maxAge)
      startMyr = maxAge
    }
        
    if ((solution == .La2010a) ||
        (solution == .La2010a) ||
        (solution == .La2010a) ||
        (solution == .La2010a)) {
      maxAge = min(100.0, maxAge)
      startMyr = maxAge
    }
        
    let fileName =
    "\(solutionName)_(\(String(format: "%6.4f", fgam)),\(String(format:"%3.1f", cmar)))_0-\(startMyr)Ma.txt"
    return fileName
  }
}




public struct ParameterLabels: View {
    public var body: some View {
        HStack {
            Text("dyn. ellipticity")
            Text("tidal dissipation")
        }.foregroundColor(.primary)
    }
}

public struct AstroSolutionView: View {
  var selections = AstroSolutionEnum.allCases
  @Binding var selection: Int

  public var body: some View {
    Picker(
      selection: $selection,
      label: Text("Astro Solution")
    ) {
      Text("Please select:")
      ForEach(0..<selections.count) {
          Text(String(describing: selections[$0]))
      }
    }
  }
}

public struct Parameters: View {
    var selections = AstroSolutionEnum.allCases
    @Binding var selection: Int

    public var body: some View {
        Picker(
            selection: $selection,
            label: Text("Parameters")
        ) {
            Text("Please select:")
            ForEach(0..<availPrecomputedSelections.count) {
                Text("fgam: \(String(format: "%.2f", availPrecomputedSelections[$0].fgam)), cmar: \(String(format: "%.2f", availPrecomputedSelections[$0].cmar))")
                //Text(String(describing: availPrecomputedSelections[$0]))
            }
        }
  }
}


public struct UsePrecomputed: View {
    @Binding var isOn: Bool
    public var body: some View {
        Toggle(isOn: $isOn) {
            Text("use precomputed Solution")
        }
        .foregroundColor(.primary)
    }
}

struct StatusView: View {
  @EnvironmentObject var environment: AppEnvironment
  public var body: some View {
    VStack {
      Text("File to generate and download:")
      Text("\(environment.solutionName)")
        .italic()
        .foregroundColor(.blue)
        .background(.white)
    }
    .opacity(environment.shouldShowSolutionName ? 1 : 0)


    HStack {
      ProgressView("Loading")
      .opacity(environment.isDownloading ? 1 : 0)
    ProgressView("Computing")
      .opacity(environment.isComputing ? 1 : 0)
    ProgressView("Processing")
      .opacity(environment.isProcessing ? 1 : 0)
    }
  }
}

struct ComputationButton: View {
  @EnvironmentObject var environment: AppEnvironment
  @Binding var solutionSelection: Int

  @State var showThroughput = false
  static let defaultButtonText = "Start Computation"
  static let computingButtonText = "Please Wait"

  @State var buttonText = defaultButtonText
  public var body: some View {
    VStack {
      Button(buttonText){
        let solution = AstroSolutionEnum.allCases[$solutionSelection.wrappedValue]
        let solutionText = String(describing: solution)
        
        if (environment.isComputing == true)
        { return }
        else {
          environment.isComputing = true
          buttonText = Self.computingButtonText
          showThroughput = false
        }

        if ((solutionText == "La2004") || (solutionText == "La2011")) {
          let errorText = "Cannot compute solutions for La2004 or La2011:\n The underlying data have not been published / made available and are therefore not reproducible."
          print(errorText)
          #if os(WASI)
          let _ = JSObject.global.alert!(errorText)
          #endif
          environment.isComputing = false
          return
        }

        Task.detached(priority: .background) {
          await compute(solution: solutionText, environment: environment)
          environment.isComputing = false
          showThroughput = true
          buttonText = Self.defaultButtonText
        }
      }
      Text("Computation Throughput: \(String(format: "%6.1f", environment.throughput))")
        .opacity(showThroughput ? 1 : 0)
    }
  }
}

struct FgamCmarSelectionView: View {
  @EnvironmentObject var environment: AppEnvironment

  let fgamMin = 0.9800
  let fgamMax = 1.0200
  let fgamStep = 0.0005
  let cmarMin = 0.0
  let cmarMax = 2.0
  let cmarStep = 0.1
  
  var body: some View {
    let fgamProxy = Binding<Double>(
      get: { environment.fgam },
      set: {
        environment.fgam = $0
        environment.solutionName = environment.fileName()
      }
    )
    let cmarProxy = Binding<Double>(
      get: { environment.cmar },
      set: {
        environment.cmar = $0
        environment.solutionName = environment.fileName()
      }
    )

    VStack(alignment: .leading) {
      Slider(value: fgamProxy,
                 in: fgamMin...fgamMax,
                 step: fgamStep,
                 minimumValueLabel: Text("\(String(format: "%6.4f", fgamMin))"),
                 maximumValueLabel: Text("\(String(format: "%6.4f", fgamMax))")
      ) {
        
        Text("dynamical ellipticity: \(String(format: "%6.4f", environment.fgam))")
      }
      HStack {
        Text("dynamical ellipticity:")
        Text("\(String(format: "%6.4f", environment.fgam))")
          .foregroundColor(.blue)
          .background(.white)
          .padding(5)
      }
      Slider(value: cmarProxy,
             in: cmarMin...cmarMax,
             step: cmarStep,
             //onEditingChanged: { print("CMAR selected: \($0)") },
             minimumValueLabel: Text("\(String(format: "%3.1f", cmarMin))"),
             maximumValueLabel: Text("\(String(format: "%3.1f", cmarMax))")
      ) {
        Text("tidal dissipation: \(String(format: "%3.1f", environment.cmar))")
      }
      HStack {
        Text("tidal dissipation:")
        Text("\(String(format: "%3.1f", environment.cmar))")
          .foregroundColor(.blue)
          .background(.white)
          .padding(5)
      }
    }
  }
}

struct startMyrSelectionView: View {
  @EnvironmentObject var environment: AppEnvironment
  
  let startMyrMin: Double = 0.0
  var startMyrMax: Double {
    switch environment.solution {
      case .La1993:
        return 50.0
      case .La2004, .La2011:
        return 0.0
      case .La2010a, .La2010b, .La2010c, .La2010d:
        return 100.0
      case .ZB2017e, .ZB2018a:
        return 96.0
    }
  }
  let startMyrStep: Double = 1.0

  var body: some View {
    let startMyrProxy = Binding<Double>(
      get: { environment.startMyr },
      set: {
        environment.startMyr = $0
        environment.solutionName = environment.fileName()
      }
    )
    VStack(alignment: .leading) {
      Slider(value: startMyrProxy,
             in: startMyrMin...startMyrMax,
             step: startMyrStep,
             minimumValueLabel: Text("\(String(format: "%3.0f", startMyrMin)) Ma"),
             maximumValueLabel: Text("\(String(format: "%3.0f", startMyrMax)) Ma")
      ) {
        Text("Integrate from 0 to \(String(format: "%3.0f", environment.startMyr)) Ma")
      }
      HStack {
        Text("Integrate from 0 to")
        Text("\(String(format: "%3.0f", environment.startMyr))")
          .foregroundColor(.blue)
          .background(.white)
          .padding(5)
        Text("Ma")
      }
    }
  }
}

struct CustomDivider: View {
    let height: CGFloat = 1
    let color: Color = .white
    let opacity: Double = 0.2
    
    var body: some View {
        Group {
            Rectangle()
        }
        .frame(height: height)
        .foregroundColor(color)
        .opacity(opacity)
    }
}
