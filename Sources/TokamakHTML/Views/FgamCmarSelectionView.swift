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
