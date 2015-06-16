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

// Using structs instead of tuples prevents implicit conversion,
// which was making debugging difficult

import Foundation

typealias Tuple = (Double, Double, Double)

protocol Deconstructable {
  var tuple: Tuple { get }
}

struct HUSLTuple: Deconstructable {
  var H: Double
  var S: Double
  var L: Double
  
  init(_ H: Double, _ S: Double, _ L: Double) {
    self.H = H
    self.S = S
    self.L = L
  }
  
  var tuple: Tuple {
    return (H, S, L)
  }
}

struct XYZTuple: Deconstructable {
  var X: Double
  var Y: Double
  var Z: Double
  
  init(_ X: Double, _ Y: Double, _ Z: Double) {
    self.X = X
    self.Y = Y
    self.Z = Z
  }
  
  var tuple: Tuple {
    return (X, Y, Z)
  }
}

struct RGBTuple: Deconstructable {
  var R: Double
  var G: Double
  var B: Double
  
  init(_ R: Double, _ G: Double, _ B: Double) {
    self.R = R
    self.G = G
    self.B = B
  }
  
  var tuple: Tuple {
    return (R, G, B)
  }
}

struct LCHTuple: Deconstructable {
  var L: Double
  var C: Double
  var H: Double
  
  init(_ L: Double, _ C: Double, _ H: Double) {
    self.L = L
    self.C = C
    self.H = H
  }
  
  var tuple: Tuple {
    return (L, C, H)
  }
}

struct LUVTuple: Deconstructable {
  var L: Double
  var U: Double
  var V: Double
  
  init(_ L: Double, _ U: Double, _ V: Double) {
    self.L = L
    self.U = U
    self.V = V
  }
  
  var tuple: Tuple {
    return (L, U, V)
  }
}