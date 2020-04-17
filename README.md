# Simple Line Graph
Created purely as a "Hmm, I've never made that before because I've always used a thirdparty." during Isolation. Based on the Dribbble design linked above. Simple install, easy usage. 

## Installation
To install, just move the SimpleChart.swift and CurvedAlgorithm.swift files into your project, alongside adding the bg-selected image into your asset catalogue. 

## Usage
Either create a UIView programatically or in storyboard, and assign the SimpleChart class to it. 

```swift
let simpleChart:SimpleChart = SimpleChart(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
```

Initialise the view by calling the setupChartWith function, inputting the charts labels and values (Double). If you want empty labels, submit empty strings.

```swift
var stubData:[Double] = [50, 130, 70, 220, 90, 280, 220]
var stubLabels = ["March 1", "March 12", "March 18", "March 20", "March 22", "March 25", "March 30"]

simpleChart.setupChartWith(labels: stubLabels, data:stubData)
```

Set the delegate in order to update the view with the latest selection using the ChartIndexChanged delegate method.

```swift
class ViewController: UIViewController, SimpleChartDelegate {

simpleChart.delegate = self

func chartIndexChanged(index: Int) {
     chartLabel.text = "\(Int(stubData[index]))"
}
```


![](ezgif-2-00085b1ff230.gif)
