//
// The MIT License (MIT)
//
// Copyright © 2015 Clay Smith
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

/// Hexadecimal color
public struct Hex {
    public let string: String

    public init(_ string: String) {
        self.string = string
    }
}

/// Red, Green, Blue (RGB)
public struct RGB: TupleConvertible {
    public var r: Double
    public var g: Double
    public var b: Double

    public init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    public var tuple: ColorTuple {
        return (r, g, b)
    }
}

/// Luminance, Blue-stimulation, Cone-response [CIE 1931] (XYZ)
public struct XYZ: TupleConvertible {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var tuple: ColorTuple {
        return (x, y, z)
    }
}

/// L*, u*, v* [CIE 1976] (LUV)
public struct LUV {
    public var l: Double
    public var u: Double
    public var v: Double

    public init(l: Double, u: Double, v: Double) {
        self.l = l
        self.u = u
        self.v = v
    }
}

/// Lightness, Chroma, Hue (LCH)
public struct LCH {
    public var l: Double
    public var c: Double
    public var h: Double

    public init(l: Double, c: Double, h: Double) {
        self.l = l
        self.c = c
        self.h = h
    }
}

public protocol HSLInitable {
    init(h: Double, s: Double, l: Double)
}

/// HSLuv: Hue(man), Saturation, Lightness (HSLuv)
public struct HSLuv: HSLInitable {
    public var h: Double
    public var s: Double
    public var l: Double

    public init(h: Double, s: Double, l: Double) {
        self.h = h
        self.s = s
        self.l = l
    }
}

/// HPLuv: Hue(pastel), Saturation, Lightness (HPLuv)
public struct HPLuv: HSLInitable {
    public var h: Double
    public var s: Double
    public var l: Double

    public init(h: Double, s: Double, l: Double) {
        self.h = h
        self.s = s
        self.l = l
    }
}
