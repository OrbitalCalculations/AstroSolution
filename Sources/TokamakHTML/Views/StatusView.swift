//
//  StatusView.swift
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

public struct StatusView: View {
  @EnvironmentObject var environment: AppEnvironment
  public var body: some View {
    VStack {
      Text("File to generate and download:")
      Text("\(environment.solutionName)")
        .italic()
        .foregroundColor(.blue)
        .background(.white)
    }
    .opacity(environment.shouldShowSolutionName ? 1 : 0)
    /*HStack {
      ProgressView("Loading")
      .opacity(environment.isDownloading ? 1 : 0)
    ProgressView("Computing")
      .opacity(environment.isComputing ? 1 : 0)
    ProgressView("Processing")
      .opacity(environment.isProcessing ? 1 : 0)
    }*/
  }
}
