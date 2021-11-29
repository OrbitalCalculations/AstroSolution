//
//  IntegrationArr.swift
//  
//
//  Created by Heiko Pälike on 23/11/2021.
//

import Foundation
import TokamakShim


struct IntegrationArr {
  var apg: Double
  
  var cp1: Double
  var cp2: Double
  var cp3: Double
  var cp4: Double
  
  var ak1: Double
  var ak2: Double
  
  var maree = true //Tides
  
  var fgam: Double
  var cmar: Double
  
  var akix0: Double
  var akiy0: Double
  
  var tkhqpdkdhdqdp: [[Double]]
  var tkhqpdkdhdqdp_stepYears: Double
    
  var adams: AdamsArr
  var dopri8: Dopri8Arr
  
  var step: Double
  
  var solout: soloutTypeArr
  var nsample: Int
  
  var environment: AppEnvironment
}

extension IntegrationArr {
    /**
     ***********************************************************************
           EVALUATION DU SECOND MEMBRE DES EQUATIONS DE LA PRECESSION
     
      A L'ENTREE:
       nd:dimension du systeme differentiel
       tps:date a laquelle on evalue le second membre
       aki(nd):variables utilisees l'integration des equations de precession
              aki(1)=sin(eps)cos(psi)
              aki(2)=sin(eps)sin(psi)
     
      EN SORTIE:
       Dki(nd):tableau des second membres
     
     ***********************************************************************
     */
    //nd,tps,aki,Dki
    @inlinable
    func fcn(_ tps: Double, _ aki: (Double, Double), _ dki: inout (Double, Double)) {
      let telor = self.telorAsync(tps: tps)
      guard telor.count > 0 else {
        fatalError("cannot get elements in telor")
      }
      //let dki_init = dki
      dki = precess(
        t: tps,
        ak: telor[0],
        ah: telor[1],
        aq: telor[2],
        ap: telor[3],
        dk: telor[4],
        dh: telor[5],
        dq: telor[6],
        dp: telor[7],
        aki: aki)
      //let dki_final = dki
      //print("fcn: aki: \(aki) dki_init: \(dki_init), dki_final: \(dki_final)")
    }
}

extension IntegrationArr {
    mutating func initFcn() {
        self.adams.fcn = fcn
        self.dopri8.fcn = fcn
    }
}

func matrixTranspose<T>(_ matrix: [[T]]) -> [[T]] {
  if matrix.isEmpty {return matrix}
  var result = [[T]]()
  //print(matrix.count)
  //print(matrix.map{$0.count})
  for index in 0..<matrix.first!.count {
    result.append(matrix.map{$0[index]})
  }
  //print("result matrixTranspose")
  //print(result.count, result[0].count)
  return result
}


extension IntegrationArr {
    /**
       INIPRE  INITIALISATION DE LA PRECESSION POUR LA TERRE
    (c) Astronomie et Systemes Dynamiques, Bureau des Longitudes (1993)
     */
  init(fgam: Double = 1.0,
    cmar: Double = 1.0,
    printDebug: Bool = true,
    step: Double = 200.0,
    dopri8: Dopri8Arr = Dopri8Arr(),
    tkhqpdkdhdqdp: [[Double]],
    tkhqpdkdhdqdp_stepYears: Double,
    //fcn: @escaping fcnType,
    solout: @escaping soloutTypeArr,
       nsample: Int = 5, environment: AppEnvironment) {
    
    //if let callBack = callBack {
    //  self.callBack = callBack
    //}
    self.environment = environment
    self.adams = AdamsArr(m: 12/*, n: 2*/, step: 200.0, environment: environment)
    self.fgam = fgam
    self.cmar = cmar
    //self.fcn = fcn
    self.solout = solout
    self.nsample = nsample
    self.step = step
    self.tkhqpdkdhdqdp = tkhqpdkdhdqdp
    //self.tkhqpdkdhdqdpT = matrixTranspose(tkhqpdkdhdqdp)
    self.tkhqpdkdhdqdp_stepYears = tkhqpdkdhdqdp_stepYears
    precondition(tkhqpdkdhdqdp.count == 9)
//    self.adams = adams
//    self.adams.fcn = fcn
    self.adams.step = self.step
    self.adams.solout = self.solout
    self.dopri8 = dopri8
    self.dopri8.solout = self.solout
//    self.dopri8.fcn = fcn
    

    let cmar0: Double = -4.6e-18
    
    let rm0 = 496303.3e-6 // Kinoshita 1977 constants M0-3
    let rm1 = -20.7e-6
    let rm2 = -0.1e-6
    let rm3 = 3020.2e-6
    
    let rs0 = 500209.034508230784e-6   //S0
    let rs2 = 0.2e-6
    let rdsc = 206264.80624709e0 // 180 * 3600 / π
    let eps0 = (23.0 * 3600.0 + 26.0 * 60.0 + 21.448e0) / rdsc // 0.40909280422234157
    //23.439291111111835
    //0.409092804222342
    //0.40909280422234157
    self.akix0 = sin(eps0)  //sin(eps)cos(psi) aki(1)
    self.akiy0 = 0.0    //sin(eps)sin(psi) aki(2)
    
    let gk = 0.01720209895e0 * 365.25e0 //k
    let taml = 1.0/270_68736.47e0
    let tamt = 1.0/332_946.0e0 // mE/m☉
    let tams = 1.0e0
    let al = 384_747.981e0/1.495_978_701e8 // aM/aS
    let `as` = 1.000_001_017_78e0
    
    let om = 474659981.59713733/rdsc // 2301.2165295349987
    //let om_orig = 72.921151467e-6 * 86400.0*365.25 //omega in Laskar1986
    // 474659981.59757 "/yr = 15.041067178669164 "/s * 86400*365.25
    // = 72.921151467e-6 / 2 / π * 360 * 3600 * 86400*365.25
    let amn = -190.771235e0 * 365.25/rdsc
    let aml = 17325593.437360e0/rdsc // //nM, arcsec/yr  / rdsc
    let bp0 = 101_803_910e-15
    let apuai = 5029.0966e0/rdsc/100.0 //Precession constant IERS2000
    let app = apuai + 2.0 * bp0 / tan(eps0)
    self.apg = 1.92e0/rdsc/100.0
    let apls = app + self.apg
    let rkl = 3.0 * gk*gk * taml/(al * al * al)/om          // lunar
    let rks = 3.0 * gk*gk * tams/(`as` * `as` * `as`)/om    // solar
    let xl0 = (rm0 - rm2/2.0) * cos(eps0)  //Equations (3) from La1993, (24) in Laskar1986
    let xl1 =  rm1 * cos(2.0 * eps0)/sin(eps0)
    let xl3 = -rm3 * taml/(taml+tamt)*aml*aml/amn/om*(6.0 * pow(cos(eps0),2)-1.0)
    let xs = (rs0-rs2/2.0) * cos(eps0)
    let aa = rkl * xl3
    let bb = rkl * (xl0 + xl1) + rks * xs
    let cc = -apls
    let eld = (-bb + sqrt(bb*bb - 4.0*aa*cc))/2.0/aa
        

    let rfl0 = rkl * eld*xl0*rdsc
    let rfl1 = rkl * eld*xl1*rdsc
    let rfl3 = rkl * eld*eld*xl3*rdsc
    let rfs  = rks * eld*xs*rdsc
    
    let cp1 =  rkl*eld*(rm0-rm2/2.0)
    let cp2 =  rkl*eld*rm1
    let cp3 = -rkl*eld*eld*rm3*taml/(taml+tamt)*aml*aml/amn/om
    let cp4 =  rks*eld

    //Adjust dynamical ellipticity
    self.cp1 = cp1 * fgam
    self.cp2 = cp2 * fgam
    self.cp3 = cp3 * fgam * fgam
    self.cp4 = cp4 * fgam
        
    // Adjust for tides
    // Constants to take tides into effect
    /*
     Using elementary deriva- tions and constants from [19] but correcting a mistake in [19] by using :
     nM0/nM0 = -4.6e-18s-1 instead of 𝜈 0/0
     */
    self.ak2 = cmar0 * 86400.0 * 365.25 * cmar
    self.ak1 = 51.0 * ak2 * aml / om
    
    if (printDebug) {
      print()
      print("Information for internal check")
      print()
      print("Earth angular velocity:")
      print("    \(om * rdsc)")
      print("precession of right ascension:")
      print("         \(app * rdsc * 100.0)")
      print()
      print("eld :     \(String(format: "% 24.20f", eld))")
      print("rfl0:     \(String(format: "% 24.20f", rfl0))")
      print("rfl1:     \(String(format: "% 24.20f", rfl1))")
      print("rfl3:     \(String(format: "% 24.20f", rfl3))")
      print("rfs :     \(String(format: "% 24.20f", rfs))")
      print("rfl0+rfl1+rfl3+rfs :")
      print("          \(String(format: "% 24.20f", rfl0+rfl1+rfl3+rfs))")
      print()
      print("cp1, cp2, cp3, cp4 in arcseconds/a ")
      print("cp1:      \(String(format: "% 24.20f", self.cp1 * rdsc))")
      print("cp2:      \(String(format: "% 24.20f", self.cp2 * rdsc))")
      print("cp3:      \(String(format: "% 24.20f", self.cp3 * rdsc))")
      print("cp4:      \(String(format: "% 24.20f", self.cp4 * rdsc))")
      print()
      print("ak1:      \(String(format: "% 24.20f", ak1))")
      print("ak2:      \(String(format: "% 24.20f", ak2))")
      print()
    }
        
    self.initFcn()
  }
}

extension IntegrationArr {
  /*
   ***********************************************************************
   *   SECOND MEMBRE DES EQUATIONS DE LA PRECESSION POUR LA TERRE        *
   *   CORRIGE POUR TENIR COMPTE DES EFFETS DE MAREES                    *
   *                                                                     *
   *  (c) Astronomie et Systemes Dynamiques, Bureau des Longitudes (1993)*
   ***********************************************************************
   */
  func precess(
    t: Double,
    ak: Double, ah: Double, aq: Double, ap: Double,
    dk: Double, dh: Double, dq: Double, dp: Double,
    aki: (Double, Double)) -> (Double, Double) {
      
    //precondition(aki.count == 2)
    let (akix, akiy) = aki
    let akixsq = akix*akix
    let akiysq = akiy*akiy
    // let x = cos(𝜀)
    let x = sqrt(1.0 - (akixsq + akiysq))
    let sineps = sqrt(akixsq + akiysq)
    let rs = pow((1.0-ak*ak-ah*ah), -1.5)/2.0 - 0.522e-6 // S0
    let cor1 = 1.0 + ak1 * t // (1 + nu'/nu t) Eq 33
    let cor2 = 1.0 + 2.0 * ak2 * t //(1 + nM0'/nM0 t) Eq 33
    
    let rtot = cor1 * (cor2 *
                        (cp1 * x
                            + cp2 * (2.0 * x*x - 1.0)/sineps // cos(2𝜀) = 2cos^2(𝜀) - 1
                            + cor2 * cp3 * (6.0 * x*x-1.0))
                        + cp4 * rs * x) // Eq 25 La1993
    
    let cc = aq * dp - ap * dq
    let dd = 2.0 / sqrt(1.0 - ap * ap - aq * aq)
    let aa = dd * (dq + ap * cc)
    let bb = dd * (dp - aq * cc)
    
    let coef = rtot - 2.0 * cc - apg // R'(𝜀) Eq 23, apg Eq7
    
    let dkix = -akiy * coef + aa * x
    let dkiy =  akix * coef - bb * x
    
    // d𝜒/dt = iR'(𝜀) 𝜒 + cos(𝜀)*(A - iB)
    return (dkix, dkiy)
  }
}

/**
Integration betweein 0 and t1 (in millions of years) with step size step (in years)
Uses routines
- solout
- fcn: Calculation of 2nd members
*/
extension IntegrationArr {
  func integrate(t1: Double) {
    let m = adams.m
    let posneg = (t1 < 0 ? -1.0 : 1.0)
    let pas = step * posneg

    var tfin = t1 * 1e6 //+ posneg * Double(nacd/2) * 1000
    print("tfin = \(tfin)")
    var t0 = 0.0
    var aki = (akix0, akiy0)
    var valyp = ([Double](repeating: 0.0, count: m), [Double](repeating: 0.0, count: m))

    print("aki0=",aki)
    dopri8.depart(x0: &t0, step: pas, m: m, y: &aki, valyp: &valyp)
    print("aki1=",aki)

    adams.integrate(x0: t0, xfin: &tfin, step: pas, yn: &aki, valyp: &valyp)
  }
}

extension IntegrationArr {
  func telorAsync(tps: Double) -> [Double] {
    let ni = 8
    let nbf = 8
    let idxfirst = 0
    let idxlast = tkhqpdkdhdqdp[0].count - 1
    let tfirst = tkhqpdkdhdqdp[0][idxfirst] * 1000.0
    let tlast = tkhqpdkdhdqdp[0][idxlast] * 1000.0 // now in years, like tps
    guard (tps <= tfirst && tps >= tlast) else {
      fatalError("cannot process tps(\(tps) outside of [\(tlast), \(tfirst)]")
    }

    let ctrlIdx = Int(Double(idxlast)*(tps-tfirst)/(tlast-tfirst))

    var rngFirst = ctrlIdx - ni/2
    if (rngFirst < 0) {
      rngFirst = 0
    }

    var rngLast = rngFirst + (ni-1)
    if (rngLast > idxlast) {
      rngLast = idxlast
      rngFirst = idxlast - (ni-1)
    }

    let range = rngFirst...rngLast
    let xa = tkhqpdkdhdqdp[0][range].map {$0 * 1000.0}

    var ya = [[Double]]()
    for idx in 1...nbf {
      let mapped = Array(tkhqpdkdhdqdp[idx][range])
      ya.append(mapped)
    }
    let result = pint2(xavec: xa, yamat: ya, n: range.count, x: tps, nbf: nbf)
    return result
  }
  
  func telor(tps: Double) -> [Double] {
    let ni = 8
    let nbf = 8
    let idxfirst = 0
    let idxlast = tkhqpdkdhdqdp[0].count - 1
    let tfirst = tkhqpdkdhdqdp[0][idxfirst] //* 1000.0
    let tlast = tkhqpdkdhdqdp[0][idxlast] //* 1000.0 // now in years, like tps
    guard (tps <= tfirst && tps >= tlast) else {
      fatalError("cannot process tps(\(tps) outside of [\(tlast), \(tfirst)]")
    }

    let ctrlIdx = Int(Double(idxlast)*(tps-tfirst)/(tlast-tfirst))
  
    var rngFirst = ctrlIdx - ni/2
    if (rngFirst < 0) {
      rngFirst = 0
    }
    var rngLast = rngFirst + (ni-1)
    if (rngLast > idxlast) {
      rngLast = idxlast
      rngFirst = idxlast - (ni-1)
    }
    let range = rngFirst...rngLast
    let xa = tkhqpdkdhdqdp[0][range].map {$0 * 1000.0}
    let ya = tkhqpdkdhdqdp[1...nbf].map{Array($0[range])}

    let result = pint2(xavec: xa, yamat: ya, n: range.count, x: tps, nbf: nbf)
    return result
  }
}

extension IntegrationArr {
  
  //https://gist.github.com/r-lyeh-archived/2fe8b91b67aa693d5238
  func neville(x0: Double, x: [Double], y: [Double]) -> Double {
    let n = x.count
    assert(n==8, "Expecting count of 8 in neville")
    var result = y
    
    for j in 1..<n {
      for i in (j...(n-1)).reversed() {
        result[i] = ( (x0 - x[i-j] ) * result[i] - ( x0 - x[i] ) * result[i-1] ) / ( x[i] - x[i-j] )
      }
    }
    return result[n-1]
  }
  
  func pint2(xavec: [Double], yamat: [[Double]], n: Int, x: Double, nbf: Int) -> [Double] {
    struct Holder {
      static var  y = [Double](repeating: 0.0, count: 8)
      static var dy = [Double](repeating: 0.0, count: 8)
      static var  c = [Double](repeating: 0.0, count: 8)
      static var  d = [Double](repeating: 0.0, count: 8)
    }
    
    let xa = xavec
    let ya = yamat
    
    for nvar in 0..<nbf {
      var ns = 0
      var dif = abs(x-xa[0])
      for i in 0..<n {
        let dift = abs(x-xa[i])
        if (dift < dif) {
          ns = i
          dif = dift
        }
      }
      Holder.c = ya[nvar]
      Holder.d = ya[nvar]

      Holder.y[nvar] = ya[nvar][ns]
      ns -= 1
      for m in 1..<n {
        for i in 0..<(n-m) {
          let ho = xa[i] - x
          let hp = xa[i+m] - x
          let w = Holder.c[i+1] - Holder.d[i]
          var den = ho - hp
          precondition (den != 0, "denominator in pint is zero!")
          den = w / den
          Holder.d[i] = hp * den
          Holder.c[i] = ho * den
        }
        if (2*ns < (n-m)) {
          Holder.dy[nvar] = Holder.c[ns+1]
        } else {
          Holder.dy[nvar] = Holder.d[ns]
          ns -= 1
        }
        Holder.y[nvar] += Holder.dy[nvar]
      }
    }
    return Holder.y
  }
}


/**-------------------------------------------------------------------------
    methode d'integration d'un systeme y'=f(x,y)
    par la methode d'Adams du type predicteur/correcteur
    ------>   algorithme ordinaire <-------
     Frederic Joutel (*m/4)
     (c) ASD/BdL - 5/1991 -
     modifie le 26/8/92 pour des appels multiples -
--------------------------------------------------------------------------
*/

typealias fcnTypeArr = /*@escaping*/ (_ x: Double, _ y: (Double, Double), _ f: inout (Double, Double)) -> ()
typealias soloutTypeArr = (_ k: Int, _ t: Double, _ y: (Double, Double)) -> ()

struct AdamsArr {
  var m = 12 // order (m<=16)
  static let nmax = 51 // maximum dimension of system
  let n = 2
//  var n = 2 // system dimension (n<=nmax)
  
  var fcn: fcnTypeArr!
  var solout: soloutTypeArr

  var pred: ([Double], [Double]) //  = empty((2, m), type: Double)
  var corr: ([Double], [Double]) //  = empty((2, m), type: Double)
  var step: Double
  
  var environment: AppEnvironment
    
  init(m: Int = 12, n: Int = 2, step: Double = 200.0/*, currentProgress: Binding<Float>*/, environment: AppEnvironment) {
    self.environment = environment
    precondition(m==12, "The routine initcoef for Adams is setup for order 12 (\(m) requested)")
    precondition(n <= Self.nmax, "dimension of system \(n) > nmax (\(Self.nmax))")
    self.m = m
    self.step = step

    self.solout = {k, t, y in
      print("======>adams default solout")
      let a = t * 0.001 //conversion du temps en milliers d'annees
      let sineps = sqrt(y.0*y.0 + y.1*y.1)
      let eps = asin(sineps)
      let psi = atan2(y.1, y.0)
      print(a, eps, psi)
    }
    
    self.pred = ([
        -0.4777223000000000e+07,  // pred( 0,1)
         0.3008230900000000e+08,  // pred( 1,1)
        -0.1741024827100000e+11,  // pred( 2,1)
         0.9236366290000000e+09,  // pred( 3,1)
        -0.6255517490000000e+09,  // pred( 4,1)
         0.3518392888300000e+11,  // pred( 5,1)
        -0.4129027322900000e+11,  // pred( 6,1)
         0.3568989256100000e+11,  // pred( 7,1)
        -0.1506437297300000e+11,  // pred( 8,1)
         0.1232664543700000e+11,  // pred( 9,1)
        -0.6477936721000000e+10,  // pred(10,1)
         0.4527766399000000e+10], // pred(11,1)
        [0.1741824000000000e+08,  // pred( 0,2)
         0.9123840000000000e+07,  // pred( 1,2)
         0.9580032000000000e+09,  // pred( 2,2)
         0.1520640000000000e+08,  // pred( 3,2)
         0.4561920000000000e+07,  // pred( 4,2)
         0.1596672000000000e+09,  // pred( 5,2)
         0.1596672000000000e+09,  // pred( 6,2)
         0.1596672000000000e+09,  // pred( 7,2)
         0.1064448000000000e+09,  // pred( 8,2)
         0.1916006400000000e+09,  // pred( 9,2)
         0.3193344000000000e+09,  // pred(10,2)
         0.9580032000000000e+09]) // pred(11,2)
    
    
    self.corr = ([
       0.4671000000000000e+04,    // cor( 0,1)
        -0.6892878100000000e+08,  // cor( 1,1)
         0.3847093270000000e+09,  // cor( 2,1)
        -0.8706474100000000e+08,  // cor( 3,1)
         0.5012899030000000e+09,  // cor( 4,1)
        -0.9191049100000000e+08,  // cor( 5,1)
         0.1007253581000000e+10,  // cor( 6,1)
        -0.1022122330000000e+09,  // cor( 7,1)
         0.3646503700000000e+08,  // cor( 8,1)
        -0.9964241300000000e+08,  // cor( 9,1)
         0.1374799219000000e+10,  // cor(10,1)
         0.4777223000000000e+07], // cor(11,1)
        [0.7884800000000000e+06,  // cor( 0,2)
         0.9580032000000000e+09,  // cor( 1,2)
         0.9580032000000000e+09,  // cor( 2,2)
         0.6386688000000000e+08,  // cor( 3,2)
         0.1596672000000000e+09,  // cor( 4,2)
         0.1774080000000000e+08,  // cor( 5,2)
         0.1596672000000000e+09,  // cor( 6,2)
         0.1774080000000000e+08,  // cor( 7,2)
         0.9123840000000000e+07,  // cor( 8,2)
         0.4561920000000000e+08,  // cor( 9,2)
         0.9580032000000000e+09,  // cor(10,2)
         0.1741824000000000e+08]) // cor(11,2)
  }
}

extension AdamsArr {
  func integrate(x0: Double, xfin: inout Double, step: Double, yn: inout (Double, Double), valyp: inout ([Double],[Double])) {
    let count = valyp.0.count
    precondition(count == m, "valyp does not have Shape (\(2),\(m)")
    let posneg = ((xfin-x0) < 0.0) ? -1.0 : 1.0
    let h = abs(step) * posneg
    let nbre = Int(abs((xfin-x0)/step))
    print("nbre=\(nbre)")
    var y1 = yn
    // main loop
    var x = x0
    for k in 1...nbre {
      //if (k % 10000 == 0){
      //  let fraction = Double(k)/Double(nbre)
      //  print("Progress: \(String(format: " %5.1f", fraction*100.0))%")
      //}
      //callBack(Double(k)/Double(nbre))
      //Task {
        //await MainActor.run {
      //environment.computationProgress = Double(k)/Double(nbre)
      //Task.yield()

        //}
      //}
      
      x = x0 + Double(k) * h

      // prediction
      var tmp = (0.0, 0.0)
      for j in 0..<m {
        tmp.0 += pred.0[j] * valyp.0[j]/pred.1[j]
        tmp.1 += pred.0[j] * valyp.1[j]/pred.1[j]
      }
      y1 = yn
      y1.0 += h * tmp.0
      y1.1 += h * tmp.1

      // evaluation
      var f = (0.0, 0.0)
      fcn(x, y1, &f)
      for j in 0..<(m-1) {
        valyp.0[j] = valyp.0[j+1]
        valyp.1[j] = valyp.1[j+1]
      }
      valyp.0[m-1] = f.0
      valyp.1[m-1] = f.1

      // correction
      var tmp2 = (0.0, 0.0)
      for j in 0..<m {
        tmp2.0 += corr.0[j] * valyp.0[j]/corr.1[j]
        tmp2.1 += corr.0[j] * valyp.1[j]/corr.1[j]
      }
      y1 = yn
      y1.0 += h * tmp2.0
      y1.1 += h * tmp2.1

      // evaluation
      fcn(x, y1, &f)
      valyp.0[m-1] = f.0
      valyp.1[m-1] = f.1
      yn = y1
      self.solout(k, x, yn)
    }
    xfin = x
  }
}

/**
       NUMERICAL SOLUTION OF A SYSTEM OF FIRST ORDER
       ORDINARY DIFFERRENTIAL EQUATIONS Y'=F(X,Y).
       THIS IS AN EMBEDDED RUNGE-KUTTA METHOD OF ORDER (7)8
       DUE TO DORMAND & PRINCE (WITH STEPSIZE CONTROL).
       C.F. SECTION II.6

       PAGE 435 HAIRER, NORSETT & WANNER

       INPUT PARAMETERS:
       ----------------
       - N            DIMENSION OF THE SYSTEM ( N.LE.51)
       - FCN          NAME (EXTERNAL) OF SUBROUTINE COMPUTING THE
                    FIRST DERIVATIVE F(X,Y):
                      SUBROUTINE FCN(N,X,Y,F)
                      REAL*8 X,Y(N),F(N)
                      F(1)=....  ETC.
       - X            INITIAL X-VALUE
       - XEND         FINAL X-VALUE (XEND-X POSITIVE OR NEGATIVE)
       - Y(N)         INITIAL VALUES FOR Y
       - EPS          LOCAL TOLERANCE
       - HMAX         MAXIMAL STEPSIZE
       - H            INITIAL STEPSIZE GUESS
       OUTPUT PARAMETERS:
       -----------------
       - Y(N) SOLUTION AT XEND

       EXTERNAL SUBROUTINE (TO BE SUPPLIED BY THE USER)
       -------------------
       - SOLOUT       THIS SUBROUTINE IS CALLED AFTER EVERY
                    STEP
                       SUBROUTINE SOLDOPRI(NR,X,Y,N)
                       REAL*8 X,Y(N)
                    FURNISHES THE SOLUTION Y AT THE NR-TH
                    GRID-POINT X (THE INITIAL VALUE IS CON-
                    SIDERED AS THE FIRST GRID-POINT).
                    SUPPLIED A DUMMY SUBROUTINE, IF THE SOLUTION
                    IS NOT DESIRED AT THE INTERMEDIATE POINTS.
--------------------------------------------------------------------

*/

struct CoeffsArr {
  static let C2  :  Double = 1.0e0/18.0e0
  static let C3  :  Double = 1.0e0/12.0e0
  static let C4  :  Double = 1.0e0/8.0e0
  static let C5  :  Double = 5.0e0/16.0e0
  static let C6  :  Double = 3.0e0/8.0e0
  static let C7  :  Double = 59.0e0/400.0e0
  static let C8  :  Double = 93.0e0/200.0e0
  static let C9  :  Double = 5490023248.0e0/9719169821.0e0
  static let C10  : Double = 13.0e0/20.0e0
  static let C11  : Double = 1201146811.0e0/1299019798.0e0
  static let C12  : Double = 1.0e0
  static let C13  : Double = 1.0e0
  static let A21  : Double = 1.0e0/18.0e0 // C2
  static let A31  : Double = 1.0e0/48.0e0
  static let A32  : Double = 1.0e0/16.0e0
  static let A41  : Double = 1.0e0/32.0e0
  static let A43  : Double = 3.0e0/32.0e0
  static let A51  : Double = 5.0e0/16.0e0
  static let A53  : Double = -75.0e0/64.0e0
  static let A54  : Double = 75.0e0/64.0e0 //-A53
  static let A61  : Double = 3.0e0/80.0e0
  static let A64  : Double = 3.0e0/16.0e0
  static let A65  : Double = 3.0e0/20.0e0
  static let A71  : Double = 29443841.0e0/614563906.0e0
  static let A74  : Double = 77736538.0e0/692538347.0e0
  static let A75  : Double = -28693883.0e0/1125.0e6
  static let A76  : Double = 23124283.0e0/18.0e8
  static let A81  : Double = 16016141.0e0/946692911.0e0
  static let A84  : Double = 61564180.0e0/158732637.0e0
  static let A85  : Double = 22789713.0e0/633445777.0e0
  static let A86  : Double = 545815736.0e0/2771057229.0e0
  static let A87  : Double = -180193667.0e0/1043307555.0e0
  static let A91  : Double = 39632708.0e0/573591083.0e0
  static let A94  : Double = -433636366.0e0/683701615.0e0
  static let A95  : Double = -421739975.0e0/2616292301.0e0
  static let A96  : Double = 100302831.0e0/723423059.0e0
  static let A97  : Double = 790204164.0e0/839813087.0e0
  static let A98  : Double = 800635310.0e0/3783071287.0e0
  static let A101 : Double = 246121993.0e0/1340847787.0e0
  static let A104 : Double = -37695042795.0e0/15268766246.0e0
  static let A105 : Double = -309121744.0e0/1061227803.0e0
  static let A106 : Double = -12992083.0e0/490766935.0e0
  static let A107 : Double = 6005943493.0e0/2108947869.0e0
  static let A108 : Double = 393006217.0e0/1396673457.0e0
  static let A109 : Double = 123872331.0e0/1001029789.0e0
  static let A111 : Double = -1028468189.0e0/846180014.0e0
  static let A114 : Double = 8478235783.0e0/508512852.0e0
  static let A115 : Double = 1311729495.0e0/1432422823.0e0
  static let A116 : Double = -10304129995.0e0/1701304382.0e0
  static let A117 : Double = -48777925059.0e0/3047939560.0e0
  static let A118 : Double = 15336726248.0e0/1032824649.0e0
  static let A119 : Double = -45442868181.0e0/3398467696.0e0
  static let A1110: Double = 3065993473.0e0/597172653.0e0
  static let A121 : Double = 185892177.0e0/718116043.0e0
  static let A124 : Double = -3185094517.0e0/667107341.0e0
  static let A125 : Double = -477755414.0e0/1098053517.0e0
  static let A126 : Double = -703635378.0e0/230739211.0e0
  static let A127 : Double = 5731566787.0e0/1027545527.0e0
  static let A128 : Double = 5232866602.0e0/850066563.0e0
  static let A129 : Double = -4093664535.0e0/808688257.0e0
  static let A1210: Double = 3962137247.0e0/1805957418.0e0
  static let A1211: Double = 65686358.0e0/487910083.0e0
  static let A131 : Double = 403863854.0e0/491063109.0e0
  static let A134 : Double = -5068492393.0e0/434740067.0e0
  static let A135 : Double = -411421997.0e0/543043805.0e0
  static let A136 : Double = 652783627.0e0/914296604.0e0
  static let A137 : Double = 11173962825.0e0/925320556.0e0
  static let A138 : Double = -13158990841.0e0/6184727034.0e0
  static let A139 : Double = 3936647629.0e0/1978049680.0e0
  static let A1310: Double = -160528059.0e0/685178525.0e0
  static let A1311: Double = 248638103.0e0/1413531060.0e0
  static let B1   : Double = 14005451.0e0/335480064.0e0
  static let B6   : Double = -59238493.0e0/1068277825.0e0
  static let B7   : Double = 181606767.0e0/758867731.0e0
  static let B8   : Double = 561292985.0e0/797845732.0e0
  static let B9   : Double = -1041891430.0e0/1371343529.0e0
  static let B10  : Double = 760417239.0e0/1151165299.0e0
  static let B11  : Double = 118820643.0e0/751138087.0e0
  static let B12  : Double = -528747749.0e0/2220607170.0e0
  static let B13  : Double = 1.0e0/4.0e0
  static let BH1  : Double = 13451932.0e0/455176623.0e0
  static let BH6  : Double = -808719846.0e0/976000145.0e0
  static let BH7  : Double = 1757004468.0e0/5645159321.0e0
  static let BH8  : Double = 656045339.0e0/265891186.0e0
  static let BH9  : Double = -3867574721.0e0/1518517206.0e0
  static let BH10 : Double = 465885868.0e0/322736535.0e0
  static let BH11 : Double = 53011238.0e0/667516719.0e0
  static let BH12 : Double = 2.0e0/45.0e0
}

struct Dopri8Arr {
  //var n: Int = 2 // DIMENSION OF THE SYSTEM ( N.LE.51)
  let n = 2
  var fcn: fcnTypeArr = {(_ x: Double, _ y: (Double, Double), _ f: inout (Double, Double)) in  print("doprifcn Dummy")}
  let nmax = 2000
  let uround = 2.23e-16
  var solout: soloutTypeArr
}

extension Dopri8Arr {
  init() {
    self.solout = {k, t, y in
      print("======>Dopri8 default solout")
      //precondition(n==2 && y.count==n, "System Dimension n: \(n) is not 2")
      let a = t * 0.001
      let sineps = sqrt(y.0*y.0 + y.1*y.1)
      let eps = asin(sineps)
      let psi = atan2(y.1, y.0)
      print(a, eps, psi)
    }
  }
}

extension Dopri8Arr {
  func dopri8(/*n: Int, */x: Double, y: inout (Double, Double), xend: Double, eps: Double, hmax: Double, h: Double) {
    //let n = 2
    let posneg = ((xend-x) < 0.0) ? -1.0 : 1.0
    let hmax = abs(hmax)
    var h = min(max(1.0e-10, abs(h)), hmax) * posneg
    let eps = max(eps, 13.0e0 * uround)
    var reject = false
    var naccpt = 0
    var nrejct = 0
    var nfcn = 0
    var nstep = 0
    
    var x = x
    // BASIC INTEGRATION STEP
    while (((x-xend)*posneg + uround) <= 0.0) {
      precondition((nstep <= nmax) || ((x+0.03e0 * h) != x), "EXIT OF DOPRI8 AT X=\(x)")
      if ((x+h-xend)*posneg > 0.0) {
        h = xend - x
      }
      
      var k1 = (0.0, 0.0)
      var k2 = (0.0, 0.0)
      var k3 = (0.0, 0.0)
      var k4 = (0.0, 0.0)
      var k5 = (0.0, 0.0)
      var k6 = (0.0, 0.0)
      var k7 = (0.0, 0.0)

      fcn(x, y, &k1)
      repeat {
        precondition((nstep <= nmax) || ((x+0.03e0 * h) != x), "EXIT OF DOPRI8 AT X=\(x)")
        nstep += 1
        // the first 9 stages
        var y1 = (0.0, 0.0)
        y1.0 = y.0 + h * k1.0 * CoeffsArr.A21
        y1.1 = y.1 + h * k1.1 * CoeffsArr.A21

        fcn(x + CoeffsArr.C2 * h, y1, &k2)
        
        y1.0 = y.0 + h * (k1.0 * CoeffsArr.A31 + k2.0 * CoeffsArr.A32)
        y1.1 = y.1 + h * (k1.1 * CoeffsArr.A31 + k2.1 * CoeffsArr.A32)

        fcn(x + CoeffsArr.C3 * h, y1, &k3)

        y1.0 = y.0 + h * (k1.0 * CoeffsArr.A41 + k3.0 * CoeffsArr.A43)
        y1.1 = y.1 + h * (k1.1 * CoeffsArr.A41 + k3.1 * CoeffsArr.A43)

        fcn(x + CoeffsArr.C4 * h, y1, &k4)

        var tmp = (CoeffsArr.A51 * k1.0, CoeffsArr.A51 * k1.1)
        tmp.0 += CoeffsArr.A53 * k3.0 // to avoid compiler issues
        tmp.1 += CoeffsArr.A53 * k3.1
        
        tmp.0 += CoeffsArr.A54 * k4.0
        tmp.1 += CoeffsArr.A54 * k4.1

        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(x + CoeffsArr.C5 * h, y1, &k5)

        tmp  = (CoeffsArr.A61  * k1.0, CoeffsArr.A61  * k1.1)
        tmp.0 += CoeffsArr.A64  * k4.0
        tmp.1 += CoeffsArr.A64  * k4.1

        tmp.0 += CoeffsArr.A65  * k5.0
        tmp.1 += CoeffsArr.A65  * k5.1

        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(x + CoeffsArr.C6 * h, y1, &k6)

        tmp  = (CoeffsArr.A71  * k1.0, CoeffsArr.A71  * k1.1)
        tmp.0 += CoeffsArr.A74  * k4.0
        tmp.1 += CoeffsArr.A74  * k4.1
        tmp.0 += CoeffsArr.A75  * k5.0
        tmp.1 += CoeffsArr.A75  * k5.1
        tmp.0 += CoeffsArr.A76  * k6.0
        tmp.1 += CoeffsArr.A76  * k6.1

        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(x + CoeffsArr.C7 * h, y1, &k7)

        tmp  = (CoeffsArr.A81  * k1.0, CoeffsArr.A81  * k1.1)
        tmp.0 += CoeffsArr.A84  * k4.0
        tmp.1 += CoeffsArr.A84  * k4.1
        tmp.0 += CoeffsArr.A85  * k5.0
        tmp.1 += CoeffsArr.A85  * k5.1
        tmp.0 += CoeffsArr.A86  * k6.0
        tmp.1 += CoeffsArr.A86  * k6.1
        tmp.0 += CoeffsArr.A87  * k7.0
        tmp.1 += CoeffsArr.A87  * k7.1
        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(x + CoeffsArr.C8 * h, y1, &k2)

        tmp  = (CoeffsArr.A91  * k1.0, CoeffsArr.A91  * k1.1)
        tmp.0 += CoeffsArr.A94  * k4.0
        tmp.1 += CoeffsArr.A94  * k4.1
        tmp.0 += CoeffsArr.A95  * k5.0
        tmp.1 += CoeffsArr.A95  * k5.1
        tmp.0 += CoeffsArr.A96  * k6.0
        tmp.1 += CoeffsArr.A96  * k6.1
        tmp.0 += CoeffsArr.A97  * k7.0
        tmp.1 += CoeffsArr.A97  * k7.1
        tmp.0 += CoeffsArr.A98  * k2.0
        tmp.1 += CoeffsArr.A98  * k2.1
        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(x + CoeffsArr.C9 * h, y1, &k3)

        tmp  = (CoeffsArr.A101 * k1.0, CoeffsArr.A101 * k1.1)
        tmp.0 += CoeffsArr.A104 * k4.0
        tmp.1 += CoeffsArr.A104 * k4.1
        tmp.0 += CoeffsArr.A105 * k5.0
        tmp.1 += CoeffsArr.A105 * k5.1
        tmp.0 += CoeffsArr.A106 * k6.0
        tmp.1 += CoeffsArr.A106 * k6.1
        tmp.0 += CoeffsArr.A107 * k7.0
        tmp.1 += CoeffsArr.A107 * k7.1
        tmp.0 += CoeffsArr.A108 * k2.0
        tmp.1 += CoeffsArr.A108 * k2.1
        tmp.0 += CoeffsArr.A109 * k3.0
        tmp.1 += CoeffsArr.A109 * k3.1
        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        // COMPUTE INTERMEDIATE SUMS TO SAVE MEMORY
        var y11s = (CoeffsArr.A111 * k1.0, CoeffsArr.A111 * k1.1)
        y11s.0 += CoeffsArr.A114 * k4.0
        y11s.1 += CoeffsArr.A114 * k4.1
        y11s.0 += CoeffsArr.A115 * k5.0
        y11s.1 += CoeffsArr.A115 * k5.1
        y11s.0 += CoeffsArr.A116 * k6.0
        y11s.1 += CoeffsArr.A116 * k6.1
        y11s.0 += CoeffsArr.A117 * k7.0
        y11s.1 += CoeffsArr.A117 * k7.1
        y11s.0 += CoeffsArr.A118 * k2.0
        y11s.1 += CoeffsArr.A118 * k2.1
        y11s.0 += CoeffsArr.A119 * k3.0
        y11s.1 += CoeffsArr.A119 * k3.1

        var y12s = (CoeffsArr.A121 * k1.0, CoeffsArr.A121 * k1.1)
        y12s.0 += CoeffsArr.A124 * k4.0
        y12s.1 += CoeffsArr.A124 * k4.1
        y12s.0 += CoeffsArr.A125 * k5.0
        y12s.1 += CoeffsArr.A125 * k5.1
        y12s.0 += CoeffsArr.A126 * k6.0
        y12s.1 += CoeffsArr.A126 * k6.1
        y12s.0 += CoeffsArr.A127 * k7.0
        y12s.1 += CoeffsArr.A127 * k7.1
        y12s.0 += CoeffsArr.A128 * k2.0
        y12s.1 += CoeffsArr.A128 * k2.1
        y12s.0 += CoeffsArr.A129 * k3.0
        y12s.1 += CoeffsArr.A129 * k3.1
        
        tmp  = (CoeffsArr.A131 * k1.0, CoeffsArr.A131 * k1.1)
        tmp.0 += CoeffsArr.A134 * k4.0
        tmp.1 += CoeffsArr.A134 * k4.1
        tmp.0 += CoeffsArr.A135 * k5.0
        tmp.1 += CoeffsArr.A135 * k5.1
        tmp.0 += CoeffsArr.A136 * k6.0
        tmp.1 += CoeffsArr.A136 * k6.1
        tmp.0 += CoeffsArr.A137 * k7.0
        tmp.1 += CoeffsArr.A137 * k7.1
        tmp.0 += CoeffsArr.A138 * k2.0
        tmp.1 += CoeffsArr.A138 * k2.1
        tmp.0 += CoeffsArr.A139 * k3.0
        tmp.1 += CoeffsArr.A139 * k3.1
        k4 = tmp

        
        tmp  = (CoeffsArr.B1  * k1.0, CoeffsArr.B1  * k1.1)
        tmp.0 += CoeffsArr.B6  * k6.0
        tmp.1 += CoeffsArr.B6  * k6.1
        tmp.0 += CoeffsArr.B7  * k7.0
        tmp.1 += CoeffsArr.B7  * k7.1
        tmp.0 += CoeffsArr.B8  * k2.0
        tmp.1 += CoeffsArr.B8  * k2.1
        tmp.0 += CoeffsArr.B9  * k3.0
        tmp.1 += CoeffsArr.B9  * k3.1
        k5 = tmp

        tmp  = (CoeffsArr.BH1 * k1.0, CoeffsArr.BH1 * k1.1)
        tmp.0 += CoeffsArr.BH6 * k6.0
        tmp.1 += CoeffsArr.BH6 * k6.1
        tmp.0 += CoeffsArr.BH7 * k7.0
        tmp.1 += CoeffsArr.BH7 * k7.1
        tmp.0 += CoeffsArr.BH8 * k2.0
        tmp.1 += CoeffsArr.BH8 * k2.1
        tmp.0 += CoeffsArr.BH9 * k3.0
        tmp.1 += CoeffsArr.BH9 * k3.1
        k6 = tmp

        k2 = y11s
        k3 = y12s

        // The last 4 stages
        fcn(x + CoeffsArr.C10 * h, y1, &k7)

        y1.0 = y.0 + h * (k2.0 + CoeffsArr.A1110 * k7.0)
        y1.1 = y.1 + h * (k2.1 + CoeffsArr.A1110 * k7.1)

        fcn(x + CoeffsArr.C11 * h, y1, &k2)

        let xph = x + h

        tmp  = k3
        tmp.0 += CoeffsArr.A1210 * k7.0
        tmp.1 += CoeffsArr.A1210 * k7.1
        tmp.0 += CoeffsArr.A1211 * k2.0
        tmp.1 += CoeffsArr.A1211 * k2.1
        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(xph, y1, &k3)

        tmp  = k4
        tmp.0 += CoeffsArr.A1310 * k7.0
        tmp.1 += CoeffsArr.A1310 * k7.1
        tmp.0 += CoeffsArr.A1311 * k2.0
        tmp.1 += CoeffsArr.A1311 * k2.1
        y1.0 = y.0 + h * tmp.0
        y1.1 = y.1 + h * tmp.1

        fcn(xph, y1, &k4)

        nfcn += 13
        
        tmp  = k5
        tmp.0 += CoeffsArr.B10 * k7.0
        tmp.1 += CoeffsArr.B10 * k7.1
        tmp.0 += CoeffsArr.B11 * k2.0
        tmp.1 += CoeffsArr.B11 * k2.1
        tmp.0 += CoeffsArr.B12 * k3.0
        tmp.1 += CoeffsArr.B12 * k3.1
        tmp.0 += CoeffsArr.B13 * k4.0
        tmp.1 += CoeffsArr.B13 * k4.1
        k5.0 = y.0 + h * tmp.0
        k5.1 = y.1 + h * tmp.1

        tmp  = k6
        tmp.0 += CoeffsArr.BH10 * k7.0
        tmp.1 += CoeffsArr.BH10 * k7.1
        tmp.0 += CoeffsArr.BH11 * k2.0
        tmp.1 += CoeffsArr.BH11 * k2.1
        tmp.0 += CoeffsArr.BH12 * k3.0
        tmp.1 += CoeffsArr.BH12 * k3.1
        k6.0 = y.0 + h * tmp.0
        k6.1 = y.1 + h * tmp.1
        
        // ERROR ESTIMATION
        var denom = (max(1.0e-6, abs(k5.0)), max(1.0e-6, abs(k5.1)))
        denom.0 = max(denom.0, abs(y.0))
        denom.1 = max(denom.1, abs(y.1))

        denom.0 = max(denom.0, 2.0 * uround/eps)
        denom.1 = max(denom.1, 2.0 * uround/eps)

        let errvect0 = ((k5.0-k6.0)/denom.0)
        let errvect1 = ((k5.1-k6.1)/denom.1)
        let errvect = (errvect0 * errvect0, errvect1 * errvect1)
        let err = sqrt((errvect.0 + errvect.1)/2.0)
        //print("err=\(err)")
        // -----COMPUTATION OF HNEW
        // -----WE REQUIRE .333 <=HNEW/W<=6.
        let fac = max((1.0/6.0), min(3.0, pow(err/eps, (1.0/8.0))/0.9))
        var hnew = h/fac
        
        if (err > eps) {
          // step is rejected
          reject = true
          h = hnew
          if (naccpt >= 1) {
            nrejct -= 1
          }
          nfcn -= 1
        } else {
          // Step is accepted
          naccpt += 1
          y = k5
          x = xph
          if (abs(hnew) > hmax) {
            hnew = posneg * hmax
          }
          if (reject == true) {
            hnew = posneg * min(abs(hnew), abs(h))
          }
          reject = false
          h = hnew
        }
      } while reject == true
      
    }
    return
  }
}

extension Dopri8Arr {
  /**
  ---------------------------------------------------------------------------
       depart d'une methode d'integration a pas multiples d'un syteme
                             y'=f(x,y)
       ------>   utilisation de la routine Dopri8 <-------
       Frederic Joutel (*m/4)
       (c) ASD/BdL - 5/1991 -
       (vf)
  --------------------------------------------------------------------------
  ------ PARAMETRE ---------------------------------------------------------
         nmax           dimension maximale du syteme
         eps            l'erreur locale sur une iteration de la routine
                         dopri8  (eps > udp) (calcule par le programme
                         eps=13.D0*udp, par compatibilite avec dopri8)
  ------ ENTREE -------------------------------------------------------------
         n              dimension du syteme  (n<=nmax)
         fcn            nom (externe) de la sous routine calculant
                        les seconds membres de l'equation
                          SUBROUTINE FCN(n,x,y,f)
                          REAL*8 x,y(n),f(n)
                          f(1)= ...
         x0             la valeur initiale du temps
         pas            le pas
         m              l'ordre de la methode
         y(n)           la position du syteme a l'instant x0
  ------ SORTIE --------------------------------------------------------------
         x0             la valeur du temps apres (m-1) pas
         y(n)           la position du systeme a l'instant x0
         valyp(n,0:m-1) le tableau des seconds membres a l'arrivee
                         (valyp(...,m-1) les seconds membres a l'instant x0)
  ----------------------------------------------------------------------------
  */
  func depart(x0: inout Double, step: Double, m: Int, y: inout (Double, Double), valyp: inout ([Double],[Double]) ) {

    // calculate machine epsilon (UDP)
    var udp = 1.0
    while ((1.0+udp) > 1.0) {
      udp /= 2.0
    }
    udp *= 2.0
    let eps = 13.0 * udp
    
    var f = (0.0, 0.0)
    fcn(x0, y, &f)
    
    self.solout(0, x0, y)
    
    valyp.0[0] = f.0
    valyp.1[0] = f.1

    for j in 1..<m {
      let xfin = x0 + step
      //------ we take the first estimate of the step so that Dopri8
      //------ calculates the optimal value by itself.
      let pas1 = step
      let pas0 = step
      dopri8(x: x0, y: &y, xend: xfin, eps: eps, hmax: pas0, h: pas1)
      fcn(xfin, y, &f)
      self.solout(j,xfin,y)
      valyp.0[j] = f.0
      valyp.1[j] = f.1
      x0 = xfin
    }
  }
}
