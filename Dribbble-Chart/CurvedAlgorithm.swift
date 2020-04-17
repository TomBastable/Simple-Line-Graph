//
//  CurvedAlgorithm.swift
//  Dribbble-Chart
//
//  Created by Tom Bastable on 06/04/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation
import UIKit

struct CurvedSegment {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
}

class CurveAlgorithm {
    static let shared = CurveAlgorithm()
    
    private func controlPointsFrom(points: [CGPoint]) -> [CurvedSegment] {
        var result: [CurvedSegment] = []
        
        let delta: CGFloat = 0.3 // The value that help to choose temporary control points.
        
        // Calculate temporary control points, these control points make Bezier segments look straight and not curving at all
        for value in 1..<points.count {
            let pointA = points[value-1]
            let pointB = points[value]
            let controlPoint1 = CGPoint(x: pointA.x + delta*(pointB.x-pointA.x), y: pointA.y + delta*(pointB.y - pointA.y))
            let controlPoint2 = CGPoint(x: pointB.x - delta*(pointB.x-pointA.x), y: pointB.y - delta*(pointB.y - pointA.y))
            let curvedSegment = CurvedSegment(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            result.append(curvedSegment)
        }
        
        // Calculate good control points
        for value in 1..<points.count-1 {
            /// A temporary control point
            let pointM = result[value-1].controlPoint2
            
            /// A temporary control point
            let pointN = result[value].controlPoint1
            
            /// central point
            let pointA = points[value]
            
            /// Reflection of M over the point A
            let pointMM = CGPoint(x: 2 * pointA.x - pointM.x, y: 2 * pointA.y - pointM.y)
            
            /// Reflection of N over the point A
            let pointNN = CGPoint(x: 2 * pointA.x - pointN.x, y: 2 * pointA.y - pointN.y)
            
            result[value].controlPoint1 = CGPoint(x: (pointMM.x + pointN.x)/2, y: (pointMM.y + pointN.y)/2)
            result[value-1].controlPoint2 = CGPoint(x: (pointNN.x + pointM.x)/2, y: (pointNN.y + pointM.y)/2)
        }
        
        return result
    }
    
    /**
     Create a curved bezier path that connects all points in the dataset
     */
    func createCurvedPath(_ dataPoints: [CGPoint]) -> UIBezierPath? {
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        var curveSegments: [CurvedSegment] = []
        curveSegments = controlPointsFrom(points: dataPoints)
        
        for value in 1..<dataPoints.count {
            path.addCurve(to: dataPoints[value], controlPoint1: curveSegments[value-1].controlPoint1, controlPoint2: curveSegments[value-1].controlPoint2)
        }
        return path
    }
}
