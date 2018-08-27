//
//  Snapshot.swift
//  HSLuvColor
//
//  Created by Clay Smith on 6/17/15.
//  Copyright © 2015 Clay Smith. All rights reserved.
//

import Foundation
import XCTest
@testable import HSLuv

// TODO: Add HPLuv support

typealias SnapshotType = [String: [String: [Double]]]

class Snapshot {
    static var hexSamples: [String] = {
        let samples = "0123456789abcdef"

        var hexSamples = [String]()
        samples.forEach { r in
            samples.forEach { g in
                samples.forEach { b in
                    hexSamples.append("#\(r)\(r)\(g)\(g)\(b)\(b)")
                }
            }
        }

        return hexSamples
    }()

    static var stable: SnapshotType = {
        guard let url = Bundle(for: Snapshot.self).url(forResource: "snapshot-rev4", withExtension: "json") else {
            fatalError("Snapshot JSON file is missing")
        }

        let jsonData = try! Data(contentsOf: url, options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! SnapshotType

        return jsonResult
    }()

    static var current: SnapshotType = {
        var current = SnapshotType()

        for sample in Snapshot.hexSamples {
            let hex = Hex(sample)

            let rgb = hex.toRgb
            let xyz = rgb.toXyz
            let luv = xyz.toLuv
            let lch = luv.toLch
            let hsluv = lch.toHSLuv

            current[sample] = [
                "rgb": [rgb.r, rgb.g, rgb.b],
                "xyz": [xyz.x, xyz.y, xyz.z],
                "luv": [luv.l, luv.u, luv.v],
                "lch": [lch.l, lch.c, lch.h],
                "hsluv": [hsluv.h, hsluv.s, hsluv.l]
            ]
        }

        return current
    }()

    static func compare(_ snapshot: SnapshotType,
                        block: (_ hex: String, _ tag: String, _ stableTuple: [Double], _ currentTuple: [Double], _ stableChannel: Double, _ currentChannel: Double) -> Void) {

        hexes: for (hex, stableSamples) in stable {
            guard let currentSamples = current[hex] else {
                fatalError("Current sample is missing at \(hex)")
            }

            tags: for (tag, stableTuple) in stableSamples {
                if tag == "hpluv" {
                    continue tags
                }

                guard let currentTuple = currentSamples[tag] else {
                    fatalError("Current tuple is missing at \(hex):\(tag)")
                }

                channels: for i in [0...2] {
                    guard let stableChannel = stableTuple[i].first, let currentChannel = currentTuple[i].first else {
                        fatalError("Current channel is missing at \(hex):\(tag):\(i)")
                    }

                    block(hex, tag, stableTuple, currentTuple, stableChannel, currentChannel)
                }
            }
        }
    }
}
