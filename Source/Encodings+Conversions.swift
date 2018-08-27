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
        let R = fromLinear(dotProduct(Constant.m.R, b: self))
        let G = fromLinear(dotProduct(Constant.m.G, b: self))
        let B = fromLinear(dotProduct(Constant.m.B, b: self))

        return RGB(R, G, B)
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
        let rgbl = RGB(toLinear(R), toLinear(G), toLinear(B))

        let X = dotProduct(Constant.mInv.X, b: rgbl)
        let Y = dotProduct(Constant.mInv.Y, b: rgbl)
        let Z = dotProduct(Constant.mInv.Z, b: rgbl)

        return XYZ(X, Y, Z)
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
        let varU = (4 * X) / (X + (15 * Y) + (3 * Z))
        let varV = (9 * Y) / (X + (15 * Y) + (3 * Z))

        let L = yToL(Y)

        guard L != 0 else {
            // Black will create a divide-by-zero error
            return LUV(0, 0, 0)
        }

        let U = 13 * L * (varU - Constant.refU)
        let V = 13 * L * (varV - Constant.refV)

        return LUV(L, U, V)
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
        guard L != 0 else {
            // Black will create a divide-by-zero error
            return XYZ(0, 0, 0)
        }

        let varU = U / (13 * L) + Constant.refU
        let varV = V / (13 * L) + Constant.refV

        let Y = lToY(L)
        let X = 0 - (9 * Y * varU) / ((varU - 4) * varV - varU * varV)
        let Z = (9 * Y - (15 * varV * Y) - (varV * X)) / (3 * varV)

        return XYZ(X, Y, Z)
    }
}

// MARK: - LUV / LCH Conversion

public extension LUV {

    var toLch: LCH {
        let C = sqrt(pow(U, 2) + pow(V, 2))

        guard C >= 0.00000001 else {
            // Greys: disambiguate hue
            return LCH(L, C, 0)
        }

        let Hrad = atan2(V, U)
        var H = Hrad * 360 / 2 / .pi

        if H < 0 {
            H = 360 + H
        }

        return LCH(L, C, H)
    }
}

public extension LCH {

    var toLUV: LUV {
        let Hrad = H / 360 * 2 * .pi
        let U = cos(Hrad) * C
        let V = sin(Hrad) * C

        return LUV(L, U, V)
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
        guard L <= 99.9999999 && L >= 0.00000001 else {
            // White and black: disambiguate chroma
            return LCH(L, 0, H)
        }

        let max = maxChroma(lightness: L, hue: H)
        let C = max / 100 * S

        return LCH(L, C, H)
    }
}

public extension LCH {
    public var toHSLuv: HSLuv {
        guard L <= 99.9999999 && L >= 0.00000001 else {
            // White and black: disambiguate saturation
            return HSLuv(H, 0, L)
        }

        let max = maxChroma(lightness: L, hue: H)
        let S = C / max * 100

        return HSLuv(H, S, L)
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
        guard L <= 99.9999999 && L >= 0.00000001 else {
            // White and black: disambiguate chroma
            return LCH(L, 0, H)
        }

        let max = maxChroma(lightness: L)
        let C = max / 100 * S

        return LCH(L, C, H)
    }
}

public extension LCH {

    public var toHPLuv: HPLuv {
        guard L <= 99.9999999 && L >= 0.00000001 else {
            // White and black: disambiguate saturation
            return HPLuv(H, 0, L)
        }

        let max = maxChroma(lightness: L)
        let S = C / max * 100

        return HPLuv(H, S, L)
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
        let R = getHexString(self.R)
        let G = getHexString(self.G)
        let B = getHexString(self.B)

        return Hex("#\(R)\(G)\(B)")
    }
}

public extension Hex {

    // This function is based on a comment by mehawk on gist arshad/de147c42d7b3063ef7bc.
    public var toRgb: RGB {
        let string = self.string.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)

        return RGB(
            Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            Double((rgbValue & 0x00FF00) >> 8)  / 255.0,
            Double( rgbValue & 0x0000FF)        / 255.0
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
