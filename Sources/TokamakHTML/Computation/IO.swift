//
//  readOrbits.swift
//
//  Created by Heiko Pälike on 19/09/2015.
//  Copyright © 2015 Heiko Pälike. All rights reserved.
//

import Foundation
import JavaScriptKit
import OpenCombine
import OpenCombineJS
import LNTBinaryCoding


public extension AstroSolutionEnum{
    
  static func returnTKHQP(_ sol: AstroSolutionEnum) async -> [[Double]] {
    var results = [[Double]]()
    guard let filePath = self.orbElmFileName(sol) else {
        fatalError("cannot get path")
    }
  
    let indices = self.tkhqp_indices(sol)
  
    var fileContent : String = ""
    print(filePath)
    do {
        let test = Task {
          try await JSPromise(JSObject.global.fetch.function!(filePath).object!)!.value
        }
        let result = try await JSPromise(test.value.text().object!)!.value
        print("Result received from \(filePath)")
        guard let receivedFile = result.string else {
          print("error converting JSValue to String in returnTKHQP")
          fatalError("ABORT")
        }
        fileContent = receivedFile
    }
    catch{
        print("error getting file. Error \(error)")
    }
      
    fileContent.enumerateLines(invoking: {
      fileContent, stop in
      
      let fileContent = fileContent.replacingOccurrences(of: "D", with: "E")
      let scanner = Scanner(string: fileContent)
      scanner.charactersToBeSkipped = NSCharacterSet.whitespaces
      
      var line = [Double]()
      var columnCount = 0
      while let doubleValue = scanner.scanDouble(representation: .decimal) {
        if indices.contains(columnCount) {
          line.append(doubleValue)
        }
        columnCount += 1
      }

      guard line.count == self.tkhqp_indices(sol).count else {
                print("line \(fileContent) does not appear to have \(self.tkhqp_indices(sol).count) elements")
                fatalError()
      }
      results.append(line)
    })
    return results
  }
    
  static private func tkhqp_indices(_ sol: AstroSolutionEnum) -> [Int]{
    switch sol {
    case .La1993:
      return [0, 1, 2, 3, 4]
    case .La2004:
      return [Int]()
    case .La2010a, .La2010b, .La2010c, .La2010d:
      return [0, 1, 2, 3, 4, 5, 6]
    case .La2011:
      return [Int]()
    case .ZB2017e, .ZB2018a:
      return [0, 1, 2, 3, 4, 5, 6]
    }
  }
	
    
  static private func orbElmFileName(_ sol: AstroSolutionEnum) -> String? {

    let basePath = "https://paloz.marum.de/fileStore/astroSolutions"

    switch sol {
    case .La1993:
      return [basePath, "la93", "ORBELN.ASC"].joined(separator: "/")
    case .La2004:
      return nil
            //return Path(components: [basePath,"/la04/INSOLN.LA2004.BTL.250.ASC"])
    case .La2010a:
      return [basePath, "la10", "l10a_k3l.dat"].joined(separator: "/")
    case .La2010b:
      return [basePath, "la10", "l10b_k3l.dat"].joined(separator: "/")
    case .La2010c:
      return [basePath, "la10", "l10c_k3l.dat"].joined(separator: "/")
    case .La2010d:
      return [basePath, "la10", "l10d_k3l.dat"].joined(separator: "/")
    case .La2011:
      return nil
    case .ZB2017e:
      return [basePath, "ZB17e", "ZB17e_alkhqp.txt"].joined(separator: "/")
    case .ZB2018a:
      return [basePath, "ZB18a", "ZB18a_alkhqp.txt"].joined(separator: "/")
    }
  }
	
  static func binaryElmFileName(_ sol: AstroSolutionEnum, startMyr: Double) -> String? {
    let basePath = "https://paloz.marum.de/fileStore/astroSolutions/Elements"

    var suffix = String(format:"%05.2f", Double(Int(ceil(max(5.0,-startMyr)/5.0)*5.0+1.0)))
    if sol == .La1993 {
      suffix = suffix.replacingOccurrences(of: "51.00", with: "50.48")
    }
    
    if ((sol == .ZB2017e) || (sol == .ZB2018a)) {
      suffix = suffix.replacingOccurrences(of: "101.00", with: "99.98")
    }
    print("suffix=\(suffix)")
    switch sol {
    case .La1993:
        return [basePath, "La1993", "La93ELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .La2004:
        return nil
    case .La2010a:
        return [basePath, "La2010a", "La10aELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .La2010b:
        return [basePath, "La2010b", "La10bELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .La2010c:
        return [basePath, "La2010c", "La10cELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .La2010d:
        return [basePath, "La2010d", "La10dELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .La2011:
        return nil
    case .ZB2017e:
        return [basePath, "ZB2017e", "ZB17eELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    case .ZB2018a:
        return [basePath, "ZB2018a", "ZB18aELLDER_0-\(suffix).BIN.base64"].joined(separator: "/")
    }
	}
  
  static func returnBinaryElements(_ sol: AstroSolutionEnum, startMyr: Double) async -> [[Double]]? {
    guard let filePath = Self.binaryElmFileName(sol, startMyr: startMyr) else {
        fatalError("cannot get path for binary Elements of solution \(sol)")
    }
    print("Task returnBinaryElements init, filePath: \(filePath)")
    do {
      let test = Task {
        try await JSPromise(JSObject.global.fetch.function!(filePath).object!)!.value
      }
      let result = try await JSPromise(test.value.text().object!)!.value
      print("Result received from \(filePath)")
      guard let receivedFile = result.string else {
        print("error converting JSValue to String in returnBinaryElements")
        return nil
      }
      guard let base64DecodedData = Data(base64Encoded: receivedFile) else {
        print("error decoding Base64 in returnBinaryElements")
        return nil
      }
     
      let decoder = BinaryDecoder()
      let finalArray = try decoder.decode([[Double]].self, from: base64DecodedData)
      print("finalArray counts:",finalArray.count, finalArray[0].count)
      return finalArray
    }
    catch{
      print("error getting file. Error \(error)")
      return nil//resultData
    }
  }
    
  static private func eccFileName(_ sol: AstroSolutionEnum) -> String? {
    let basePath = "" //rp //Path(rp).string
    switch sol {
    case .La1993:
      return [basePath,"la93", "ORBELN.ASC"].joined(separator: "/")
    case .La2004:
      return nil
        //return Path(components: [basePath,"/la04/INSOLN.LA2004.BTL.250.ASC"])
    case .La2010a:
      return [basePath,"la10", "l10a_k3l.dat"].joined(separator: "/")
    case .La2010b:
      return [basePath,"la10", "l10b_k3l.dat"].joined(separator: "/")
    case .La2010c:
      return [basePath,"la10", "l10c_k3l.dat"].joined(separator: "/")
    case .La2010d:
      return [basePath,"la10", "l10d_k3l.dat"].joined(separator: "/")
    case .La2011:
      return nil
    case .ZB2017e:
      return nil
    case .ZB2018a:
      return nil
    }
  }
}
