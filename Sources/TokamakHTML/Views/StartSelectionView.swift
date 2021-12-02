//
//  StartMyrSelectionView.swift
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

struct StartMyrSelectionView: View {
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
