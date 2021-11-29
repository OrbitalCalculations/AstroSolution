//
//  MainProg.swift
//
//
//  Created by  Heiko Pälike on 11/11/2021.
//

import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

import Foundation
import LNTBinaryCoding

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WASILibc)
import WASILibc
#endif

let IPRT = 0

struct AstroSolutionApp: App {
    var body: some Scene {
      WindowGroup("AstroSolution WebApp") {
          ContentView()
      }
    }
}

struct ContentView: View {
  @State var fetchedSolutions: [AstroSolutions] = [AstroSolutions]()
  @State private var solutionSelection: Int = 0
  @State private var precomputedSelection: Int = 0
  
  @State private var usePrecomputedSolution: Bool = true
  @State private var parameterSelection: AstroParameter = AstroParameter(fgam: 1.0, cmar: 1.0)

  @State private var progress: Double = 0.0
  
  @State private var fgamText: String = "1.00"
  @State private var cmarText: String = "1.00"

  @StateObject var environment = AppEnvironment()

  
  var body: some View {
      let solutionProxy = Binding(
          get: { solutionSelection },
          set: { newValue in
              solutionSelection = newValue
            let solution = AstroSolutionEnum.allCases[newValue]
            environment.solution = solution
            environment.solutionName = environment.fileName()
            environment.shouldShowSolutionName = true
          }
      )
   
      VStack(alignment: .leading) {
        Text("Computation Tool for Astronomical Solutions")
          .bold()
          .font(.headline)

        
        HStack {
          AstroSolutionView(selection: solutionProxy)
          //TooltipView("Different astronomical solutions can be selected here. Please note that some are not (yet) available (La2004/La2011), as their orbital elements have not been published yet, and are therefore irreproducible.")
        }
        CustomDivider()
        startMyrSelectionView()
        CustomDivider()
        FgamCmarSelectionView()
        CustomDivider()
        ComputationButton(solutionSelection: solutionProxy)
          .buttonStyle(BorderedProminentButtonStyle())
        CustomDivider()
        StatusView()
    }.environmentObject(environment)
      .padding(10)
      .background(.gray)
      .onAppear {
        environment.solutionName = environment.fileName()
      }
  }
}

@main
struct Main {
  static func main() {
    JavaScriptEventLoop.installGlobalExecutor()
    AstroSolutionApp.main()
    print("AstroSolution Webapp ready.")
  }
}
