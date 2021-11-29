//
//  Rotation.swift
//
//  Created by Heiko Pälike on 30/10/2020.
//

import Foundation



/** Structure holding classical Keplerian elements encoded in quasi-equinoctual elements

The classical orbital elements are provided as computed properties.

They can manually be obtained by:
- e: Eccentricity = sqrt(k^2 + h^2) (-)
- varpi: longitude of periapsis = atan2(h, k) (rad)
- Omega: longitude of ascending node = atan2(p, q) (rad)
- i: orbital inclination = sqrt(q^2+ p^2) * 2.0 (rad)

- Parameter i: Double
*/
public struct Keplerian {
	/// The semi-major axis (AU)
	let a: Double
	
	/// The mean longitude (rad)
	let l: Double
	
	/// e * cos (longitude of perihelion)
	let k: Double
	
	/// e * sin (longitude of perihelion)
	let h: Double
	
	/// sin(i/2) cos (longitude of node) (i: inclination from J2000 ecliptic)
	let q: Double
	
	/// sin(i/2) sin (longitude of node) (i: inclination from J2000 ecliptic)
	let p: Double
	
	/// Ω longitude of ascending node (rad)
	var Omega: Double {
		atan2(p, q)
	}
	
	/// orbital inclination (rad)
	var i: Double {
		sqrt(q*q + p*p) * 2.0
	}
	
	/// orbital eccentricity (-)
	var e: Double {
		sqrt(k*k + h*h)
	}
	
	/// longitude of perihelion (rad) = Ω + ω
	var varpi: Double {
		get {
				return atan2(h, k)
		}
	}
	
	// argument of Perihelion ω (rad)
	var argPeri: Double {
		varpi - Omega
	}
	
	// mean Anomaly (rad)
	var M: Double {
		l - varpi
	}
	
	/// Eccentric anomaly
	var E: Double {
		calcE(M: M, ecc: e)
	}
	
	/// true Anomaly (rad)
	var nu: Double {
		2.0 * atan(sqrt((1.0 + e)/(1.0 - e))*tan(E/2.0))
	}
}


/**
- Parameters:
	 - a: The semi-major axis (AU)
	 - l: The mean anomaly (rad)
	 - k: e * cos (longitude of perihelion)
	 - h: e * sin (longitude of perihelion)
	 - q: sin(i/2) cos (longitude of node) (i: inclination from J2000 ecliptic)
	 - p: sin(i/2) sin (longitude of node) (i: inclination from J2000 ecliptic)
	 - t: time from J2000 (currently unused)
- Returns: Keplerian
*/
public func unrotateFromInvariablePlane(_ elements: Keplerian,
										t: Double = 0.0,
										Omega0: Double = -1.3257524502535283, //-75.960020078654796
										i0: Double = 0.02755113997947439, //1.578564041598032
										printVal: Bool = false) -> Keplerian {
	// steps:
	// 1. compute from k,h; q,p variables inc, ecc, Omega, varpi
	// 2. convert Kepler elements w.r.t. invariable plane to state vector x,y,z,dx,dy,dz
	// 3. apply rotation matrix from invariable plane to ICRF (Souami & Souchay	2012)
	// 4. convert rotated state vector back to Keplerian elements
	
	// 0. Define constants
	let drcf = Double.pi / 180.0 // scaling factor degree -> radians
	let AU = 1.495_978_707_00e11 //m
	//let mu =  1.327_124_400_41e20 //m^3/s^2 for Sun as central body
	// let ε0J2000 = 23.439291111 * drcf
	
	let orientationInpop10a = (107.58237116*drcf, 1.57870235*drcf) // Table 7 from Souami & Souchay 2012, doi: 10.1051/0004-6361/201219011
	//let orientationDE405 = (107.58228062*drcf, 1.57870566*drcf) // wrt Ecliptic-Equinox (not vs ICRF)

	// 1.
//	let (Omega0, i0) = calcOmegaI(q: q0, p: p0) // rad (in deg: )
//	let (e0, varpi0) = calcEvarpi(k: k0, h: h0) // rad (in deg: )
//	let argPeri = elements.varpi - elements.Omega
//	let M0 = l0 - varpi0
//	let E0 = calcE(M: M0, ecc: e0)// eccentric anomaly
//	let nu0 = 2 * atan(sqrt((1.0 + e0)/(1.0 - e0))*tan(E0/2.0)) // true anomaly


	// 2.
	let (pos0, vel0) = kepler_to_cartesianVec(a: elements.a * AU, e: elements.e, i: elements.i, Omega: elements.Omega, argPeri: elements.argPeri, M: elements.M)

	let posrot0 = rotateFull(Omega:  Omega0 + Double.pi, theta: -i0, phi: 0.0, xyz: pos0)  // make Omega0 fixed for t= 0
	let finalpos = rotate(Omega: -orientationInpop10a.0, theta: 0.0, xyz: posrot0)
	
	let velrot0 = rotateFull(Omega:  Omega0 + Double.pi, theta: -i0, phi: 0.0, xyz: vel0) // make Omega0 fixed for t= 0
	let finalvel = rotate(Omega: -orientationInpop10a.0, theta: 0.0, xyz: velrot0)

	let keplerNew = cartesian_to_keplerVect(pos: finalpos, vel: finalvel)

	// 4.
	//let (res) = cartesian_to_keplerVect(pos: pos0, vel: vel0)
	let enew = keplerNew.e
	let inew = keplerNew.i
	let Omeganew = keplerNew.Omega % (2.0 * Double.pi)
	
	let varpi_new = keplerNew.argPeri + keplerNew.Omega // mean longitude = Omega + arg periapsis
	
	let lnew = (keplerNew.M + keplerNew.argPeri + keplerNew.Omega) % 360.0  // M + varpi_new
	let (knew, hnew) = calckh(e: enew, varpi: varpi_new)
	let (qnew, pnew) = calcqp(omega: Omeganew, i: inew)
	
    if (printVal) {
        print(-t/1000.0, keplerNew.a/AU, lnew, Omeganew, inew, enew, varpi_new, knew, hnew, qnew, pnew)
    }

    
	return Keplerian(a: keplerNew.a/AU, l: lnew, k: knew, h: hnew, q: qnew, p: pnew)
}


/**
- Parameters:
	 - a: The semi-major axis (AU)
	 - l: The mean anomaly (rad)
	 - k: e * cos (longitude of perihelion)
	 - h: e * sin (longitude of perihelion)
	 - q: sin(i/2) cos (longitude of node) (i: inclination from J2000 ecliptic)
	 - p: sin(i/2) sin (longitude of node) (i: inclination from J2000 ecliptic)
	 - t: time from J2000 (currently unused)
- Returns: Keplerian
*/
public func unrotateFromSolarPlane(_ elements: Keplerian,
										t: Double = 0.0,
										Omega0: Double = 179.9992488761977 / 180.0 * Double.pi,
										i0: Double = 7.150307688039328/180.0*Double.pi,
										printVal: Bool = false) -> Keplerian {
	// steps:
	// 1. compute from k,h; q,p variables inc, ecc, Omega, varpi
	// 2. convert Kepler elements w.r.t. invariable plane to state vector x,y,z,dx,dy,dz
	// 3. apply rotation matrix from invariable plane to ICRF (Souami & Souchay	2012)
	// 4. convert rotated state vector back to Keplerian elements
	
	// 0. Define constants
	let drcf = Double.pi / 180.0 // scaling factor degree -> radians
	let AU = 1.495_978_707_00e11 //m
	//let mu =  1.327_124_400_41e20 //m^3/s^2 for Sun as central body
	// let ε0J2000 = 23.439291111 * drcf
	
	//let orientationInpop10a = (107.58237116*drcf, 1.57870235*drcf) // Table 7 from Souami & Souchay 2012, doi: 10.1051/0004-6361/201219011
	//let orientationDE405 = (107.58228062*drcf, 1.57870566*drcf) //
	let orientationBeckGiles = (75.594*drcf, 7.155*drcf) // wrt Ecliptic-Equinox (not vs ICRF)

	// 1.
//	let (Omega0, i0) = calcOmegaI(q: q0, p: p0) // rad (in deg: )
//	let (e0, varpi0) = calcEvarpi(k: k0, h: h0) // rad (in deg: )
//	let argPeri = elements.varpi - elements.Omega
//	let M0 = l0 - varpi0
//	let E0 = calcE(M: M0, ecc: e0)// eccentric anomaly
//	let nu0 = 2 * atan(sqrt((1.0 + e0)/(1.0 - e0))*tan(E0/2.0)) // true anomaly


	// 2.
	let (pos0, vel0) = kepler_to_cartesianVec(a: elements.a * AU, e: elements.e, i: elements.i, Omega: elements.Omega, argPeri: elements.argPeri, M: elements.M)

	let posrot0 = rotateFull(Omega:  Omega0 + Double.pi, theta: -i0, phi: 0.0, xyz: pos0)  // make Omega0 fixed for t= 0
	let finalpos = rotate(Omega: -orientationBeckGiles.0, theta: 0.0, xyz: posrot0)
	
	let velrot0 = rotateFull(Omega:  Omega0 + Double.pi, theta: -i0, phi: 0.0, xyz: vel0) // make Omega0 fixed for t= 0
	let finalvel = rotate(Omega: -orientationBeckGiles.0, theta: 0.0, xyz: velrot0)

	let keplerNew = cartesian_to_keplerVect(pos: finalpos, vel: finalvel)

	//print(keplerNew)
	// 4.
	//let (res) = cartesian_to_keplerVect(pos: pos0, vel: vel0)
	let enew = keplerNew.e
	let inew = keplerNew.i
	let Omeganew = keplerNew.Omega % (2.0 * Double.pi)
	
	let varpi_new = keplerNew.argPeri + keplerNew.Omega // mean longitude = Omega + arg periapsis
	
	let lnew = (keplerNew.M + keplerNew.argPeri + keplerNew.Omega) % 360.0  // M + varpi_new
	let (knew, hnew) = calckh(e: enew, varpi: varpi_new)
	let (qnew, pnew) = calcqp(omega: Omeganew, i: inew)
	
		if (printVal) {
				print(-t/1000.0, keplerNew.a/AU, lnew, Omeganew, inew, enew, varpi_new, knew, hnew, qnew, pnew)
		}

		
	return Keplerian(a: keplerNew.a/AU, l: lnew, k: knew, h: hnew, q: qnew, p: pnew)
}

/**
    Calculate the Eccentricity anomaly E from the mean anomaly M, iterativly
    inversion of Keplers formula: E-e*sin(E)=M  (188)
    based on the book
    Grossman; The sheer joy of celestial mechanics
    Orbits under the inverse square law
*/
func calcE(M: Double,ecc: Double, tol: Double = 1e-15) -> Double
    //Calculate the Eccentricity anomaly E from the mean anomaly M, iterativly
    //inversion of Keplers formula: E-e*sin(E)=M  (188)
    //based on the book
    //Grossman; The sheer joy of celestial mechanics
    //Orbits under the inverse square law
{
    var E : Double = 0.0
    var Etemp = M
    var ratio : Double = -1.0
    while (abs(ratio)>tol)
    {
        let fE = Etemp - ecc*sin(Etemp) - M
        let fEprime = 1.0 - ecc * cos(Etemp)
        ratio = fE/fEprime
        if (abs(ratio) > tol) {
            Etemp = Etemp - ratio
        }else {
            E = Etemp
        }
    }
    return E
}


public func kepler_to_cartesianVec(a: Double, e: Double, i: Double, Omega: Double, argPeri: Double, M: Double) -> (pos: Vector3<Double>, vel: Vector3<Double>) {
	//https://downloads.rene-schwarz.com/download/M001-Keplerian_Orbit_Elements_to_Cartesian_State_Vectors.pdf

	let E = calcE(M: M, ecc: e)//*180.0/Double.pi
	let mu = 1.32712440018e20 //m3s-2
	//let nu = 2.0 * atan2(sqrt(1.0+e) * sin(E/2.0), sqrt(1.0-e) * cos(E/2.0)) // true anomaly
	let nu = 2.0 * atan(sqrt((1.0 + e)/(1.0 - e)) * tan(E/2.0))
	let rc = a*(1.0-e*cos(E))
	
	let const = sqrt(mu * a)/rc

	// in orbital frame
	let ox  = rc * cos(nu) // Fränz Harper Eq 29
	let oy  = rc * sin(nu)
	// let oz  = 0.0
	let odx = const * (-1.0 * sin(E)) // Fränz Harper Eq 30
	let ody = const * (sqrt(1-e*e) * cos(E))
	// let odz = 0.0
	
	// let rtest = unrotateFull(Omega: Omega, theta: i, phi: argPeri, xyz: Vector3<Double>(ox, oy, 0.0)) // this is equiv to below
	let  rx =  ox * ( cos(argPeri)*cos(Omega) - sin(argPeri)*cos(i)*sin(Omega)) -
			   oy * ( sin(argPeri)*cos(Omega) + cos(argPeri)*cos(i)*sin(Omega))
	let  ry =  ox * ( cos(argPeri)*sin(Omega) + sin(argPeri)*cos(i)*cos(Omega)) +
			   oy * (-sin(argPeri)*sin(Omega) + cos(argPeri)*cos(i)*cos(Omega))
	let  rz =  ox * ( sin(argPeri)*sin(i)) +
			   oy * ( cos(argPeri)*sin(i))
	
	let rdx = odx * ( cos(argPeri)*cos(Omega) - sin(argPeri)*cos(i)*sin(Omega)) -
			  ody * ( sin(argPeri)*cos(Omega) + cos(argPeri)*cos(i)*sin(Omega))
	let rdy = odx * ( cos(argPeri)*sin(Omega) + sin(argPeri)*cos(i)*cos(Omega)) +
			  ody * (-sin(argPeri)*sin(Omega) + cos(argPeri)*cos(i)*cos(Omega))
	let rdz = odx * ( sin(argPeri)*sin(i)) +
			  ody * ( cos(argPeri)*sin(i))
	
	let pos = Vector3<Double>( rx, ry, rz)
	let vel = Vector3<Double>(rdx,rdy,rdz)
	// r(t) = Rz(−Ω)Rx(−i)Rz(−ω)o(t)
	// r ̇(t) = Rz(−Ω)Rx(−i)Rz(−ω)o ̇(t)
	// let xv = a*(cos(E) - e)
	// let yv = a * (sqrt(1.0 - e * e) * sin(E))
	// let v = atan2(yv,xv)
	// let r = sqrt(xv*xv+yv*yv)
	// let rc = a*(1.0-e*cos(E))
	// let xh = r * (cos(omega) * cos(v + argPeri) - sin(omega)*sin(v+argPeri)*cos(i))
	// let yh = r * (sin(omega) * cos(v + argPeri) + cos(omega)*sin(v+argPeri)*cos(i))
	// let zh = r*(sin(v + argPeri) * sin(i))
	// let pos = Vector3<Double>(xh,yh,zh)
	// let vel = Vector3<Double>(-sin(E),sqrt(1.0-e*e)*cos(E),0.0)*sqrt(mu*a/r)
	// //let posh_norm = simd_normalize(SIMD3<Double>(xh,yh,zh))
	return (pos,vel)
}

public func cartesian_to_keplerVect(pos: Vector3<Double>, vel: Vector3<Double>) -> (a: Double, e: Double, i: Double, Omega: Double, argPeri: Double, M: Double) {
	//https://downloads.rene-schwarz.com/download/M002-Cartesian_State_Vectors_to_Keplerian_Orbit_Elements.pdf
	//let pos = SIMD3<Double>(xyz.x,xyz.y,xyz.z)
	//let vel = SIMD3<Double>(xv,yv,zv)
	let h = cross(pos, vel) //orbital momentum vector
	let hmag = length(h)
	let r = length(pos)
	let v = length(vel)
	let mu = 1.32712440018e20 //m3s-2
	
	let evec = cross(vel,h)/mu - pos/r
	let e = length(evec)
	let nvec = Vector3<Double>(-h.y, h.x, 0.0) //simd_cross(SIMD3<Double>(0.0,0.0,1.0),h)
	let n = length(nvec)

	let posdotvel = dot(pos,vel)
	var nu = acos(dot(evec,pos)/e/r) // true anomaly

	if posdotvel < 0.0 {
        nu = 2.0 * .pi - nu
	}
	
	let i = acos(h.z/hmag)
	
	let E = 2.0 * atan(tan(nu/2.0)/sqrt((1.0+e)/(1.0-e)))
	//let E = 2.0 * atan2(sqrt((1.0+e)/(1.0-e)),tan(nu/2.0))

	var Omega = acos(nvec.x/n)
	if (nvec.y < 0.0) {
        Omega = 2.0 * .pi - Omega
	}
	
	var argperi = acos(dot(nvec,evec)/e/n)
	if (evec.z < 0.0) {
		argperi = 2.0 * .pi - argperi
	}
	
	let M = E - e*sin(E)
	let a = 1.0/(2.0/r - v*v/mu)
	
	return (a,e,i,Omega,argperi,M)
}


func calcOmegaI(q: Double, p: Double) -> (Omega: Double, i: Double) {
	// q : sin(i/2) cos (Omega)
	// p : sin(i/2) sin (Omega)
	let Omega = atan2(p, q)
	// if Omega < 0 {
	// 	Omega += Double.pi * 2.0
	// }
	let i = sqrt(q*q + p*p) * 2.0

	return (Omega, i)
}

func calcEvarpi(k: Double, h: Double) -> (e: Double, varpi: Double) {
	// k: e  cos (varpi) // eccentricity, "long. of periapsis"
	// h: e  sin (varpi)
	let varpi = atan2(h, k)
	let e = sqrt(k*k + h*h)

	return (e, varpi)
}


func calcqp(omega: Double, i: Double) -> (q: Double, p: Double) {
	let val = sin(i/2.0)
	return (q: val * cos(omega),
			p: val * sin(omega))
}

func calckh(e: Double, varpi: Double) -> (k: Double, h: Double) {
	return (k: e * cos(varpi),
			h: e * sin(varpi))
}


func calcAngleGL(u: dvec3, v: dvec3) -> Double {
	let dotprod = dot(u,v)
	let theta = acos(dotprod/length(u)/length(v))
	return theta
}

public func unrotate(Omega:Double,theta:Double, xyz: dvec3)  -> dvec3 {
	
	let sinOmegatheta = [sin(Omega), sin(theta)]
	let cosOmegatheta = [cos(Omega), cos(theta)]
	
	let sinOmega = sinOmegatheta[0]
	let sintheta = sinOmegatheta[1]
	let cosOmega = cosOmegatheta[0]
	let costheta = cosOmegatheta[1]
	let sinOmegacostheta = sinOmega*costheta
	let cosOmegacostheta = cosOmega*costheta
	let sinOmegasintheta = sinOmega*sintheta
	let cosOmegasintheta = cosOmega*sintheta
	let E = dmat3(dvec3([  cosOmega, //col 1
						   sinOmega,
						   0.0]),
				  dvec3([ -sinOmegacostheta, //col2
						   cosOmegacostheta,
						   sintheta]),
				  dvec3([  sinOmegasintheta, //col3
						   -cosOmegasintheta,
						   costheta])
	)

	let unrot = E * xyz

	return unrot
}



public func rotateFullMat(Omega:Double,theta:Double,phi:Double)  -> dmat3 {
	
	let sinOmegathetaphi = [sin(Omega), sin(theta), sin(phi)]
	let cosOmegathetaphi = [cos(Omega), cos(theta), cos(phi)]

	let sinOmega = sinOmegathetaphi[0]
	let sintheta = sinOmegathetaphi[1]
	let sinphi   = sinOmegathetaphi[2]
	
	let cosOmega = cosOmegathetaphi[0]
	let costheta = cosOmegathetaphi[1]
	let cosphi   = cosOmegathetaphi[2]
	
	let sinphisintheta = sinphi * sintheta
	let cosphisintheta = cosphi * sintheta
	let sinphisinOmega = sinphi * sinOmega
	let sinphicosOmega = sinphi * cosOmega
	let sinphicostheta = sinphi * costheta
	let cosphicosOmega = cosphi * cosOmega
	let cosphisinOmega = cosphi * sinOmega

	let E = dmat3(dvec3([ cosphicosOmega - sinphisinOmega*costheta, //col 1
						 -sinphicosOmega - cosphisinOmega*costheta,
						  sinOmega*sintheta]),
				  dvec3([  cosphisinOmega + sinphicostheta*cosOmega, //col2
						  -sinphisinOmega + cosphicosOmega*costheta,
						  -cosOmega*sintheta]),
				  dvec3([ sinphisintheta, //col3
						  cosphisintheta,
						  costheta])
	)
	
	return E
}

public func rotateMat(Omega:Double,theta:Double)  -> dmat3 {
	
	let sinOmegatheta = [sin(Omega), sin(theta)]
	let cosOmegatheta = [cos(Omega), cos(theta)]
	
	let sinOmega = sinOmegatheta[0]
	let sintheta = sinOmegatheta[1]
	let cosOmega = cosOmegatheta[0]
	let costheta = cosOmegatheta[1]
	let sinOmegacostheta = sinOmega*costheta
	let cosOmegacostheta = cosOmega*costheta
	let sinOmegasintheta = sinOmega*sintheta
	let cosOmegasintheta = cosOmega*sintheta
	
	let E = dmat3(dvec3([ cosOmega, 		//col 1
						 -sinOmegacostheta,
						  sinOmegasintheta ]),
				  dvec3([ sinOmega, 		//col 2
						  cosOmegacostheta,
						 -cosOmegasintheta ]),
				  dvec3([              0.0, //col 3
								  sintheta,
								  costheta ])
	)

	return E
}

public func unrotateFullMat(Omega:Double,theta:Double,phi:Double)  -> dmat3 {
	
	let sinOmegathetaphi = [sin(Omega), sin(theta), sin(phi)]
	let cosOmegathetaphi = [cos(Omega), cos(theta), cos(phi)]

	let sinOmega = sinOmegathetaphi[0]
	let sintheta = sinOmegathetaphi[1]
	let sinphi   = sinOmegathetaphi[2]
	
	let cosOmega = cosOmegathetaphi[0]
	let costheta = cosOmegathetaphi[1]
	let cosphi   = cosOmegathetaphi[2]
	
	let sinphisintheta = sinphi * sintheta
	let cosphisintheta = cosphi * sintheta
	let sinphisinOmega = sinphi * sinOmega
	let sinphicosOmega = sinphi * cosOmega
	let sinphicostheta = sinphi * costheta
	let cosphicosOmega = cosphi * cosOmega
	let cosphisinOmega = cosphi * sinOmega

	let E = dmat3(dvec3([  cosphicosOmega - sinphisinOmega*costheta, //col 1
						   cosphisinOmega + sinphicostheta*cosOmega,
						   sinphisintheta]),
				  dvec3([ -sinphicosOmega - cosphisinOmega*costheta, //col2
						  -sinphisinOmega + cosphicosOmega*costheta,
						   cosphisintheta]),
				  dvec3([  sinOmega*sintheta, 						//col3
						  -cosOmega*sintheta,
						   costheta])
	)
	return E
}

public func unrotateMat(Omega:Double,theta:Double)  -> dmat3 {
	
	let sinOmegatheta = [sin(Omega), sin(theta)]
	let cosOmegatheta = [cos(Omega), cos(theta)]
	
	let sinOmega = sinOmegatheta[0]
	let sintheta = sinOmegatheta[1]
	let cosOmega = cosOmegatheta[0]
	let costheta = cosOmegatheta[1]
	let sinOmegacostheta = sinOmega*costheta
	let cosOmegacostheta = cosOmega*costheta
	let sinOmegasintheta = sinOmega*sintheta
	let cosOmegasintheta = cosOmega*sintheta
	let E = dmat3(dvec3([  cosOmega, //col 1 //transpose of rotateMat
						   sinOmega,
						   0.0]),
				  dvec3([ -sinOmegacostheta, //col2
						   cosOmegacostheta,
						   sintheta]),
				  dvec3([  sinOmegasintheta, //col3
						   -cosOmegasintheta,
						   costheta])
	)

	return E
}


public func unrotateOmegaI(e: dmat3, origOmega: Double, origI: Double) -> (Omega: Double, origI: Double) {
	let pole = dvec3(0.0, 0.0, 1.0)
	let vec = rotate(Omega: origOmega, theta: origI, xyz: pole)
	let vec2 = e * vec // unrotate to given
	
	
	let  inew =  acos(vec2.z)
	let Omeganew = atan2(vec2.x, -vec2.y)
	return (Omega: Omeganew, origI: inew)
}

public func rotateFull(Omega: Double, theta: Double, phi: Double, xyz: dvec3)  -> dvec3 {
	let E = rotateFullMat(Omega: Omega, theta: theta, phi: phi)
	return E * xyz
}

public func unrotateFull(Omega: Double, theta: Double, phi: Double, xyz: dvec3)  -> dvec3 {
	let E = unrotateFullMat(Omega: Omega, theta: theta, phi: phi)
	return E * xyz
}

public func rotate(Omega:Double, theta:Double, xyz: dvec3)  -> dvec3 {
	let rot = rotateMat(Omega: Omega, theta: theta) * xyz
	return rot
}
