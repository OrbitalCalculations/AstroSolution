//
//  SGLMath+Vector.swift
//
//  Created by Heiko Pälike on 27/08/2021.
//

import Foundation
// Copyright (c) 2015-2016 David Turnbull
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and/or associated documentation files (the
// "Materials"), to deal in the Materials without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Materials, and to
// permit persons to whom the Materials are furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Materials.
//
// THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
public typealias dvec3 = Vector3<Double>
public typealias dmat3 = Matrix3x3<Double>


public protocol ArithmeticType: Numeric, /*Hashable, */Strideable {
    init(_: Double)
    init(_: Float)
    init(_: Int)
    init(_: UInt)
    init(_: Int8)
    init(_: UInt8)
    init(_: Int16)
    init(_: UInt16)
    init(_: Int32)
    init(_: UInt32)
    init(_: Int64)
    init(_: UInt64)
    static func /(_: Self, _: Self) -> Self
    static func /=(_: inout Self, _: Self)
    static func %(_: Self, _: Self) -> Self
    static func %=(_: inout Self, _: Self)
}

public protocol FloatingPointArithmeticType: ArithmeticType, FloatingPoint, ExpressibleByFloatLiteral {}
extension Double: FloatingPointArithmeticType {
    public static func %(a: Double, b: Double) -> Double {
        return a.remainder(dividingBy: b)
    }
    public static func %=(a: inout Double, b: Double) {
        a = a.remainder(dividingBy: b)
    }
}
extension Float: FloatingPointArithmeticType {
    public static func %(a: Float, b: Float) -> Float {
        return a.remainder(dividingBy: b)
    }
    public static func %=(a: inout Float, b: Float) {
        a = a.remainder(dividingBy: b)
    }
}
// Anything not a plain single scalar is considered a Matrix.
// This includes Vectors, Complex, and Quaternion.
public protocol MatrixType: /*Hashable,*/ CustomDebugStringConvertible, Sequence where Element: ArithmeticType {
    init()
    init(_: Self, _:(_:Element) -> Element)
    init(_: Self, _: Self, _:(_:Element, _:Element) -> Element)
    init(_: Element, _: Self, _:(_:Element, _:Element) -> Element)
    init(_: Self, _: Element, _:(_:Element, _:Element) -> Element)
    prefix static func ++(_: inout Self) -> Self
    postfix static func ++(_: inout Self) -> Self
    prefix static func --(_: inout Self) -> Self
    postfix static func --(_: inout Self) -> Self
    static func +(_: Self, _: Self) -> Self
    static func +=(_: inout Self, _: Self)
    static func +(_: Element, _: Self) -> Self
    static func +(_: Self, _: Element) -> Self
    static func +=(_: inout Self, _: Element)
    static func -(_: Self, _: Self) -> Self
    static func -=(_: inout Self, _: Self)
    static func -(_: Element, _: Self) -> Self
    static func -(_: Self, _: Element) -> Self
    static func -=(_: inout Self, _: Element)
    static func *(_: Element, _: Self) -> Self
    static func *(_: Self, _: Element) -> Self
    static func *=(_: inout Self, _: Element)
    static func /(_: Element, _: Self) -> Self
    static func /(_: Self, _: Element) -> Self
    static func /=(_: inout Self, _: Element)
    static func %(_: Self, _: Self) -> Self
    static func %=(_: inout Self, _: Self)
    static func %(_: Element, _: Self) -> Self
    static func %(_: Self, _: Element) -> Self
    static func %=(_: inout Self, _: Element)
    var elements: [Element] { get }
}

// This protocol is only Vector2, Vector3, and Vector4
public protocol VectorType: MatrixType, ExpressibleByArrayLiteral {
    associatedtype FloatVector
    associatedtype DoubleVector
    associatedtype Int32Vector
    associatedtype UInt32Vector
    associatedtype BooleanVector
    // T.BooleanVector == BooleanVector : Must use this key with mixed types.
    subscript(_:Int) -> Element { get set }
    init<T: VectorType>(_: T, _:(_:T.Element) -> Element) where T.BooleanVector == BooleanVector
    init<T1: VectorType, T2: VectorType>(_:T1, _:T2, _:(_:T1.Element, _:T2.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector
    init<T1: VectorType, T2: VectorType>(_:T1, _:inout T2, _:(_:T1.Element, _:inout T2.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector
    init<T1: VectorType, T2: VectorType, T3: VectorType>(_:T1, _:T2, _:T3, _:(_:T1.Element, _:T2.Element, _:T3.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector, T3.BooleanVector == BooleanVector
    init<T1: VectorType, T2: VectorType, T3: BooleanVectorType>(_:T1, _:T2, _:T3, _:(_:T1.Element, _:T2.Element, _:Bool) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector, T3.BooleanVector == BooleanVector
    static func *(_: Self, _: Self) -> Self
    static func *=(_: inout Self, _: Self)
    static func /(_: Self, _: Self) -> Self
    static func /=(_: inout Self, _: Self)
}

// This protocol is only Vector2b, Vector3b, and Vector4b
public protocol BooleanVectorType: Hashable, CustomDebugStringConvertible, Sequence {
    associatedtype BooleanVector
    subscript(_:Int) -> Bool { get set }
    init(_: Self, _:(_:Bool) -> Bool)
    init<T: VectorType>(_: T, _:(_:T.Element) -> Bool) where T.BooleanVector == BooleanVector
    init<T1: VectorType, T2: VectorType>(_:T1, _:T2, _:(_:T1.Element, _:T2.Element) -> Bool) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector
}

public struct Vector3<T: ArithmeticType>: VectorType {

  

  
    public typealias Element = T
    public typealias FloatVector = Vector3<Float>
    public typealias DoubleVector = Vector3<Double>
    public typealias Int32Vector = Vector3<Int32>
    public typealias UInt32Vector = Vector3<UInt32>
    public typealias BooleanVector = Vector3b

    public var x: T, y: T, z: T

    public var r: T { get { return x } set { x = newValue } }
    public var g: T { get { return y } set { y = newValue } }
    public var b: T { get { return z } set { z = newValue } }

    public var s: T { get { return x } set { x = newValue } }
    public var t: T { get { return y } set { y = newValue } }
    public var p: T { get { return z } set { z = newValue } }

    public var elements: [Element] {
        return [x, y, z]
    }

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return elements.makeIterator()
    }

    public subscript(index: Int) -> T {
        get {
            switch(index) {
            case 0: return x
            case 1: return y
            case 2: return z
            default: preconditionFailure("Vector index out of range")
            }
        }
        set {
            switch(index) {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: preconditionFailure("Vector index out of range")
            }
        }
    }

    public var debugDescription: String {
        return String(describing: type(of: self)) + "(\(x), \(y), \(z))"
    }

    /*public func hash(into hasher: inout Hasher) {
        hasher.combine(SGLMath.hash(x.hashValue, y.hashValue, z.hashValue))
    }*/

    public init () {
        self.x = 0
        self.y = 0
        self.z = 0
    }

    public init (_ v: T) {
        self.x = v
        self.y = v
        self.z = v
    }

    public init(_ array: [T]) {
        precondition(array.count == 3, "Vector3 requires a 3-element array")
        self.x = array[0]
        self.y = array[1]
        self.z = array[2]
    }

    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }

    public init (_ x: T, _ y: T, _ z: T) {
        self.x = x
        self.y = y
        self.z = z
    }

    /*public init (_ v: Vector2<T>, _ z: T) {
        self.x = v.x
        self.y = v.y
        self.z = z
    }

    public init (_ x: T, _ v: Vector2<T>) {
        self.x = x
        self.y = v.x
        self.z = v.y
    }*/

    public init (x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init (r: T, g: T, b: T) {
        self.x = r
        self.y = g
        self.z = b
    }

    public init (s: T, t: T, p: T) {
        self.x = s
        self.y = t
        self.z = p
    }

    public init (_ v: Vector3<T>) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
    }

    /*public init (_ v: Vector4<T>) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
    }*/

    public init (_ v: Vector3<Double>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Float>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Int>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<UInt>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Int8>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<UInt8>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Int16>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<UInt16>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Int32>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<UInt32>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<Int64>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ v: Vector3<UInt64>) {
        self.x = T(v.x)
        self.y = T(v.y)
        self.z = T(v.z)
    }

    public init (_ s: T, _ v: Vector3<T>, _ op:(_:T, _:T) -> T) {
        self.x = op(s, v.x)
        self.y = op(s, v.y)
        self.z = op(s, v.z)
    }

    public init (_ v: Vector3<T>, _ s: T, _ op:(_:T, _:T) -> T) {
        self.x = op(v.x, s)
        self.y = op(v.y, s)
        self.z = op(v.z, s)
    }

    public init<T: VectorType>(_ v: T, _ op:(_:T.Element) -> Element) where T.BooleanVector == BooleanVector {
            self.x = op(v[0])
            self.y = op(v[1])
            self.z = op(v[2])
    }

    public init<T1: VectorType, T2: VectorType>(_ v1: T1, _ v2: T2, _ op:(_:T1.Element, _:T2.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector {
            self.x = op(v1[0], v2[0])
            self.y = op(v1[1], v2[1])
            self.z = op(v1[2], v2[2])
    }

    public init<T1: VectorType, T2: VectorType>(_ v1: T1, _ v2:inout T2, _ op:(_:T1.Element, _:inout T2.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector {
            self.x = op(v1[0], &v2[0])
            self.y = op(v1[1], &v2[1])
            self.z = op(v1[2], &v2[2])
    }

    public init<T1: VectorType, T2: VectorType, T3: VectorType>(_ v1: T1, _ v2: T2, _ v3: T3, _ op:(_:T1.Element, _:T2.Element, _:T3.Element) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector, T3.BooleanVector == BooleanVector {
            self.x = op(v1[0], v2[0], v3[0])
            self.y = op(v1[1], v2[1], v3[1])
            self.z = op(v1[2], v2[2], v3[2])
    }

    public init<T1: VectorType, T2: VectorType, T3: BooleanVectorType>(_ v1: T1, _ v2: T2, _ v3: T3, _ op:(_:T1.Element, _:T2.Element, _:Bool) -> Element) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector, T3.BooleanVector == BooleanVector {
            self.x = op(v1[0], v2[0], v3[0])
            self.y = op(v1[1], v2[1], v3[1])
            self.z = op(v1[2], v2[2], v3[2])
    }

    public static func ==(v1: Vector3<T>, v2: Vector3<T>) -> Bool {
        return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z
    }
}

// Swift didn't put these in BitwiseOperationsType
public protocol BitsOperationsType: ArithmeticType, BinaryInteger {
}
extension Int: BitsOperationsType {}
extension UInt: BitsOperationsType {}
extension Int8: BitsOperationsType {}
extension UInt8: BitsOperationsType {}
extension Int16: BitsOperationsType {}
extension UInt16: BitsOperationsType {}
extension Int32: BitsOperationsType {}
extension UInt32: BitsOperationsType {}
extension Int64: BitsOperationsType {}
extension UInt64: BitsOperationsType {}

public struct Matrix3x3<T: ArithmeticType>: MatrixType {

  
    public typealias Element = T

    private var x: Vector3<T>, y: Vector3<T>, z: Vector3<T>

    public subscript(column: Int) -> Vector3<T> {
        get {
            switch(column) {
            case 0: return x
            case 1: return y
            case 2: return z
            default: preconditionFailure("Matrix index out of range")
            }
        }
        set {
            switch(column) {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: preconditionFailure("Matrix index out of range")
            }
        }
    }

    public var elements: [Element] {
        return Array([x.elements, y.elements, z.elements].joined())
    }

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return elements.makeIterator()
    }

    public subscript(column: Int, row: Int) -> T {
        return self[column][row]
    }

    public var debugDescription: String {
        return String(describing: type(of: self)) + "(" + [x, y, z].map { (v: Vector3<T>) -> String in
            "[" + [v.x, v.y, v.z].map { (n: T) -> String in String(describing: n) }.joined(separator: ", ") + "]"
        }.joined(separator: ", ") + ")"
    }

    //public func hash(into hasher: inout Hasher) {
    //    hasher.combine(SGLMath.hash(x.hashValue, y.hashValue, z.hashValue))
    //}

    public init() {
        self.x = Vector3<T>(1, 0, 0)
        self.y = Vector3<T>(0, 1, 0)
        self.z = Vector3<T>(0, 0, 1)
    }

    public init(_ s: T) {
        self.x = Vector3<T>(s, 0, 0)
        self.y = Vector3<T>(0, s, 0)
        self.z = Vector3<T>(0, 0, s)
    }

    public init(_ x: Vector3<T>, _ y: Vector3<T>, _ z: Vector3<T>) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(
        _ x1: T, _ y1: T, _ z1: T,
        _ x2: T, _ y2: T, _ z2: T,
        _ x3: T, _ y3: T, _ z3: T
        ) {
            self.x = Vector3<T>(x1, y1, z1)
            self.y = Vector3<T>(x2, y2, z2)
            self.z = Vector3<T>(x3, y3, z3)
    }

    /*public init(_ m: Matrix2x2<T>) {
        self.x = Vector3<T>(m[0], 0)
        self.y = Vector3<T>(m[1], 0)
        self.z = Vector3<T>(0, 0, 1)
    }

    public init(_ m: Matrix2x3<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(0, 0, 1)
    }

    public init(_ m: Matrix2x4<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(0, 0, 1)
    }

    public init(_ m: Matrix3x2<T>) {
        self.x = Vector3<T>(m[0], 0)
        self.y = Vector3<T>(m[1], 0)
        self.z = Vector3<T>(m[2], 1)
    }*/

    public init(_ m: Matrix3x3<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(m[2])
    }
/*
    public init(_ m: Matrix3x4<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(m[2])
    }

    public init(_ m: Matrix4x2<T>) {
        self.x = Vector3<T>(m[0], 0)
        self.y = Vector3<T>(m[1], 0)
        self.z = Vector3<T>(m[2], 1)
    }

    public init(_ m: Matrix4x3<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(m[2])
    }

    public init(_ m: Matrix4x4<T>) {
        self.x = Vector3<T>(m[0])
        self.y = Vector3<T>(m[1])
        self.z = Vector3<T>(m[2])
    }
*/
    public init(_ m: Matrix3x3<Double>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Float>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Int>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<UInt>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Int8>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<UInt8>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Int16>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<UInt16>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Int32>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<UInt32>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<Int64>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init(_ m: Matrix3x3<UInt64>) {
        self.x = Vector3<T>(m.x)
        self.y = Vector3<T>(m.y)
        self.z = Vector3<T>(m.z)
    }

    public init (_ m: Matrix3x3<T>, _ op:(_:T) -> T) {
        self.x = Vector3<T>(m.x, op)
        self.y = Vector3<T>(m.y, op)
        self.z = Vector3<T>(m.z, op)
    }

    public init (_ s: T, _ m: Matrix3x3<T>, _ op:(_:T, _:T) -> T) {
        self.x = Vector3<T>(s, m.x, op)
        self.y = Vector3<T>(s, m.y, op)
        self.z = Vector3<T>(s, m.z, op)
    }

    public init (_ m: Matrix3x3<T>, _ s: T, _ op:(_:T, _:T) -> T) {
        self.x = Vector3<T>(m.x, s, op)
        self.y = Vector3<T>(m.y, s, op)
        self.z = Vector3<T>(m.z, s, op)
    }

    public init (_ m1: Matrix3x3<T>, _ m2: Matrix3x3<T>, _ op:(_:T, _:T) -> T) {
        self.x = Vector3<T>(m1.x, m2.x, op)
        self.y = Vector3<T>(m1.y, m2.y, op)
        self.z = Vector3<T>(m1.z, m2.z, op)
    }

    public var inverse: Matrix3x3<T> {
        var mm = Matrix3x3<T>()
        mm.x.x = self.y.y * self.z.z
        mm.x.x = mm.x.x - self.y.z * self.z.y
        mm.y.x = self.y.z * self.z.x
        mm.y.x = mm.y.x - self.y.x * self.z.z
        mm.z.x = self.y.x * self.z.y
        mm.z.x = mm.z.x - self.y.y * self.z.x
        mm.x.y = self.x.z * self.z.y
        mm.x.y = mm.x.y - self.x.y * self.z.z
        mm.y.y = self.x.x * self.z.z
        mm.y.y = mm.y.y - self.x.z * self.z.x
        mm.z.y = self.x.y * self.z.x
        mm.z.y = mm.z.y - self.x.x * self.z.y
        mm.x.z = self.x.y * self.y.z
        mm.x.z = mm.x.z - self.x.z * self.y.y
        mm.y.z = self.x.z * self.y.x
        mm.y.z = mm.y.z - self.x.x * self.y.z
        mm.z.z = self.x.x * self.y.y
        mm.z.z = mm.z.z - self.x.y * self.y.x
        return mm * (1 / determinant)
    }

    public var determinant: T {
        var d1 = self.y.y * self.z.z
        d1 = d1 - self.z.y * self.y.z
        var d2 = self.x.y * self.z.z
        d2 = d2 - self.z.y * self.x.z
        var d3 = self.x.y * self.y.z
        d3 = d3 - self.y.y * self.x.z
        var det = self.x.x * d1
        det = det - self.y.x * d2
        det = det + self.z.x * d3
        return det
    }

    public var transpose: Matrix3x3<T> {
        return Matrix3x3(
            self.x.x, self.y.x, self.z.x,
            self.x.y, self.y.y, self.z.y,
            self.x.z, self.y.z, self.z.z
        )
    }

    public static func ==(m1: Matrix3x3<T>, m2: Matrix3x3<T>) -> Bool {
        return m1.x == m2.x && m1.y == m2.y && m1.z == m2.z
    }

    public static func *(v: Vector3<T>, m: Matrix3x3<T>) -> Vector3<T> {
        var x: T = v.x * m.x.x
        x = x + v.y * m.x.y
        x = x + v.z * m.x.z
        var y: T = v.x * m.y.x
        y = y + v.y * m.y.y
        y = y + v.z * m.y.z
        var z: T = v.x * m.z.x
        z = z + v.y * m.z.y
        z = z + v.z * m.z.z
        return Vector3<T>(x, y, z)
    }

    public static func *(m: Matrix3x3<T>, v: Vector3<T>) -> Vector3<T> {
        var rv: Vector3<T> = m.x * v.x
        rv = rv + m.y * v.y
        rv = rv + m.z * v.z
        return rv
    }

    /*public static func *(m1: Matrix3x3<T>, m2: Matrix2x3<T>) -> Matrix2x3<T> {
        var x: Vector3<T> = m1.x * m2[0].x
        x = x + m1.y * m2[0].y
        x = x + m1.z * m2[0].z
        var y: Vector3<T> = m1.x * m2[1].x
        y = y + m1.y * m2[1].y
        y = y + m1.z * m2[1].z
        return Matrix2x3<T>(x, y)
    }*/

    public static func *(m1: Matrix3x3<T>, m2: Matrix3x3<T>) -> Matrix3x3<T> {
        var x: Vector3<T> = m1.x * m2[0].x
        x = x + m1.y * m2[0].y
        x = x + m1.z * m2[0].z
        var y: Vector3<T> = m1.x * m2[1].x
        y = y + m1.y * m2[1].y
        y = y + m1.z * m2[1].z
        var z: Vector3<T> = m1.x * m2[2].x
        z = z + m1.y * m2[2].y
        z = z + m1.z * m2[2].z
        return Matrix3x3<T>(x, y, z)
    }

    /*public static func *(m1: Matrix3x3<T>, m2: Matrix4x3<T>) -> Matrix4x3<T> {
        var x: Vector3<T> = m1.x * m2[0].x
        x = x + m1.y * m2[0].y
        x = x + m1.z * m2[0].z
        var y: Vector3<T> = m1.x * m2[1].x
        y = y + m1.y * m2[1].y
        y = y + m1.z * m2[1].z
        var z: Vector3<T> = m1.x * m2[2].x
        z = z + m1.y * m2[2].y
        z = z + m1.z * m2[2].z
        var w: Vector3<T> = m1.x * m2[3].x
        w = w + m1.y * m2[3].y
        w = w + m1.z * m2[3].z
        return Matrix4x3<T>(x, y, z, w)
    }*/

    public static func *=(m1: inout Matrix3x3<T>, m2: Matrix3x3<T>) {
        m1 = m1 * m2
    }

    public static func /(v: Vector3<T>, m: Matrix3x3<T>) -> Vector3<T> {
        return v * m.inverse
    }

    public static func /(m: Matrix3x3<T>, v: Vector3<T>) -> Vector3<T> {
        return m.inverse * v
    }

    public static func /(m1: Matrix3x3<T>, m2: Matrix3x3<T>) -> Matrix3x3<T> {
        return m1 * m2.inverse
    }

    public static func /=(m1: inout Matrix3x3<T>, m2: Matrix3x3<T>) {
        m1 = m1 / m2
    }
}

#if canImport(simd)
    import simd
#endif

// Arithmetic Operators

public prefix func ++<T: MatrixType>(v: inout T) -> T {
    v = v + 1
    return v
}

public postfix func ++<T: MatrixType>(v: inout T) -> T {
    let r = v
    v = v + 1
    return r
}

public prefix func --<T: MatrixType>(v: inout T) -> T {
    v = v - 1
    return v
}

public postfix func --<T: MatrixType>(v: inout T) -> T {
    let r = v
    v = v - 1
    return r
}

public func +<T: MatrixType>(x1: T, x2: T) -> T {
    #if canImport(simd)
        switch (x1) {/*
        case is Matrix2x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2x2.self) + unsafeBitCast(x2, to: float2x2.self), to: T.self)

        case is Matrix2x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2x2.self) + unsafeBitCast(x2, to: double2x2.self), to: T.self)

        case is Matrix2x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2x4.self) + unsafeBitCast(x2, to: float2x4.self), to: T.self)

        case is Matrix2x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2x4.self) + unsafeBitCast(x2, to: double2x4.self), to: T.self)

        case is Matrix3x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float3x2.self) + unsafeBitCast(x2, to: float3x2.self), to: T.self)

        case is Matrix3x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double3x2.self) + unsafeBitCast(x2, to: double3x2.self), to: T.self)

        case is Matrix3x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float3x4.self) + unsafeBitCast(x2, to: float3x4.self), to: T.self)

        case is Matrix3x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double3x4.self) + unsafeBitCast(x2, to: double3x4.self), to: T.self)

        case is Matrix4x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4x2.self) + unsafeBitCast(x2, to: float4x2.self), to: T.self)

        case is Matrix4x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4x2.self) + unsafeBitCast(x2, to: double4x2.self), to: T.self)

        case is Matrix4x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4x4.self) + unsafeBitCast(x2, to: float4x4.self), to: T.self)

        case is Matrix4x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4x4.self) + unsafeBitCast(x2, to: double4x4.self), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2.self) + unsafeBitCast(x2, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2.self) + unsafeBitCast(x2, to: double2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4.self) + unsafeBitCast(x2, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4.self) + unsafeBitCast(x2, to: double4.self), to: T.self)*/
        default: break
        }
    #endif
    return T(x1, x2, +)
}

public func +=<T: MatrixType>(x1: inout T, x2: T) {
    x1 = x1 + x2
}

public func +<T: MatrixType>(s: T.Element, x: T) -> T {
    return T(s, x, +)
}

public func +<T: MatrixType>(x: T, s: T.Element) -> T {
    return T(x, s, +)
}

public func +=<T: MatrixType>(x: inout T, s: T.Element) {
    x = x + s
}

public func -<T: MatrixType>(x1: T, x2: T) -> T {
    #if canImport(simd)
        switch (x1) {/*
        case is Matrix2x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2x2.self) - unsafeBitCast(x2, to: float2x2.self), to: T.self)

        case is Matrix2x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2x2.self) - unsafeBitCast(x2, to: double2x2.self), to: T.self)

        case is Matrix2x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2x4.self) - unsafeBitCast(x2, to: float2x4.self), to: T.self)

        case is Matrix2x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2x4.self) - unsafeBitCast(x2, to: double2x4.self), to: T.self)

        case is Matrix3x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float3x2.self) - unsafeBitCast(x2, to: float3x2.self), to: T.self)

        case is Matrix3x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double3x2.self) - unsafeBitCast(x2, to: double3x2.self), to: T.self)

        case is Matrix3x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float3x4.self) - unsafeBitCast(x2, to: float3x4.self), to: T.self)

        case is Matrix3x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double3x4.self) - unsafeBitCast(x2, to: double3x4.self), to: T.self)

        case is Matrix4x2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4x2.self) - unsafeBitCast(x2, to: float4x2.self), to: T.self)

        case is Matrix4x2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4x2.self) - unsafeBitCast(x2, to: double4x2.self), to: T.self)

        case is Matrix4x4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4x4.self) - unsafeBitCast(x2, to: float4x4.self), to: T.self)

        case is Matrix4x4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4x4.self) - unsafeBitCast(x2, to: double4x4.self), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float2.self) - unsafeBitCast(x2, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double2.self) - unsafeBitCast(x2, to: double2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(unsafeBitCast(x1, to: float4.self) - unsafeBitCast(x2, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(unsafeBitCast(x1, to: double4.self) - unsafeBitCast(x2, to: double4.self), to: T.self)*/
        default: break
        }
    #endif
    return T(x1, x2, -)
}

public func -=<T: MatrixType>(x1: inout T, x2: T) {
    x1 = x1 - x2
}

public func -<T: MatrixType>(s: T.Element, x: T) -> T {
    return T(s, x, -)
}

public func -<T: MatrixType>(x: T, s: T.Element) -> T {
    return T(x, s, -)
}

public func -=<T: MatrixType>(x: inout T, s: T.Element) {
    x = x - s
}

public func *<T: MatrixType>(s: T.Element, x: T) -> T {
    #if canImport(simd)
        switch (x) {/*
        case is Matrix2x2<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float2x2.self), to: T.self)

        case is Matrix2x2<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double2x2.self), to: T.self)

        case is Matrix2x4<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float2x4.self), to: T.self)

        case is Matrix2x4<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double2x4.self), to: T.self)

        case is Matrix3x2<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float3x2.self), to: T.self)

        case is Matrix3x2<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double3x2.self), to: T.self)

        case is Matrix3x4<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float3x4.self), to: T.self)

        case is Matrix3x4<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double3x4.self), to: T.self)

        case is Matrix4x2<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float4x2.self), to: T.self)

        case is Matrix4x2<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double4x2.self), to: T.self)

        case is Matrix4x4<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float4x4.self), to: T.self)

        case is Matrix4x4<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double4x4.self), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast((s as! Float) * unsafeBitCast(x, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast((s as! Double) * unsafeBitCast(x, to: double4.self), to: T.self)*/
        default: break
        }
    #endif
    return T(s, x, *)
}

public func *<T: MatrixType>(x: T, s: T.Element) -> T {
    #if canImport(simd)
        switch (x) {/*
        case is Matrix2x2<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float2x2.self) * (s as! Float), to: T.self)

        case is Matrix2x2<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double2x2.self) * (s as! Double), to: T.self)

        case is Matrix2x4<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float2x4.self) * (s as! Float), to: T.self)

        case is Matrix2x4<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double2x4.self) * (s as! Double), to: T.self)

        case is Matrix3x2<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float3x2.self) * (s as! Float), to: T.self)

        case is Matrix3x2<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double3x2.self) * (s as! Double), to: T.self)

        case is Matrix3x4<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float3x4.self) * (s as! Float), to: T.self)

        case is Matrix3x4<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double3x4.self) * (s as! Double), to: T.self)

        case is Matrix4x2<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float4x2.self) * (s as! Float), to: T.self)

        case is Matrix4x2<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double4x2.self) * (s as! Double), to: T.self)

        case is Matrix4x4<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float4x4.self) * (s as! Float), to: T.self)

        case is Matrix4x4<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double4x4.self) * (s as! Double), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float2.self) * (s as! Float), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double2.self) * (s as! Double), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(unsafeBitCast(x, to: float4.self) * (s as! Float), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(unsafeBitCast(x, to: double4.self) * (s as! Double), to: T.self)*/
        default: break
        }
    #endif
    return T(x, s, *)
}

public func *=<T: MatrixType>(x: inout T, s: T.Element) {
    x = x * s
}

public func /<T: MatrixType>(s: T.Element, x: T) -> T {
    return T(s, x, /)
}

public func /<T: MatrixType>(x: T, s: T.Element) -> T {
    return T(x, s, /)
}

public func /=<T: MatrixType>(x: inout T, s: T.Element) {
    x = x / s
}

public func %<T: MatrixType>(x1: T, x2: T) -> T {
    return T(x1, x2, %)
}

public func %=<T: MatrixType>(x1: inout T, x2: T) {
    x1 = x1 % x2
}

public func %<T: MatrixType>(s: T.Element, x: T) -> T {
    return T(s, x, %)
}

public func %<T: MatrixType>(x: T, s: T.Element) -> T {
    return T(x, s, %)
}

public func %=<T: MatrixType>(x: inout T, s: T.Element) {
    x = x % s
}

// Unchecked Integer Operators

public func &+<T: MatrixType>(v1: T, v2: T) -> T where T.Element: FixedWidthInteger {
    #if canImport(simd)
        switch (v1) {/*
        case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int2.self) &+ unsafeBitCast(v2, to: int2.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int4.self) &+ unsafeBitCast(v2, to: int4.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(v1, v2, &+)
}

public func &+<T: MatrixType>(s: T.Element, v: T) -> T where T.Element: FixedWidthInteger {
    return T(s, v, &+)
}

public func &+<T: MatrixType>(v: T, s: T.Element) -> T where T.Element: FixedWidthInteger {
    return T(v, s, &+)
}

public func &-<T: MatrixType>(v1: T, v2: T) -> T where T.Element: FixedWidthInteger {
    #if canImport(simd)
        switch (v1) {/*
        case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int2.self) &- unsafeBitCast(v2, to: int2.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int4.self) &- unsafeBitCast(v2, to: int4.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(v1, v2, &-)
}

public func &-<T: MatrixType>(s: T.Element, v: T) -> T where T.Element: FixedWidthInteger {
    return T(s, v, &-)
}

public func &-<T: MatrixType>(v: T, s: T.Element) -> T where T.Element: FixedWidthInteger {
    return T(v, s, &-)
}

public func &*<T: MatrixType>(v1: T, v2: T) -> T where T.Element: FixedWidthInteger {
    #if canImport(simd)
        switch (v1) {
        /*case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int2.self) &* unsafeBitCast(v2, to: int2.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int4.self) &* unsafeBitCast(v2, to: int4.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(v1, v2, &*)
}

public func &*<T: MatrixType>(s: T.Element, v: T) -> T where T.Element: FixedWidthInteger {
    #if canImport(simd)
        switch (v) {/*
        case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(s, to: Int32.self) &* unsafeBitCast(v, to: int2.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(s, to: Int32.self) &* unsafeBitCast(v, to: int4.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(s, v, &*)
}

public func &*<T: MatrixType>(v: T, s: T.Element) -> T where T.Element: FixedWidthInteger {
    #if canImport(simd)
        switch (v) {/*
        case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(v, to: int2.self) &* unsafeBitCast(s, to: Int32.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(v, to: int4.self) &* unsafeBitCast(s, to: Int32.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(v, s, &*)
}

public func << <T: MatrixType>(v: T, s: T.Element) -> T where T.Element: BitsOperationsType {
    return T(v, s, <<)
}

public func <<= <T: MatrixType>(v: inout T, s: T.Element) where T.Element: BitsOperationsType {
    v = v << s
}

public func >> <T: MatrixType>(v: T, s: T.Element) -> T where T.Element: BitsOperationsType {
    return T(v, s, <<)
}

public func >>= <T: MatrixType>(v: inout T, s: T.Element) where T.Element: BitsOperationsType {
    v = v >> s
}

public func &<T: MatrixType>(x1: T, x2: T) -> T where T.Element: BitsOperationsType {
    return T(x1, x2, &)
}

public func &=<T: MatrixType>(x1: inout T, x2: T) where T.Element: BitsOperationsType {
    x1 = x1 & x2
}

public func &<T: MatrixType>(s: T.Element, x: T) -> T where T.Element: BitsOperationsType {
    return T(s, x, &)
}

public func &<T: MatrixType>(x: T, s: T.Element) -> T where T.Element: BitsOperationsType {
    return T(x, s, &)
}

public func &=<T: MatrixType>(x: inout T, s: T.Element) where T.Element: BitsOperationsType {
    x = x & s
}

public func |<T: MatrixType>(x1: T, x2: T) -> T where T.Element: BitsOperationsType {
    return T(x1, x2, |)
}

public func |=<T: MatrixType>(x1: inout T, x2: T) where T.Element: BitsOperationsType {
    x1 = x1 | x2
}

public func |<T: MatrixType>(s: T.Element, x: T) -> T where T.Element: BitsOperationsType {
    return T(s, x, |)
}

public func |<T: MatrixType>(x: T, s: T.Element) -> T where T.Element: BitsOperationsType {
    return T(x, s, |)
}

public func |=<T: MatrixType>(x: inout T, s: T.Element) where T.Element: BitsOperationsType {
    x = x | s
}

public func ^<T: MatrixType>(v1: T, v2: T) -> T where T.Element: BitsOperationsType {
    return T(v1, v2, ^)
}

public func ^=<T: MatrixType>(x1: inout T, x2: T) where T.Element: BitsOperationsType {
    x1 = x1 ^ x2
}

public func ^<T: MatrixType>(s: T.Element, x: T) -> T where T.Element: BitsOperationsType {
    return T(s, x, ^)
}

public func ^<T: MatrixType>(x: T, s: T.Element) -> T where T.Element: BitsOperationsType {
    return T(x, s, ^)
}

public func ^=<T: MatrixType>(x: inout T, s: T.Element) where T.Element: BitsOperationsType {
    x = x ^ s
}

public prefix func ~<T: MatrixType>(v: T) -> T where T.Element: BitsOperationsType {
    return T(v, ~)
}

// Signed Numbers Only

public prefix func +<T: MatrixType>(v: T) -> T where T.Element: SignedNumeric {
    return v
}

public prefix func -<T: MatrixType>(x: T) -> T where T.Element: SignedNumeric {
    #if canImport(simd)
        switch (x) {/*
        case is Matrix2x2<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float2x2.self), to: T.self)

        case is Matrix2x2<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double2x2.self), to: T.self)

        case is Matrix2x4<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float2x4.self), to: T.self)

        case is Matrix2x4<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double2x4.self), to: T.self)

        case is Matrix3x2<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float3x2.self), to: T.self)

        case is Matrix3x2<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double3x2.self), to: T.self)

        case is Matrix3x4<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float3x4.self), to: T.self)

        case is Matrix3x4<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double3x4.self), to: T.self)

        case is Matrix4x2<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float4x2.self), to: T.self)

        case is Matrix4x2<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double4x2.self), to: T.self)

        case is Matrix4x4<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float4x4.self), to: T.self)

        case is Matrix4x4<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double4x4.self), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double2.self), to: T.self)

        case is Vector2<Int32>:
            return unsafeBitCast(-unsafeBitCast(x, to: int2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(-unsafeBitCast(x, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(-unsafeBitCast(x, to: double4.self), to: T.self)

        case is Vector4<Int32>:
            return unsafeBitCast(-unsafeBitCast(x, to: int4.self), to: T.self)*/
        default: break
        }
    #endif
    return T(x, -)
}

// Vector Multiply and Divide

public func *<T: VectorType>(v1: T, v2: T) -> T {
    #if canImport(simd)
        switch (v1) {/*
        case is Vector2<Float> :
            return unsafeBitCast(unsafeBitCast(v1, to: float2.self) * unsafeBitCast(v2, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(unsafeBitCast(v1, to: double2.self) * unsafeBitCast(v2, to: double2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(unsafeBitCast(v1, to: float4.self) * unsafeBitCast(v2, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(unsafeBitCast(v1, to: double4.self) * unsafeBitCast(v2, to: double4.self), to: T.self)*/
        default: break
        }
    #endif
    return T(v1, v2, *)
}

public func *=<T: VectorType>(v1: inout T, v2: T) {
    v1 = v1 * v2
}

public func /<T: VectorType>(v1: T, v2: T) -> T {
    #if canImport(simd)
        switch (v1) {/*
        case is Vector2<Int32>, is Vector2<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int2.self) / unsafeBitCast(v2, to: int2.self), to: T.self)

        case is Vector4<Int32>, is Vector4<UInt32> :
            return unsafeBitCast(unsafeBitCast(v1, to: int4.self) / unsafeBitCast(v2, to: int4.self), to: T.self)

        case is Vector2<Float> :
            return unsafeBitCast(unsafeBitCast(v1, to: float2.self) / unsafeBitCast(v2, to: float2.self), to: T.self)

        case is Vector2<Double> :
            return unsafeBitCast(unsafeBitCast(v1, to: double2.self) / unsafeBitCast(v2, to: double2.self), to: T.self)

        case is Vector4<Float> :
            return unsafeBitCast(unsafeBitCast(v1, to: float4.self) / unsafeBitCast(v2, to: float4.self), to: T.self)

        case is Vector4<Double> :
            return unsafeBitCast(unsafeBitCast(v1, to: double4.self) / unsafeBitCast(v2, to: double4.self), to: T.self)
*/
        default:
            break
        }
    #endif
    return T(v1, v2, /)
}

public func /=<T: VectorType>(v1: inout T, v2: T) {
    v1 = v1 / v2
}

public struct Vector3b: BooleanVectorType {
    public typealias BooleanVector = Vector3b

    public var x: Bool, y: Bool, z: Bool

    public var r: Bool { get { return x } set { x = newValue } }
    public var g: Bool { get { return y } set { y = newValue } }
    public var b: Bool { get { return z } set { z = newValue } }

    public var s: Bool { get { return x } set { x = newValue } }
    public var t: Bool { get { return y } set { y = newValue } }
    public var p: Bool { get { return z } set { z = newValue } }

    public var elements: [Bool] {
        return [x, y, z]
    }

    public func makeIterator() -> IndexingIterator<Array<Bool>> {
        return elements.makeIterator()
    }

    public subscript(index: Int) -> Bool {
        get {
            switch(index) {
            case 0: return x
            case 1: return y
            case 2: return z
            default: preconditionFailure("Vector index out of range")
            }
        }
        set {
            switch(index) {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: preconditionFailure("Vector index out of range")
            }
        }
    }

    public var debugDescription: String {
        return String(describing: type(of: self)) + "(\(x), \(y), \(z))"
    }
/*
    public func hash(into hasher: inout Hasher) {
        hasher.combine(SGLMath.hash(x.hashValue, y.hashValue, z.hashValue))
    }*/

    public init () {
        self.x = false
        self.y = false
        self.z = false
    }

    public init (_ v: Bool) {
        self.x = v
        self.y = v
        self.z = v
    }

    public init (_ x: Bool, _ y: Bool, _ z: Bool) {
        self.x = x
        self.y = y
        self.z = z
    }
/*
    public init (_ v: Vector2b, _ z: Bool) {
        self.x = v.x
        self.y = v.y
        self.z = z
    }

    public init (_ x: Bool, _ v: Vector2b) {
        self.x = x
        self.y = v.x
        self.z = v.y
    }*/

    public init (x: Bool, y: Bool, z: Bool) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init (r: Bool, g: Bool, b: Bool) {
        self.x = r
        self.y = g
        self.z = b
    }

    public init (s: Bool, t: Bool, p: Bool) {
        self.x = s
        self.y = t
        self.z = p
    }

    public init (_ v: Vector3b) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
    }
/*
    public init (_ v: Vector4b) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
    }*/

    public init (_ s: Bool, _ v: Vector3b, _ op:(_:Bool, _:Bool) -> Bool) {
        self.x = op(s, v.x)
        self.y = op(s, v.y)
        self.z = op(s, v.z)
    }

    public init (_ v: Vector3b, _ s: Bool, _ op:(_:Bool, _:Bool) -> Bool) {
        self.x = op(v.x, s)
        self.y = op(v.y, s)
        self.z = op(v.z, s)
    }

    public init(_ v: Vector3b, _ op:(_:Bool) -> Bool) {
        self.x = op(v[0])
        self.y = op(v[1])
        self.z = op(v[2])
    }

    public init<T: VectorType>(_ v: T, _ op:(_:T.Element) -> Bool) where T.BooleanVector == BooleanVector {
            self.x = op(v[0])
            self.y = op(v[1])
            self.z = op(v[2])
    }

    public init<T1: VectorType, T2: VectorType>(_ v1: T1, _ v2: T2, _ op:(_:T1.Element, _:T2.Element) -> Bool) where
        T1.BooleanVector == BooleanVector, T2.BooleanVector == BooleanVector {
            self.x = op(v1[0], v2[0])
            self.y = op(v1[1], v2[1])
            self.z = op(v1[2], v2[2])
    }

    public static func ==(v1: Vector3b, v2: Vector3b) -> Bool {
        return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z
    }
}
public final class SGLMath {
  public static func SGLsqrt<T: FloatingPointArithmeticType>(_ x: T) -> T {
      if let z = x as? Double {
          return sqrt(z) as! T
      }
      if let z = x as? Float {
          return sqrtf(z) as! T
      }
      preconditionFailure()
  }
}
public func length<genType: VectorType>(_ x: genType) -> genType.Element where genType.Element: FloatingPointArithmeticType {
    return SGLMath.SGLsqrt(dot(x, x))
}

public func distance<genType: VectorType>(_ p0: genType, _ p1: genType) -> genType.Element where genType.Element: FloatingPointArithmeticType {
    return length(p0 - p1)
}

public func dot<genType: VectorType>(_ x: genType, _ y: genType) -> genType.Element where genType.Element: FloatingPointArithmeticType {
    switch (x) {
    /*case is Vector2<genType.Element>:
        let xx = x as! Vector2<genType.Element>
        let yy = y as! Vector2<genType.Element>
        return xx.x * yy.x + xx.y * yy.y
*/
    case is Vector3<genType.Element>:
        let xx = x as! Vector3<genType.Element>
        let yy = y as! Vector3<genType.Element>
        let z = xx.x * yy.x + xx.y * yy.y
        return z + xx.z * yy.z
/*
    case is Vector4<genType.Element>:
        let xx = x as! Vector4<genType.Element>
        let yy = y as! Vector4<genType.Element>
        let z = xx.x * yy.x + xx.y * yy.y
        return z + xx.z * yy.z + xx.w * yy.w
*/
    default:
        preconditionFailure()
    }
    // Above is a bit faster in debug builds
    //let a = genType(x, y, *)
    //return a.reduce(0) { $0 + ($1 as! genType.Element) }
}

public func cross<T: FloatingPointArithmeticType>(_ x: Vector3<T>, _ y: Vector3<T>) -> Vector3<T> {
        var x1: T = x.y * y.z
            x1 = x1 - y.y * x.z
        var y1: T = x.z * y.x
            y1 = y1 - y.z * x.x
        var z1: T = x.x * y.y
            z1 = z1 - y.x * x.y
        return Vector3<T>(x1, y1, z1)
}

public func normalize<genType: VectorType>(_ x: genType) -> genType where genType.Element: FloatingPointArithmeticType {
    return x / length(x)
}
