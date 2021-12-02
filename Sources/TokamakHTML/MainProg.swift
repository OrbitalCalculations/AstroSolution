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
import Plotly

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
  var body: some TokamakShim.Scene {
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

  
  func setupPlotly() {
    #if os(WASI)
    let document = JSObject.global.document
    let script = document.createElement("script")
    let _ = script.setAttribute("src", "https://cdn.plot.ly/plotly-latest.min.js")
    let _ = document.head.appendChild(script)
    //_ = document.head.insertAdjacentHTML("beforeend", #"""
    //<link
    //  rel="stylesheet"
    //  href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css">
    //"""#)
    #endif
  }
  
  var body: some View {
    let _ = setupPlotly()
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
        
        Group {
        AstroSolutionView(selection: solutionProxy)
        CustomDivider()
        
        StartMyrSelectionView()
        CustomDivider()
        
        FgamCmarSelectionView()
        CustomDivider()
        
        ComputationButton(solutionSelection: solutionProxy)
          .buttonStyle(BorderedProminentButtonStyle())
        CustomDivider()
        }
        
        
        Button("Plotly"){
          print("Plotly")
          let plotly = JSObject.global.Plotly.object!
          let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
            PlotlySupport.plotlyConfig))
          
          let x = [1.0, 2.0, 3.0, 4.0]
          let y = [10.0, 15.0, 13.0, 17.0]
          let data: [Trace] = [
              Scatter(name: "Scatter", x: x, y: y),
              Bar(name: "Bar", x: x, y: y)
          ]
          let figure = Figure(data: data)
          try! figure.show()
          
        }
        StatusView()
        PlotlyView()
        
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
