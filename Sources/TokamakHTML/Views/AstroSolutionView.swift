//
//  AstroSolutionView.swift
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

struct AstroSolutionView: View {
  var selections = AstroSolutionEnum.allCases
  @Binding var selection: Int

  public var body: some View {
    Picker(
      selection: $selection,
      label: Text("Astro Solution")
    ) {
      Text("Please select:")
      ForEach(0..<selections.count) {
          Text(String(describing: selections[$0]))
      }
    }
  }
}
