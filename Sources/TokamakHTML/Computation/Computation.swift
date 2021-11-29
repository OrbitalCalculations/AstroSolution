//
//  Computation.swift
//  
//
//  Created by Heiko Pälike on 20/11/2021.
//

import Foundation
import LNTBinaryCoding
import TokamakShim
import JavaScriptKit
import JavaScriptEventLoop
import OpenCombineShim
import OpenCombineJS

func compute(solution: String, environment: AppEnvironment, fgam: Double = 1.0, cmar: Double = 1.0, startMyr: Double = -25.0, endMyr: Double = 0.0) async {

  if ((solution == "La2004") || (solution == "La2011")) {
    print("cannot compute solutions for La2004 or La2011: These have not been published / made available.")
    return
  }
  
  print("starting COMPUTE")
  let fgam = environment.fgam
  let cmar = environment.cmar
  let startMyr = -1.0 * environment.startMyr
  //await Task.yield()
  let startMilliseconds = JSDate.now()
  guard let astroSolution = AstroSolutionEnum(rawValue: solution) else {
    print("cannot parse solution")
    return
  }
  
  print("selected arguments:")
  print("    fgam = \(fgam)")
  print("    cmar = \(cmar)")
  print("  endMyr = \(endMyr)")
  print("startMyr = \(startMyr)")
  print("astroSolution: \(astroSolution.rawValue)")
  
  var tkhqpdkdhdqdp: [[Double]] = [[Double]]()
  
  
  if !(environment.binary_option) {
    print("starting generate ELEMENTS")

    let tkhqp = await Task {await AstroSolutionEnum.returnTKHQP(astroSolution) }.value
    //print("tkhqp = \(tkhqp)")
    var t = [Double]()
    t.reserveCapacity(tkhqp.count)
    var k = [Double]()
    k.reserveCapacity(tkhqp.count)
    var h = [Double]()
    h.reserveCapacity(tkhqp.count)
    var q = [Double]()
    q.reserveCapacity(tkhqp.count)
    var p = [Double]()
    p.reserveCapacity(tkhqp.count)
    
    let idebut = Int(startMyr*1000.0) - 200//- Cherchel.nacd
    let ifin = Int(endMyr*1000.0) + 200 //+ Cherchel.nacd

    let filteredTkhqp = tkhqp.filter { $0[0] >= Double(idebut) && $0[0] <= Double(ifin) }

    switch astroSolution {
      case .La1993:
        filteredTkhqp.forEach({
          t.append($0[0])
          k.append($0[1])
          h.append($0[2])
          q.append($0[3])
          p.append($0[4])
        })
      case .La2010a, .La2010b, .La2010c, .La2010d:
        if (environment.verbosity_option) {
          print("Age(Ma)","a","l","Omega", "inc", "ecc", "varpi", "k", "h", "q", "p")
        }

        filteredTkhqp.forEach({
          let element = Keplerian(a: $0[1], l: $0[2], k: $0[3], h: $0[4], q: $0[5], p: $0[6])
          let new = unrotateFromInvariablePlane(element, t: $0[0], Omega0: -1.3257524502535283, i0: 0.02755113997947439, printVal: false /*verbosity_option*/)
          t.append($0[0])
          k.append(new.k)
          h.append(new.h)
          q.append(new.q)
          p.append(new.p)
        })
      case .ZB2017e, .ZB2018a:
        if (environment.verbosity_option) {
          print("Age(Ma)","a","l","Omega", "inc", "ecc", "varpi", "k", "h", "q", "p")
        }

        filteredTkhqp.forEach({
          let element = Keplerian(a: $0[1], l: $0[2], k: $0[3], h: $0[4], q: $0[5], p: $0[6])
          let new = unrotateFromSolarPlane(element, t: $0[0], Omega0: -179.9992488761977/180.0*Double.pi, i0: 7.150307688039328/180.0*Double.pi, printVal: false /*verbosity_option*/)
          //let new = unrotateFromSolarPlane(element, t: $0[0], Omega0: 75.594/180.0*Double.pi, i0: 7.150307688039328/180.0*Double.pi, printVal: verbosity_option.wasSet)

          t.append($0[0])
          k.append(new.k)
          h.append(new.h)
          q.append(new.q)
          p.append(new.p)
        })
      default:
        break
    }

    let kDeriv = HassanDiffArr().fDerivative(m: 1, o: 20, f: k, h: -1000.0)
    let hDeriv = HassanDiffArr().fDerivative(m: 1, o: 20, f: h, h: -1000.0)
    let qDeriv = HassanDiffArr().fDerivative(m: 1, o: 20, f: q, h: -1000.0)
    let pDeriv = HassanDiffArr().fDerivative(m: 1, o: 20, f: p, h: -1000.0)

    let minCount = min(t.count, k.count, h.count,q.count, p.count, kDeriv.count, hDeriv.count, qDeriv.count, pDeriv.count)
    //print(minCount)
    
    tkhqpdkdhdqdp = [Array(t[0..<minCount]),
                     Array(k[0..<minCount]),
                     Array(h[0..<minCount]),
                     Array(q[0..<minCount]),
                     Array(p[0..<minCount]),
                     Array(kDeriv[0..<minCount]),
                     Array(hDeriv[0..<minCount]),
                     Array(qDeriv[0..<minCount]),
                     Array(pDeriv[0..<minCount])]
      
    // print("Would write data to ELLDER.BIN, ELLDIR.TXT")
    
  } else { // binary Option
    print("starting downloading ELEMENTS")
    
    guard let array = await Task(operation: { await AstroSolutionEnum.returnBinaryElements(astroSolution, startMyr: startMyr) }).value else {
      print("Error obtaining data from \(String(describing: AstroSolutionEnum.binaryElmFileName(astroSolution, startMyr: startMyr)))")
      return
    }
    
    tkhqpdkdhdqdp = array
    print("success download ELEMENTS")
  }

  let nsample = 5
  
  //
  // MAIN INTEGRATION
  //

  let integration = IntegrationArr(fgam: fgam, cmar: cmar, step: 200.0, tkhqpdkdhdqdp: tkhqpdkdhdqdp, tkhqpdkdhdqdp_stepYears: 1000.0, solout: solout, nsample: nsample, environment: environment)
  print("progress:")
  print("********** | 100 Myr")

  print(">>>>>>INTEGRATION")
  integration.integrate(t1: startMyr)
  print("INTEGRATION<<<<<<")

  let age = Precession.ageMa
  let ecc = zip(tkhqpdkdhdqdp[1], tkhqpdkdhdqdp[2]).lazy.map{sqrt($0*$0+$1*$1)}
  let varpi = zip(tkhqpdkdhdqdp[2], tkhqpdkdhdqdp[1]).lazy.map{atan2($0,$1)}

  let obl = Precession.obl
  let psi = Precession.psi
  let precangle = zip(psi, varpi).lazy.map{$0+$1}
  let climprec = zip(ecc, precangle).lazy.map{$0*sin($1)}
  let pibar = zip(varpi, psi).lazy.map{fmod($0 + $1 + 2.0 * Double.pi, 2.0 * Double.pi)}
  let results: [[Double]] = [age,
                             Array(ecc),
                             obl,
                             Array(climprec),
                             Array(pibar),
                             psi,
                             Array(varpi),
                             Array(precangle)
                             ]

  let resultst = matrixTranspose(results)
  print()

  let rowCount = resultst.count
  var finalResultString = "Age(Ma)\tEccentricity\tObliquity(radians)\tClimatic Precession\tPiBar\tPsi\tVarPi\tPrecAngle\n"
  for i in 0..<rowCount {
    var columns: [String] = [String(format: "%   8.4f", resultst[i][0])]
    columns.append(contentsOf: resultst[i][1...7].map{String(format: "% 17.15f", $0)})
    finalResultString += columns.joined(separator: "\t")
    finalResultString += "\n"
  }
    
  let endMilliseconds = JSDate.now()
  let duration = (endMilliseconds - startMilliseconds)/1000.0
  print("Duration for \(rowCount) = \(duration)")
  let throughput = Double(rowCount)/duration
  print("Throughput = \(throughput) items/s")
  environment.throughput = throughput
  
  textToDownload(fileName: environment.fileName(), text: finalResultString)
  finalResultString = ""
  Precession.ageMa = []
  Precession.obl = []
  Precession.psi = []
  Holder.ind = 0
  print("Download done")
}

func textToDownload(fileName: String, text: String) {
  let document = JSObject.global.document
  var element = document.createElement("a")
  let blobConstructor = JSObject.global.Blob.function!

  let blobtype = ["type": "application/octet-stream"]

  let blob = blobConstructor.new([text.jsValue().string],
                                 blobtype.jsValue())
  let urlBase = JSObject.global.URL.function!
  let createObjectURLF = urlBase.createObjectURL.function!
  let url = createObjectURLF(blob)
  element.href = url
  element.download = fileName.jsValue()
  _ = document.body.appendChild(element)
  print("Should have downloaded \(fileName)")
   _ = element.click()
  _ = urlBase.revokeObjectURL.function!(url)
  _ = document.body.removeChild(element)

}


public struct Holder {
  public static var ind = 0
}

public struct Precession {
  public static var ageMa = [Double]()
  public static var obl = [Double]()
  public static var psi = [Double]()
}

@inlinable
func solout(_ k: Int, _ t: Double, _ y: (Double, Double)){
    let nsample = 5
  let a = -t * 0.000001 // convert from years to Myr
  let sineps = sqrt(y.0 * y.0 + y.1 * y.1)
  let eps = asin(sineps)
  let psi = atan2(y.1, y.0)
  if (Holder.ind % nsample == 0) {
        if (Holder.ind % (nsample * 10000) == 0) {print("*", terminator: "")}
        //print("\(a)\t\(eps)\t\(psi)")
        Precession.ageMa.append(a)
        Precession.obl.append(eps)
        Precession.psi.append(psi)
    }
    Holder.ind += 1
}
