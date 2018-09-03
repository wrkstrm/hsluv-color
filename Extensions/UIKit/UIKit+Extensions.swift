//
// The MIT License (MIT)
//
// Copyright (c) 2015 Clay Smith
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

import UIKit

public extension UIColor {
    /// Initializes and returns a color object using the specified opacity and
    /// HSLuv color space component values.
    ///
    /// - parameter hue: Double
    /// - parameter saturation: Double
    /// - parameter lightness: Double
    /// - parameter alpha: Double
    public convenience init(hue: Double, saturation: Double, lightness: Double, alpha: CGFloat) {
        let rgb = hsluvToRgb(HSLuv(h: hue, s: saturation, l: lightness))
        self.init(red: CGFloat(rgb.r),
                  green: CGFloat(rgb.g),
                  blue: CGFloat(rgb.b),
                  alpha: alpha)
    }

    /// Initializes and returns a color object using the specified opacity and
    /// HSLuv color space component values.
    ///
    /// - parameter hue: Double
    /// - parameter saturation: Double
    /// - parameter lightness: Double
    /// - parameter alpha: Double
    public convenience init(hsluv: HSLuv, alpha: CGFloat) {
        let rgb = hsluvToRgb(hsluv)
        self.init(red: CGFloat(rgb.r),
                  green: CGFloat(rgb.g),
                  blue: CGFloat(rgb.b),
                  alpha: alpha)
    }

    /// Initializes and returns a color object using the specified opacity and
    /// HPLuv color space component values.
    ///
    /// - parameter hue: Double
    /// - parameter saturation: Double
    /// - parameter lightness: Double
    /// - parameter alpha: Double
    public convenience init(hpluv: HPLuv, alpha: CGFloat) {
        let rgb = hpluvToRgb(hpluv)
        self.init(red: CGFloat(rgb.r),
                  green: CGFloat(rgb.g),
                  blue: CGFloat(rgb.b),
                  alpha: alpha)
    }

    /// Initializes and returns a color object using the specified opacity and
    /// HPL in regular iOS color space component values.
    ///
    /// - parameter hue: Double
    /// - parameter saturation: Double
    /// - parameter lightness: Double
    /// - parameter alpha: Double
    public convenience init(hsl: HSL, alpha: CGFloat) {
        self.init(hue: CGFloat(hsl.h),
                  saturation: CGFloat(hsl.s),
                  brightness: CGFloat(hsl.l),
                  alpha: alpha)
    }

    /// Convenience function to wrap the behavior of getRed(red:green:blue:alpha:)
    ///
    /// - returns: (rgb: RGB, alpha: CGFloat)
    public var getRGBA: (rgb: RGB, a: Double) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (RGB(r: Double(red), g: Double(green), b: Double(blue)), a: Double(alpha))
    }

    /// Convenience function to wrap the behavior of getHue(hue:saturation:lightness:alpha:)
    ///
    /// - returns: (rgb: RGB, alpha: CGFloat)
    public var getHSLA: (rgb: HSL, a: CGFloat) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var lightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        self.getHue(&hue, saturation: &saturation, brightness: &lightness, alpha: &alpha)
        return (HSL(h: Double(hue), s: Double(saturation), l: Double(lightness)), a: alpha)
    }
}
