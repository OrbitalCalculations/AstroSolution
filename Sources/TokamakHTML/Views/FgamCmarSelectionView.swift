//
//  FgamCmarSelectionView.swift
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

struct FgamCmarSelectionView: View {
  @EnvironmentObject var environment: AppEnvironment

  let fgamMin = 0.9975
  let fgamMax = 1.0025
  let fgamStep = 0.0005
  let cmarMin = 0.0
  let cmarMax = 2.0
  let cmarStep = 0.05
  
  var body: some View {
    let fgamProxy = Binding<Double>(
      get: { environment.fgam },
      set: {
        environment.fgam = $0
        environment.solutionName = environment.fileName()
        let plotly = JSObject.global.Plotly.object
        let (x,y) = pAModelling.pAPrediction(fgam: environment.fgam, cmar: environment.cmar)
        let _ = plotly?.react?(
          "66154CE9-D203-4126-89F4-837930B5EF87",
          JSObject.global.JSON.object!.parse!(
            PlotlySupport.chartStudioTemplate(x: x, y: y))
        )
      }
    )
    let cmarProxy = Binding<Double>(
      get: { environment.cmar },
      set: {
        environment.cmar = $0
        environment.solutionName = environment.fileName()
        let plotly = JSObject.global.Plotly.object
        let (x,y) = pAModelling.pAPrediction(fgam: environment.fgam, cmar: environment.cmar)
        let _ = plotly?.react?(
          "66154CE9-D203-4126-89F4-837930B5EF87",
          JSObject.global.JSON.object!.parse!(
            PlotlySupport.chartStudioTemplate(x: x, y: y))
        )
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
             minimumValueLabel: Text("\(String(format: "%4.2f", cmarMin))"),
             maximumValueLabel: Text("\(String(format: "%4.2f", cmarMax))")
      ) {
        Text("tidal dissipation: \(String(format: "%4.2f", environment.cmar))")
      }
      HStack {
        Text("tidal dissipation:")
        Text("\(String(format: "%4.2f", environment.cmar))")
          .foregroundColor(.blue)
          .background(.white)
          .padding(5)
      }
    }
  }
}
