//
//  File.swift
//  
//
//  Created by wiggles on 02/12/2021.
//

import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

import Foundation
import Plotly

struct PlotlyView: View {
  @EnvironmentObject var environment: AppEnvironment
  
  func setupPlotly() {
    #if os(WASI)
    let document = JSObject.global.document
    let script = document.createElement("script")
//    let _ = script.setAttribute("src", "https://cdn.plot.ly/plotly-latest.min.js")
//  https://paloz.marum.de/AstroComputation/plotly-latest.min.js
    let _ = script.setAttribute("src", "./plotly-latest.min.js")

    let _ = document.head.appendChild(script)
    //_ = document.head.insertAdjacentHTML("beforeend", #"""
    //<link
    //  rel="stylesheet"
    //  href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css">
    //"""#)
    #endif
  }
  
  func plot() {
    let plotly = JSObject.global.Plotly.object!
    //let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
   //   PlotlySupport.plotlyConfig))
    
    let (x,y) = pAModelling.pAPrediction(fgam: environment.fgam, cmar: environment.cmar)
    //let x = [1.0, 2.0, 3.0, 4.0]
    //let y = [10.0, 15.0, 13.0, 17.0]
    let data: [Trace] = [
        Scatter(name: "pA", x: x, y: y)//,
        //Bar(name: "Bar", x: x, y: y)
    ]
    var figure = Figure(data: data)
    //figure.config.staticPlot = true
    //figure.config.responsive = true
    let encoder = JSONEncoder()
    guard let figureData = try? encoder.encode(figure),
          let jsonFigureData = String(data: figureData, encoding: .utf8) else {
            print("cannot encode figure")
            return
    }
    
    let _ = plotly.react!("66154CE9-D203-4126-89F4-837930B5EF87", JSObject.global.JSON.object!.parse!(
    jsonFigureData))
  }
  var body: some View {
    #if os(WASI)
    
    

    HTML("div", ["id":"66154CE9-D203-4126-89F4-837930B5EF87",
           "style":"width:600px;height:250px;",
           "min-height":"200px"
    ])/*.onAppear {
      //self.setupPlotly()
      self.plot()
  }*/
    
    #endif
    //EmptyView()
    
  }
}

