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
    "\(solutionName)_(\(String(format: "%06.4f", fgam)),\(String(format:"%04.2f", cmar)))_0-\(startMyr)Ma.txt"
    
    
    return fileName
  }
}
