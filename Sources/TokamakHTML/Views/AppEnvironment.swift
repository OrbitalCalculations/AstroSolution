//
//  AppEnvironment.swift
//  
//
//  Created by Heiko Pälike on 02/12/2021.
//

import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

import Foundation
import Plotly

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
    
    //updatePlot()
    
    return fileName
  }
  
  /*public func updatePlot(){
    print("Plotly onAppear ")
    return
    let window = JSObject.global.document.defaultView.object!
    
    print("window = \(window)")

    let eventListener = JSClosure.init( {_ in
      print("all loaded")
      
      let plotly = JSObject.global.Plotly.object!
      //let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
      //  PlotlySupport.plotlyConfig))
      
      let (x,y) = pAModelling.pAPrediction(fgam: self.fgam, cmar: self.cmar)
      //let x = [1.0, 2.0, 3.0, 4.0]
      //let y = [10.0, 15.0, 13.0, 17.0]
      let data: [Trace] = [
        Scatter(name: "pA", x: x, y: y, mode: .lines)//,
      ]
      
      let config = Config(staticPlot: true, responsive: true)
      let layout = Layout(height: 250.0, margin: Layout.Margin.init(autoExpand:true), paperBackgroundColor: .lightCyan/*, plotBackgroundColor: .gray*/)
      let figure = Figure(data: data, layout: layout, config: config)

      let encoder = JSONEncoder()
      guard let figureData = try? encoder.encode(figure),
            let jsonFigureData = String(data: figureData, encoding: .utf8) else {
              print("cannot encode figure")
              return JSValue.undefined
      }
      
      let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
      jsonFigureData))
      return JSValue.undefined
    })
    
    window.addEventListener!(JSValue.object(eventListener))
  }*/
}
