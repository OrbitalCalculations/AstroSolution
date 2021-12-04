//
//  File.swift
//  
//
//  Created by wiggles on 03/12/2021.
//

import Foundation

struct pAModelling {
  static func pAPrediction(fgam: Double, cmar: Double) -> ([Double], [Double]) {
    
    let cp1_0 =  37.52660322621579069846
    let cp2_0 =  -0.00156517316835090223
    let cp3_0 =   0.00008260292831613919
    let cp4_0 =  34.81861759592058547241
    
    
    let oldestYear = -50000000.0
    let rdsc = 206264.80624709e0 // 180 * 3600 / π
    let aml = 17325593.437360e0/rdsc
    let om = 474659981.59713733/rdsc
    let cmar0 = -4.6e-18
    let eps0 = 0.40666
    let S0 = 0.5007
    let coseps0 = cos(eps0) //0.91844705998496
    let sineps0 = sin(eps0) //0.395543926770445
    let nu0 = 0.150019
    let p0 = 50.467718
    let p1 = -13.526564e-9
    let phi0 = 171.424
    
    let cp1 = cp1_0*fgam
    let cp2 = cp2_0*fgam
    let cp3 = cp3_0*fgam*fgam
    let cp4 = cp4_0*fgam
    
    let ak2 = cmar0 * 86400.0 * 365.25 * cmar
    let ak1 = 51.0 * ak2 * aml / om


    let x = Array(stride(from: 0.0, through: oldestYear, by: -500000.0))
    
    let y = x.map { years -> Double in
      let cor1 = 1.0 + ak1 * years
      let cor2 = 1.0 + 2.0 * ak2 * years
      return cor1 * (cor2 * (cp1 * coseps0 + cp2 * (2.0 * coseps0*coseps0 - 1.0)/sineps0 + cor2 * cp3 * (6.0 * coseps0*coseps0-1.0)) + cp4 * S0 * coseps0)
    }
    return (x,y)
  }
}
