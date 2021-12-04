//
//  PlotlyView.swift
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

struct PlotlyView: View {
  @EnvironmentObject var environment: AppEnvironment
  
  var body: some View {
    #if os(WASI)

    HTML("div", ["id":"66154CE9-D203-4126-89F4-837930B5EF87",
           "style":"width:600px;height:250px;",
           "min-height":"200px"])
    #endif
  }
}

