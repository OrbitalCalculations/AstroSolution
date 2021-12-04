//
//  ComputationButton.swift
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
