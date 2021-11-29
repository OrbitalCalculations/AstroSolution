//
//  FiniteDifference.swift
//
//
//  Created by Heiko Pälike on 13/10/2020.
//

import Foundation
public struct HassanDiffArr {
  
  func sigTransposed(_ v: [Double], _ n: Int) -> [[Double]] {
    precondition(v.count == n)
    var result = [[Double]](repeating: [Double](repeating: 1.0, count: n), count: n)
    var s = result

    for k in 1...n {
      var vv = v
      vv[k-1] = v[0]
      for i in 1..<n {
        s[i][i] = s[i-1][i-1] * vv[i]
        if (i>1) {
          for j in (1...(i-1)).reversed() {
            s[i][j] = s[i-1][j-1] * vv[i] + s[i-1][j]
          }
        }
      }
      result[k-1] = s[n-1]
    }
    return result // is transposed
  }
  
  func factorial<N: Numeric & Comparable>(_ x: N) -> N  {
    precondition(x >= 0, "x must be non-negative")
    precondition(x < 21, "x must be <21 to be valid on Int64")
    return x == 0 ? 1 : x * factorial(x - 1)
  }
  
  //https://stackoverflow.com/questions/24196689/how-to-get-the-power-of-some-integer-in-swift-language
  func powint<T: BinaryInteger>(_ base: T, _ power: T) -> T {
      func expBySq(_ y: T, _ x: T, _ n: T) -> T {
          precondition(n >= -1)
        if n == -1 {
          return expBySq(y, 1 / x , 1);
        }
        else if n == 0 {
            return y
        } else if n == 1 {
            return y * x
        } else if n.isMultiple(of: 2) {
            return expBySq(y, x * x, n / 2)
        } else { // n is odd
            return expBySq(y * x, x * x, (n - 1) / 2)
        }
      }
      return expBySq(1, base, power)
  }
  
  func coeff(_ m: Int, _ O: Int, _ h: Double) -> [[Double]] {
    let n = m + O
    var result = [[Double]](repeating: [Double](repeating: 1.0, count: n), count: n)
    let k = Array(stride(from: 1.0, through: Double(n), by: 1.0))
    let factor = pow(Double(h), Double(m))
    let factorM = Double(factorial(m))
    for i in 1...n {
      let sigma = sigTransposed(k.map{$0-Double(i)}, n)
      for l in 1...n {
        let tmp1 = Double(powint(-1, l-m-1)) * factorM
        let tmp2 = Double(factorial(UInt64(l-1)) * factorial(UInt64(n-l))) * factor
        result[i-1][l-1] = sigma[l-1][n-m-1] * tmp1 / tmp2
      }
    }
    return result
  }
  
  func fDerivative(m: Int = 1, o: Int = 20, f: [Double], h: Double) -> [Double] {
    let n = m + o
    let c = coeff(m, o, h) //checked --- correct c.f. Matlab version
    var np: Int
    var coefU = [[Double]](repeating: [Double](repeating: 0.0, count: n+1), count: n+1)
    var coefM = [[Double]](repeating: [Double](repeating: 0.0, count: n+1), count: n+1)
    var coefL = [[Double]](repeating: [Double](repeating: 0.0, count: n+1), count: n+1)

    var intermediate = [[Double]](repeating:[Double](), count: n+1)
    
    var j: Int

    let reversed = Array(f[1...n].reversed())
    let initial = [Double](repeating: 2.0 * f[0], count: n)

    // Pad Vector
    let fnew: [Double] = (0..<n).map{ initial[$0] - reversed[$0]} + f // count = 2n
        
    //  Modifying the numerical stencil for a unified accuracy
    if ((m % 2) == 0 && (o % 2) != 0) {
      np = n + 1
      j = np / 2

      for i in 0..<(j-1) {
        coefU[i] = c[i] + [Double](repeating: 0.0, count: j-1)
      }
      coefM[0] = [0.0] + c[j-1]
      coefM[1] = c[j+1-1] + [0.0]
      for i in (0..<(np-j-1)) {
        coefL[i] = [0] + c[i+j]
      }

      intermediate[0..<(j-1)] = coefU[0..<(j-1)]
      intermediate[j...(j+1)] = coefM[0...1]
      intermediate[(j+2)..<(np+1)] = coefL[0..<(np-j-1)]
    } else {
      np = n
      intermediate = c
    }
    
    // Generating the derivative over the real domain of N nodes
    let N = f.count
    if N < np {
      fatalError("The size of the given data (\(N) should be greater than or equal to \(np). \n\t Try using larger set of data or decrease the accuracy order.")
    }
    if np % 2 == 0 {
      j = np / 2
    } else {
      j = (np + 1) / 2
    }
       
    var result = [Double](repeating: 0.0, count: N) //zeros(shape: N, type: Double.self)
   
    // upper -> forward
    let fnewArr = Array(fnew[0..<np])
    for i in 0..<(j-1) {
      result[i] = zip(intermediate[i], fnewArr).lazy.reduce(0, {$0 + $1.0 * $1.1})
    }
    
    // middle -> central
    for i in 0..<(N-np+1) {
      for k in 0..<N {
        if i==k {
          let fnewArr = Array(fnew[k...(k+np-1)])
          result[i+j-1] = zip(intermediate[j-1], fnewArr).lazy.reduce(0, {$0 + $1.0 * $1.1})
        }
      }
    }
    
    // lower -> backward
    for i in (j+1-1)..<np {
      let fnewArr = Array(fnew[(N-np)..<N])
      result[N-np+i] = zip(intermediate[i],fnewArr).lazy.reduce(0, {$0 + $1.0 * $1.1})
    }
    return Array(result[n..<N])
  }
}

