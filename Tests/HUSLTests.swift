//
//  Common.swift
//  HUSLSwift
//
//  Created by Clay Smith on 6/16/15.
//  Copyright © 2015 Clay Smith. All rights reserved.
//

import Foundation
import XCTest
@testable import HUSLSwift

class HUSLTests: XCTestCase {
  
  let tolerance = 0.00000001
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testHUSLConsistency() {
    let hsl = rgbToHusl(RGBTuple(0.9175225466, 0, 0.3938514752))
    
    XCTAssertEqualWithAccuracy(hsl.H, 0, accuracy: tolerance)
    XCTAssertEqualWithAccuracy(hsl.S, 100.0, accuracy: tolerance)
    XCTAssertEqualWithAccuracy(hsl.L, 50.0, accuracy: tolerance)
  }
  
  func testRGBConsistency() {
    let rgb = huslToRgb(HUSLTuple(0, 100, 50))
    
    XCTAssertEqualWithAccuracy(rgb.R, 0.9175225466, accuracy: tolerance)
    XCTAssertEqualWithAccuracy(rgb.G, 0, accuracy: tolerance)
    XCTAssertEqualWithAccuracy(rgb.B, 0.3938514752, accuracy: tolerance)
  }
  
  func testBackAndForthConsistency() {
    let originalRgb = RGBTuple(0.51, 0.251, 0.557)
    
    let returnedRgb = huslToRgb(rgbToHusl(originalRgb))
    
    XCTAssertEqualWithAccuracy(originalRgb.R, returnedRgb.R, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(originalRgb.G, returnedRgb.G, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(originalRgb.B, returnedRgb.B, accuracy: 0.01)
  }
  
  
}
