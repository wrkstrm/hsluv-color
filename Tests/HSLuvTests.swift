//
//  Common.swift
//  HSLuvColor
//
//  Created by Clay Smith on 6/16/15.
//  Copyright © 2015 Clay Smith. All rights reserved.
//

import Foundation
import XCTest
@testable import HSLuv

// TODO: Add HPLuv tests

class HSLuvTests: XCTestCase {
    let rgbRangeTolerance = 0.000000001
    let snapshotTolerance = 0.000000001

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        continueAfterFailure = false
    }

    func testConversionConsistency() {
        for hex in Snapshot.hexSamples {
            let rgb  = Hex(hex).toRgb
            let xyz  = rgb.toXyz
            let luv  = xyz.toLuv
            let lch  = luv.toLch
            let hsluv = lch.toHSLuv

            let toLch = hsluv.toLch
            let toLuv = toLch.toLUV
            let toXyz = toLuv.toXYZ
            let toRgb = toXyz.toRGB
            let toHex = toRgb.toHex

            XCTAssertEqual(lch.L, toLch.L, accuracy: rgbRangeTolerance)
            XCTAssertEqual(lch.C, toLch.C, accuracy: rgbRangeTolerance)
            XCTAssertEqual(lch.H, toLch.H, accuracy: rgbRangeTolerance)

            XCTAssertEqual(luv.L, toLuv.L, accuracy: rgbRangeTolerance)
            XCTAssertEqual(luv.U, toLuv.U, accuracy: rgbRangeTolerance)
            XCTAssertEqual(luv.V, toLuv.V, accuracy: rgbRangeTolerance)

            XCTAssertEqual(xyz.X, toXyz.X, accuracy: rgbRangeTolerance)
            XCTAssertEqual(xyz.Y, toXyz.Y, accuracy: rgbRangeTolerance)
            XCTAssertEqual(xyz.Z, toXyz.Z, accuracy: rgbRangeTolerance)

            XCTAssertEqual(rgb.R, toRgb.R, accuracy: rgbRangeTolerance)
            XCTAssertEqual(rgb.G, toRgb.G, accuracy: rgbRangeTolerance)
            XCTAssertEqual(rgb.B, toRgb.B, accuracy: rgbRangeTolerance)

            XCTAssertEqual(hex, toHex.string)
        }
    }

    func testRgbRangeTolerance() {
        for h in stride(from: 0.0, through: 360, by: 5) {
            for s in stride(from: 0.0, through: 100, by: 5) {
                for l in stride(from: 0.0, through: 100, by: 5) {
                    let tRgb = hsluvToRgb(HSLuv(h, s, l))
                    let rgb = [tRgb.R, tRgb.G, tRgb.B]

                    for channel in rgb {
                        XCTAssertGreaterThan(channel, -rgbRangeTolerance, "HSLuv: \([h, s, l]) -> RGB: \(rgb)")
                        XCTAssertLessThanOrEqual(channel, 1 + rgbRangeTolerance, "HSLuv: \([h, s, l]) -> RGB: \(rgb)")
                    }
                }
            }
        }
    }

    func testSnapshot() {
        Snapshot.compare(Snapshot.current) { [snapshotTolerance] hex, tag, stableTuple, currentTuple, stableChannel, currentChannel in
            let diff = abs(currentChannel - stableChannel)

            XCTAssertLessThan(diff, snapshotTolerance,
                              "Snapshots for \(hex) don't match at \(tag): (stable: \(stableTuple), current: \(currentTuple)")
        }
    }
}
