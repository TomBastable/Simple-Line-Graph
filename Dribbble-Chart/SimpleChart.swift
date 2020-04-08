//
//  SimpleChart.swift
//  Dribbble-Chart
//
//  Created by Tom Bastable on 05/04/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit

@objc protocol SimpleChartDelegate {
    @objc optional func chartIndexChanged(index:Int)
}

class SimpleChart: UIView, CAAnimationDelegate {
    
    //MARK: - Properties
    ///delegate - contains the chartindexchanged method to manage the charts current index in a VC
    var delegate:SimpleChartDelegate?
    ///contains all plots on the graph, ordered.
    var graphPlots:[CGPoint] = []
    ///contains all of the label origin points, ordered.
    var labelPoints:[CGPoint] = []
    ///the imageview for the point that shows which graph point is currently selected.
    let selectedPoint = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    ///contains the imageview that displays behind the selected point to further 
    let selectedBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    ///the charts label font - customisable
    var labelFont = UIFont.systemFont(ofSize: 9.0, weight: UIFont.Weight.semibold)
    ///the chart labels text alignment setting
    var labelAlignment:NSTextAlignment = .center
    ///the chart labels text color
    var labelColor = UIColor(red:0.94, green:0.63, blue:0.57, alpha:1.00)
    ///line layer for the graph
    var lineLayer = CAShapeLayer()
    ///temporarily contains the next point for the selectedpoint to assign its origin to
    private var newpoint:CGPoint?
    ///the interactive layer of the chart
    private let interactiveLayer:UIView = UIView(frame: CGRect.zero)
    ///the background layer of the chart
    private let backgroundLayer:UIView = UIView(frame: CGRect.zero)
    ///contains the current selected Index of the chart
    var currentIndex: Int?
    
    //MARK: - Awake From Nib
    override func awakeFromNib() {
       super.awakeFromNib()
        
        //setup the interative layer with a tap gesture, frames etc and add as subviews.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        interactiveLayer.addGestureRecognizer(tapGesture)
        interactiveLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        interactiveLayer.addSubview(selectedPoint)
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(backgroundLayer)
        self.addSubview(interactiveLayer)
        
        //setup background selection and add as subview
        selectedBackground.image = UIImage(named: "bg-selected")
        selectedBackground.contentMode = .scaleAspectFill
        selectedBackground.isHidden = true
        selectedBackground.alpha = 0.5
        self.backgroundLayer.addSubview(selectedBackground)
        
        //setup the selectedpoint and hide, ready for being unhidden during intial selection
        selectedPoint.isHidden = true
        selectedPoint.backgroundColor = UIColor(red:0.92, green:0.52, blue:0.33, alpha:1.00)
        selectedPoint.layer.cornerRadius = 10.0
        selectedPoint.layer.masksToBounds = true
        selectedPoint.layer.borderWidth = 5
        selectedPoint.layer.borderColor = UIColor.white.cgColor
        
        //ensure interactive layer is only enabled for interaction after successfully setting up the graph
        interactiveLayer.isUserInteractionEnabled = false
        
    }
    
    //MARK: - Setup Chart With Labels / Data
    ///function takes in the labels [String] and data [Double] and initialises the graph.
    func setupChartWith(labels:[String], data:[Double]){
        
        //**==Check for previous artifacts from historic loads==**\\
        //remove any existing line layers (In case this graph is being refreshed)
        if self.subviews.count > 2{
            lineLayer.removeFromSuperlayer()
            lineLayer = CAShapeLayer()
            graphPlots.removeAll()
            labelPoints.removeAll()
            currentIndex = nil
            selectedPoint.layer.removeAllAnimations()
            //reset selected background and point
            selectedBackground.frame.origin = CGPoint(x: 0, y: 0)
            selectedBackground.isHidden = true
            selectedPoint.isHidden = true
            selectedPoint.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        //remove all previous graph labels
            for view in self.subviews{
                if view.isKind(of: UILabel.self){
                    view.removeFromSuperview()
                }
            }
        }

        
        //check for mismatch in label and data count
        if labels.count != data.count{ interactiveLayer.isUserInteractionEnabled = false ; print("Number of labels do not match the number of data points") ; return }
       
        //**Find the points for each label at the bottom**\\
        ///The required width of each label
        let labelWidth:CGFloat = (self.frame.width / CGFloat(data.count))
        ///label height
        let labelHeight:CGFloat = 15
        ///bottom margin
        let marginBottom:CGFloat = 40
        ///correct y position for the label
        let labelYValue:CGFloat = self.frame.height - labelHeight
        selectedBackground.frame = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.height)
        //highest value & lowest value
        guard let highestValue = data.max(), let lowestValue = data.min() else { return }
        //difference between max min
        let difference = (highestValue - lowestValue)
        
        //loop through and create / place labels for each datapoint & organise CGPoints for graphPlots
        for i in 0..<labels.count{
            
            //computed property of xvalue
            var xValue:CGFloat{
                if i != 0{ return (CGFloat(i) * labelWidth)
                }else{ return 0 }
            }
            
            //**==Label Setup==**\\
            //setup the UILabel
            let dataLabel = UILabel(frame: CGRect(x: xValue, y: labelYValue, width: labelWidth, height: labelHeight))
            //assign the label text
            dataLabel.text = labels[i]
            //assign the labels font
            dataLabel.font = labelFont
            //setup the alignment of the label
            dataLabel.textAlignment = labelAlignment
            //setup the label text color
            dataLabel.textColor = labelColor
            //calculate the center point of the label and adjust the plot value, as each plot will be centered to the label.
            let halfWidth = labelWidth / 2
            
            //**==Graph Plot Setup==**\\
            //work out value percentage
            let valuePercentage = CGFloat((data[i] - lowestValue) / difference * 100)
            //height of the chart area, without margins
            let heightMinusMargins:CGFloat = (self.frame.height - (labelHeight + marginBottom))
            //yvalue of the graph plot
            let yValue = (heightMinusMargins - valuePercentage * (heightMinusMargins / 100))
            //create a CGPoint for the plot
            let valuePoint = CGPoint(x: dataLabel.frame.origin.x + halfWidth, y: yValue)
            //append graph plot
            graphPlots.append(valuePoint)
            //append labelpoint, for later use
            labelPoints.append(dataLabel.frame.origin)
            //finally, add the label as a subview
            self.addSubview(dataLabel)
            
        }
        //Once the plots and the labels have been calculated, draw the curved line.
        drawCurve(graphPlots: graphPlots)
        //enable user interaction
        interactiveLayer.isUserInteractionEnabled = true
    }
    
    //MARK: - Draw Curve
    ///Draws a curved line based on a series of CGPoints
    private func drawCurve(graphPlots:[CGPoint]) {
        
        //attempt to create a curved path based on a third party Curve Algoritm
        if let path = CurveAlgorithm.shared.createCurvedPath(graphPlots) {
            //create the shape layer, setup and add as sublayer.
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 5.0
            lineLayer.lineCap = .round
            self.backgroundLayer.layer.addSublayer(lineLayer)
        }
    }
    
    //MARK: - Handle Tap
    ///Handles the user interaction
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        
        //get the current tap position in the form of a CGPoint
        let currentPosition:CGPoint = sender.location(in: self)
        print(currentPosition)
        let labelWidth:CGFloat = (self.frame.width / CGFloat(graphPlots.count))
        
        //work out the desired datapoint index
        for point in labelPoints{
            
            //find the point that is within the range of each point
            if point.x...(point.x + labelWidth) ~= currentPosition.x{
                
                //get the tapped index
                guard let tappedIndex = labelPoints.firstIndex(of: point) else{ return }
                
                //confirm current index
                if var currentIndex = currentIndex{
                    
                    //zeroed difference property - will be updated later depdning on tap direction
                    var difference:Int = 0
                    //bool value that determines if the currentindex needs adding to or removing from
                    var isPlus:Bool { if currentIndex < tappedIndex {return true}else{return false}}
                    //check to see if the tapped index is the same as the currentIndex
                    if currentIndex == tappedIndex { return
                    //if the current index is less than the tapped index, work out the difference
                    }else if currentIndex < tappedIndex{ difference = tappedIndex - currentIndex
                    //if the current index is more than the tapped index, work out the difference
                    }else if currentIndex > tappedIndex{ difference = currentIndex - tappedIndex }
                    //empty array of animation plots
                    var animationPlots:[CGPoint] = []
                    //append the current index's plot
                    animationPlots.append(CGPoint(x: graphPlots[currentIndex].x, y: graphPlots[currentIndex].y))
                    
                    //loop through the plots between the current index and the tapped index - add to array
                    for i in 1...difference{
                        if isPlus {currentIndex += 1} else if !isPlus {currentIndex -= 1}
                        animationPlots.append(CGPoint(x: graphPlots[currentIndex].x, y: graphPlots[currentIndex].y))
                        if i == difference{ newpoint = graphPlots[currentIndex] }
                    }
                    
                    //animate the point based on the plots calculated above
                    animatePoint(points: animationPlots)
                    
                    //set the new current index
                    self.currentIndex = tappedIndex
                    //call the delegate function to reflect the new index
                    delegate?.chartIndexChanged?(index: self.currentIndex!)
                
                //interaction not initiated yet
                }else{
                    //unhide the point
                    selectedPoint.isHidden = false
                    //set the new origin
                    selectedPoint.frame.origin = CGPoint(x: graphPlots[tappedIndex].x - 10, y: graphPlots[tappedIndex].y - 10)
                    print(selectedPoint.frame.origin)
                    //set the current index
                    currentIndex = tappedIndex
                    //call the delegate to reflect change of index
                    delegate?.chartIndexChanged?(index: currentIndex!)
                }
                //animate the background selector
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveLinear, animations: { () -> Void in
                    self.selectedBackground.isHidden = false
                    self.selectedBackground.frame.origin = CGPoint(x: point.x, y: 0)
                })
                
            }
            
        }
        
    }
    
    //MARK: - Animate Point
    ///Animates based on a series of cgpoints between two points
    private func animatePoint(points:[CGPoint]){
        //same as above - calculate path, setup the animation and add to point as sublayer
        if let path = CurveAlgorithm.shared.createCurvedPath(points) {
            let anim: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
            anim.path = path.cgPath
            anim.repeatCount = 0
            anim.duration = 0.2
            anim.fillMode = .both
            anim.isRemovedOnCompletion = false
            anim.delegate = self
            selectedPoint.layer.add(anim, forKey: "animate position along path")
        }
    }
    
    //MARK: - Animation Did Stop - CAAnimationDelegate Method
    ///called when the animation stops - used to update the point layers frame after the animation is complete
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        selectedPoint.frame.origin = newpoint!
    }
}
