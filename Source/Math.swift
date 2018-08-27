//
// The MIT License (MIT)
//
// Copyright © 2015 Alexei Boronine
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

// Using structs instead of tuples prevents implicit conversion,
// which was making debugging difficult

public typealias ColorTuple = (Double, Double, Double)

public protocol TupleConvertible {
    var tuple: ColorTuple { get }
}

// MARK: - Color Constants

struct Constant {
    static var m = (
        R: ColorTuple(3.2409699419045214, -1.5373831775700935, -0.49861076029300328),
        G: ColorTuple(-0.96924363628087983, 1.8759675015077207, 0.041555057407175613),
        B: ColorTuple(0.055630079696993609, -0.20397695888897657, 1.0569715142428786)
    )

    static var mInv = (
        X: ColorTuple(0.41239079926595948, 0.35758433938387796, 0.18048078840183429),
        Y: ColorTuple(0.21263900587151036, 0.71516867876775593, 0.072192315360733715),
        Z: ColorTuple(0.019330818715591851, 0.11919477979462599, 0.95053215224966058)
    )

    // Hard-coded D65 standard illuminant
    static var refU = 0.19783000664283681
    static var refV = 0.468319994938791

    // CIE LUV constants
    static var kappa = 903.2962962962963
    static var epsilon = 0.0088564516790356308

    // Swift limitations
    static var maxDouble = Double.greatestFiniteMagnitude
}
// MARK: - Vector math

typealias Vector = (Double, Double)

/// For a given lightness, return a list of 6 lines in slope-intercept
/// form that represent the bounds in CIELUV, stepping over which will
/// push a value out of the RGB gamut
///
/// - parameter lightness: Double
func getBounds(lightness L: Double) -> [Vector] {
    let sub1: Double = pow(L + 16, 3) / 1560896
    let sub2 = sub1 > Constant.epsilon ? sub1 : L / Constant.kappa

    var result = [Vector]()

    let mirror = Mirror(reflecting: Constant.m)
    for (_, value) in mirror.children {
        let (m1, m2, m3) = value as! ColorTuple

        for t in [0.0, 1.0] {
            let top1 = (284517 * m1 - 94839 * m3) * sub2
            let top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * L * sub2 - 769860 * t * L
            let bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t

            result.append((top1 / bottom, top2 / bottom))
        }
    }

    return result
}

func intersectLine(_ line1: Vector, _ line2: Vector) -> Double {
    return (line1.1 - line2.1) / (line2.0 - line1.0)
}

func distanceFromPole(_ point: Vector) -> Double {
    return sqrt(pow(point.0, 2) + pow(point.1, 2))
}

func lengthOfRayUntilIntersect(theta: Double, line: Vector) -> Double? {
    // theta  -- angle of ray starting at (0, 0)
    // m, b   -- slope and intercept of line
    // x1, y1 -- coordinates of intersection
    // length -- length of ray until it intersects with line
    //
    // b + m * x1          = y1
    // length             >= 0
    // length * cos(theta) = x1
    // length * sin(theta) = y1
    //
    //
    // b + m * (length * cos(theta)) = length * sin(theta)
    // b = length * sin(hrad) - m * length * cos(theta)
    // b = length * (sin(hrad) - m * cos(hrad))
    // len = b / (sin(hrad) - m * cos(hrad))

    let (m1, b1) = line
    let length = b1 / (sin(theta) - m1 * cos(theta))

    if length < 0 {
        return nil
    }

    return length
}

func dotProduct<T: TupleConvertible>(_ a: ColorTuple, b: T) -> Double {
    let b = b.tuple

    var ret = 0.0

    ret += a.0 * b.0
    ret += a.1 * b.1
    ret += a.2 * b.2

    return ret
}
