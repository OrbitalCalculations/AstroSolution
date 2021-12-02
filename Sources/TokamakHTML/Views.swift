//
//  Views.swift
//  
//
//  Created by Heiko Pälike on 11/11/2021.
//

import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

import Foundation


/*


public struct ParameterLabels: View {
    public var body: some View {
        HStack {
            Text("dyn. ellipticity")
            Text("tidal dissipation")
        }.foregroundColor(.primary)
    }
}

public struct Parameters: View {
    var selections = AstroSolutionEnum.allCases
    @Binding var selection: Int

    public var body: some View {
        Picker(
            selection: $selection,
            label: Text("Parameters")
        ) {
            Text("Please select:")
            ForEach(0..<availPrecomputedSelections.count) {
                Text("fgam: \(String(format: "%.2f", availPrecomputedSelections[$0].fgam)), cmar: \(String(format: "%.2f", availPrecomputedSelections[$0].cmar))")
                //Text(String(describing: availPrecomputedSelections[$0]))
            }
        }
  }
}


public struct UsePrecomputed: View {
    @Binding var isOn: Bool
    public var body: some View {
        Toggle(isOn: $isOn) {
            Text("use precomputed Solution")
        }
        .foregroundColor(.primary)
    }
}



*/
