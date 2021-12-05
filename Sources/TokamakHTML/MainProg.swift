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
  init(){
    let _ = setupPlotly()
  }
  
  func setupPlotly() {
    #if os(WASI)
    let document = JSObject.global.document
    //let script = document.createElement("script")
    //let _ = script.setAttribute("src",
    //                             "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js")
    //let _ = document.head.appendChild(script)

    let script2 = document.createElement("script")
    let _ = script2.setAttribute("src", "https://cdn.plot.ly/plotly-latest.min.js")
    let _ = document.head.appendChild(script2)

    #endif
  }

  var body: some TokamakShim.Scene {
      WindowGroup("AstroSolution WebApp") {
        ScrollView(.vertical, showsIndicators: true) {
          ContentView()
        }
        .frame(height: 580)
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
        Text("Astronomical Solutions Tool")
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
        }
        StatusView()

        Button("Preview general precession in longitude plot"){
          let plotly = JSObject.global.Plotly.object!
          let (x,y) = pAModelling.pAPrediction(fgam: environment.fgam, cmar: environment.cmar)
          let _ = plotly.react!(
            "66154CE9-D203-4126-89F4-837930B5EF87",
            JSObject.global.JSON.object!.parse!(
              PlotlySupport.chartStudioTemplate(x: x, y: y, height: 210, width: 400))
          )
          
        }
        
        PlotlyView()
        Text("H. Pälike, 2021. AstroSolution: Zenodo v0.0.5.")
        Link("https://doi.org/10.5281/zenodo.5736415", destination: URL(string: "https://doi.org/10.5281/zenodo.5736415")!)
          .foregroundColor(.white)
          .background(.blue)
        Spacer()
      }.padding(10)
        
      .background(.gray)
      .onAppear {
          environment.solutionName = environment.fileName()
      }
      .environmentObject(environment)
      
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
