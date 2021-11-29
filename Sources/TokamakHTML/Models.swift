//
//  Models.swift
//  
//
//  Created by  Heiko Pälike on 11/11/2021.
//

//import Foundation
public struct AstroParameter: Codable, Hashable {
    let fgam: Double
    let cmar: Double
}

public struct AstroSolutions: Codable {
    let name: String
    let versions: [String]
}

let jsonAstroSolutions = """
[
{
"name": "La1993", "versions": []
},
{
"name": "La2004", "versions": []
},
{
"name": "La2010",  "versions": ["a", "b", "c", "d"]
},
{
"name": "La2011", "versions": []
},
{
"name": "ZB2017", "versions": ["e"]
},
{
"name": "ZB2018", "versions": ["a"],
}
]
"""

extension AstroSolutions: Identifiable {
  public var id: String { return self.name }
}

extension AstroSolutions: Equatable {
  public static func == (lhs: AstroSolutions, rhs: AstroSolutions) -> Bool {
      lhs.name == rhs.name && lhs.versions == rhs.versions
  }
}


public enum AstroSolutionEnum: String, Identifiable, Hashable, CaseIterable {
  case La1993
  case La2004
  case La2010a
  case La2010b
  case La2010c
  case La2010d
  case La2011
  case ZB2017e
  case ZB2018a
  public var id: String {self.rawValue}
  public var description: String {self.rawValue}
}

var astroSolutions = AstroSolutionEnum.allCases.map{$0.rawValue}

public var availPrecomputedSelections: [AstroParameter] = [
    AstroParameter(fgam: 1.0, cmar: 1.0),
    AstroParameter(fgam: 1.0, cmar: 0.0),
    AstroParameter(fgam: 1.0, cmar: 0.5)
]

