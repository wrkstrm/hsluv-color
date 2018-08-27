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
    public var R: Double
    public var G: Double
    public var B: Double

    public init(_ R: Double, _ G: Double, _ B: Double) {
        self.R = R
        self.G = G
        self.B = B
    }

    public var tuple: ColorTuple {
        return (R, G, B)
    }
}

/// Luminance, Blue-stimulation, Cone-response [CIE 1931] (XYZ)
public struct XYZ: TupleConvertible {
    public var X: Double
    public var Y: Double
    public var Z: Double

    public init(_ X: Double, _ Y: Double, _ Z: Double) {
        self.X = X
        self.Y = Y
        self.Z = Z
    }

    public var tuple: ColorTuple {
        return (X, Y, Z)
    }
}

/// L*, u*, v* [CIE 1976] (LUV)
public struct LUV {
    public var L: Double
    public var U: Double
    public var V: Double

    public init(_ L: Double, _ U: Double, _ V: Double) {
        self.L = L
        self.U = U
        self.V = V
    }
}

/// Lightness, Chroma, Hue (LCH)
public struct LCH {
    public var L: Double
    public var C: Double
    public var H: Double

    public init(_ L: Double, _ C: Double, _ H: Double) {
        self.L = L
        self.C = C
        self.H = H
    }
}

/// HSLuv: Hue(man), Saturation, Lightness (HSLuv)
public struct HSLuv {
    public var H: Double
    public var S: Double
    public var L: Double

    public init(_ H: Double, _ S: Double, _ L: Double) {
        self.H = H
        self.S = S
        self.L = L
    }
}

/// HPLuv: Hue(pastel), Saturation, Lightness (HPLuv)
public struct HPLuv {
    public var H: Double
    public var S: Double
    public var L: Double

    public  init(_ H: Double, _ S: Double, _ L: Double) {
        self.H = H
        self.S = S
        self.L = L
    }
}
