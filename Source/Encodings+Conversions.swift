//
// The MIT License (MIT)
//
// Copyright © 2018 wrkstrm
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

// MARK: - XYZ/RGB Conversion

extension XYZ {

    func fromLinear(_ c: Double) -> Double {
        if c <= 0.0031308 {
            return 12.92 * c
        }

        return 1.055 * pow(c, 1 / 2.4) - 0.055
    }

    var toRGB: RGB {
        let r = fromLinear(dotProduct(Constant.m.R, b: self))
        let g = fromLinear(dotProduct(Constant.m.G, b: self))
        let B = fromLinear(dotProduct(Constant.m.B, b: self))

        return RGB(r: r, g: g, b: B)
    }
}

extension RGB {

    func toLinear(_ c: Double) -> Double {
        let a = 0.055
        if c > 0.04045 {
            return pow((c + a) / (1 + a), 2.4)
        }

        return c / 12.92
    }

    var toXyz: XYZ {
        let rgbl = RGB(r: toLinear(r), g: toLinear(g), b: toLinear(b))

        let x = dotProduct(Constant.mInv.X, b: rgbl)
        let y = dotProduct(Constant.mInv.Y, b: rgbl)
        let z = dotProduct(Constant.mInv.Z, b: rgbl)

        return XYZ(x: x, y: y, z: z)
    }
}

// MARK: - XYZ / LUV Conversion

// In these formulas, Yn refers to the reference white point. We are using
// illuminant D65, so Yn (see refY in Maxima file) equals 1. The formula is
// simplified accordingly.

extension XYZ {

    func yToL(_ Y: Double) -> Double {
        if Y <= Constant.epsilon {
            return Y * Constant.kappa
        }

        return 116 * pow(Y, 1/3) - 16
    }

    var toLuv: LUV {
        let varU = (4 * x) / (x + (15 * y) + (3 * z))
        let varV = (9 * y) / (x + (15 * y) + (3 * z))

        let l = yToL(y)

        guard l != 0 else {
            // Black will create a divide-by-zero error
            return LUV(l: 0, u: 0, v: 0)
        }

        let u = 13 * l * (varU - Constant.refU)
        let v = 13 * l * (varV - Constant.refV)

        return LUV(l: l, u: u, v: v)
    }
}

extension LUV {

    func lToY(_ L: Double) -> Double {
        if L <= 8 {
            return L / Constant.kappa
        }

        return pow((L + 16) / 116, 3)
    }

    var toXYZ: XYZ {
        guard l != 0 else {
            // Black will create a divide-by-zero error
            return XYZ(x: 0, y: 0, z: 0)
        }

        let varU = u / (13 * l) + Constant.refU
        let varV = v / (13 * l) + Constant.refV

        let y = lToY(l)
        let x = 0 - (9 * y * varU) / ((varU - 4) * varV - varU * varV)
        let z = (9 * y - (15 * varV * y) - (varV * x)) / (3 * varV)

        return XYZ(x: x, y: y, z: z)
    }
}

// MARK: - LUV / LCH Conversion

public extension LUV {

    var toLch: LCH {
        let c = sqrt(pow(u, 2) + pow(v, 2))

        guard c >= 0.00000001 else {
            // Greys: disambiguate hue
            return LCH(l: l, c: c, h: 0)
        }

        let Hrad = atan2(v, u)
        var h = Hrad * 360 / 2 / .pi

        if h < 0 {
            h = 360 + h
        }

        return LCH(l: l, c: c, h: h)
    }
}

public extension LCH {

    var toLUV: LUV {
        let hRad = h / 360 * 2 * .pi
        let u = cos(hRad) * c
        let v = sin(hRad) * c

        return LUV(l: l, u: u, v: v)
    }
}

// MARK: - HSLuv / LCH Conversion

/// For a given lightness and hue, return the maximum chroma that fits in
/// the RGB gamut.
func maxChroma(lightness L: Double, hue H: Double) -> Double {
    let hrad = H / 360 * Double.pi * 2

    var lengths = [Double]()
    for line in getBounds(lightness: L) {
        if let l = lengthOfRayUntilIntersect(theta: hrad, line: line) {
            lengths.append(l)
        }
    }

    return lengths.reduce(Constant.maxDouble) { min($0, $1) }
}

public extension HSLuv {

    var toLch: LCH {
        guard l <= 99.9999999 && l >= 0.00000001 else {
            // White and black: disambiguate chroma
            return LCH(l: l, c: 0, h: h)
        }

        let max = maxChroma(lightness: l, hue: h)
        let c = max / 100 * s

        return LCH(l: l, c: c, h: h)
    }
}

public extension LCH {
    public var toHSLuv: HSLuv {
        guard l <= 99.9999999 && l >= 0.00000001 else {
            // White and black: disambiguate saturation
            return HSLuv(h: h, s: 0, l: l)
        }

        let max = maxChroma(lightness: l, hue: h)
        let s = c / max * 100

        return HSLuv(h: h, s: s, l: l)
    }
}

// MARK: - Pastel HSLuv (HPLuv) / LCH Conversion

/// For given lightness, returns the maximum chroma. Keeping the chroma value
/// below this number will ensure that for any hue, the color is within the RGB
/// gamut.
func maxChroma(lightness L: Double) -> Double {
    var lengths = [Double]()

    for (m1, b1) in getBounds(lightness: L) {
        // x where line intersects with perpendicular running though (0, 0)
        let x = intersectLine((m1, b1), (-1 / m1, 0))
        lengths.append(distanceFromPole((x, b1 + x * m1)))
    }

    return lengths.reduce(Constant.maxDouble) { min($0, $1) }
}

public extension HPLuv {

    public var toLCH: LCH {
        guard l <= 99.9999999 && l >= 0.00000001 else {
            // White and black: disambiguate chroma
            return LCH(l: l, c: 0, h: h)
        }

        let max = maxChroma(lightness: l)
        let c = max / 100 * s

        return LCH(l: l, c: c, h: h)
    }
}

public extension LCH {

    public var toHPLuv: HPLuv {
        guard l <= 99.9999999 && l >= 0.00000001 else {
            // White and black: disambiguate saturation
            return HPLuv(h: h, s: 0, l: l)
        }

        let max = maxChroma(lightness: l)
        let s = c / max * 100

        return HPLuv(h: h, s: s, l: l)
    }
}

// MARK: - RGB / Hex Conversion

public extension RGB {

    func round(_ value: Double, places: Double) -> Double {
        let divisor = pow(10.0, places)
        return Foundation.round(value * divisor) / divisor
    }

    func getHexString(_ channel: Double) -> String {
        var ch = round(channel, places: 6)

        if ch < 0 || ch > 1 {
            // TODO: Implement Swift thrown errors
            fatalError("Illegal RGB value: \(ch)")
        }

        ch = Foundation.round(ch * 255.0)

        return String(Int(ch), radix: 16, uppercase: false).padding(toLength: 2, withPad: "0", startingAt: 0)
    }

    public var toHex: Hex {
        let R = getHexString(self.r)
        let G = getHexString(self.g)
        let B = getHexString(self.b)

        return Hex("#\(R)\(G)\(B)")
    }
}

public extension Hex {

    // This function is based on a comment by mehawk on gist arshad/de147c42d7b3063ef7bc.
    public var toRgb: RGB {
        let string = self.string.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)

        return RGB(r: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
                   g: Double((rgbValue & 0x00FF00) >> 8)  / 255.0,
                   b: Double( rgbValue & 0x0000FF)        / 255.0
        )
    }
}

// MARK: - HSLuv Conversion Requirements

public func hsluvToRgb(_ hsluv: HSLuv) -> RGB {
    return hsluv.toLch.toLUV.toXYZ.toRGB
}

public func hpluvToRgb(_ hpluv: HPLuv) -> RGB {
    return hpluv.toLCH.toLUV.toXYZ.toRGB
}

public func rgbToHsluv(_ rgb: RGB) -> HSLuv {
    return rgb.toXyz.toLuv.toLch.toHSLuv
}

public func rgbToHpluv(_ rgb: RGB) -> HPLuv {
    return rgb.toXyz.toLuv.toLch.toHPLuv
}
