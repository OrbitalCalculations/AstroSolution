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
    //let _ = script.setAttribute("src", "https://paloz.marum.de/AstroComputation/plotly-latest.min.js")
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
        
        }
        CustomDivider()
        
        Button("Plotly"){
          print("Plotly")
          let plotly = JSObject.global.Plotly.object!
          let (x,y) = pAModelling.pAPrediction(fgam: environment.fgam, cmar: environment.cmar)
          
          let trace1 = Scatter(
            name: "general precession in longitude (pA)",
            x: x,
            y: y,
            mode: .lines,
            line: .init(
                color: 0x9748a1,
                width: 2
            ),
            xAxis: .init(
                //uid: 1,
                //mirror: .on,
                //tickLength: 4,
                //showTickLabels: false,
                //tickFont: .init(size: 10),
                showLine: true,
                //showGrid: true,
                //gridColor: 0xffffff,
                //zeroLine: false,
                domain: [-50000000.0, 0.0]
            ),
            yAxis: .init(
                //uid: 1,
                //mirror: .on,
                //tickLength: 4,
                //tickFont: .init(size: 10),
                //hoverFormat: ".2f",
                showLine: true,
                //showGrid: true,
                //gridColor: 0xffffff,
                //zeroLine: false,
                domain: [49.5, 53.5]
            )
          )
          trace1.xAxis.anchor = .yAxis(trace1.yAxis)
          trace1.yAxis.anchor = .xAxis(trace1.xAxis)

          
          let data: [Trace] = [trace1]
          
          let config = Config(staticPlot: true, responsive: true)
          let layout = Layout(height: 250.0, /*margin: Layout.Margin.init(autoExpand:true),*/ paperBackgroundColor: .lightGray/*, plotBackgroundColor: .gray*//*, xAxis: [XAxis(name: "Age(years)", tick0: 0.0, dTick: 5000.0)], yAxis: [YAxis(name: "pA", tick0: 50.0, dTick: 0.5)]*/)
          let figure = Figure(data: data, layout: layout, config: config)

          let encoder = JSONEncoder()
          guard let figureData = try? encoder.encode(figure),
                let jsonFigureData = String(data: figureData, encoding: .utf8) else {
                  print("cannot encode figure")
                  return
          }
          
          let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
          jsonFigureData))
          
        }
        //StatusView()
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
