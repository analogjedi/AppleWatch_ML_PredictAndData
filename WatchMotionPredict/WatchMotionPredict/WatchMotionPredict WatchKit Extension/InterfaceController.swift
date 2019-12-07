//
//  InterfaceController.swift
//  WatchMotionPredict WatchKit Extension
//
//  Created by Arnav Reddy on 12/1/19.
//  Copyright © 2019 Arnav Reddy2. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import CoreML

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var predictionLabel: WKInterfaceLabel! //UI components
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    var dataStream = Timer()
    var recordTimer = Timer()
    var isPlaying = false
    var timeStamp = 0.0
    var stopWatchTime = 0.0
    let classifier = BaseballVsBasketabll_12epochs()
    var currentIndexInPredictionWindow = 0
    let motion = CMMotionManager() //sensor data manager
    
    struct ModelConstants {  //values specifies while training model
      static let numOfFeatures = 7
      static let predictionWindowSize = 100
      static let hiddenInLength = 200
      static let hiddenCellInLength = 200
    }
    
   let accX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber], //All the arrays of sensor data
        dataType: MLMultiArrayDataType.double)
    let accY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let rotZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let timeStampArray = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber], //Array of one of the model params
        dataType: MLMultiArrayDataType.double)
    var currentState = try? MLMultiArray( //the last output is inputted to the model
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    override func awake(withContext context: Any?) {

        super.awake(withContext: context)
        timeLabel.setText(String(stopWatchTime))
        let motion = CMMotionManager() //data manager

        stopDeviceMotion() //makes sure no data is being recieve at the beginning
        if motion.isDeviceMotionAvailable { //checks which raw data can be used:watch only supports raw accel
           /// print(motion.isGyroAvailable ? "Gyro available" : "Gyro NOT available")
           /// print(motion.isAccelerometerAvailable ? "Accel available" : "Accel NOT available")
           /// print(motion.isMagnetometerAvailable ? "Mag available" : "Mag NOT available")
            motion.deviceMotionUpdateInterval = 1.0 / 60.0 //interval at which you update sensor data
            motion.showsDeviceMovementDisplay = true
            motion.startDeviceMotionUpdates(using: .xArbitraryZVertical) // what type of sensor data
            
            self.dataStream = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in //pulls in data at same interval
                if let data = motion.deviceMotion { //uses processed sensor data without bias
                    if self.stopWatchTime>0
                    {                                   //makes sure the timer has been pressed till 3 second
                        if self.stopWatchTime<3
                        {
                            DispatchQueue.global().async { //pulls thread
                            self.rotX![self.currentIndexInPredictionWindow] = data.rotationRate.x as NSNumber  //adds all sensor data and updating time stamp to the arrays
                            self.rotY![self.currentIndexInPredictionWindow] = data.rotationRate.y as NSNumber
                            self.rotZ![self.currentIndexInPredictionWindow] = data.rotationRate.z as NSNumber
                            self.accX![self.currentIndexInPredictionWindow] = data.userAcceleration.x as NSNumber
                            self.accY![self.currentIndexInPredictionWindow] = data.userAcceleration.y as NSNumber
                            self.accZ![self.currentIndexInPredictionWindow] = data.userAcceleration.z as NSNumber
                            self.timeStampArray![self.currentIndexInPredictionWindow] = self.timeStamp as NSNumber
                            self.currentIndexInPredictionWindow += 1 //moves the prediction range over
                            if (self.currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) { //resets if the model is at the end of prediction
                               self.currentIndexInPredictionWindow = 0
                                
                                }
                            }
                    
                            let modelPrediction = try? self.classifier.prediction( //predicts the action that is occuring using the data and time stamp
                                    Accel_X: self.accX!,
                                    Accel_Y: self.accY!,
                                    Accel_Z: self.accZ!,
                                    Gyro_X: self.rotX!,
                                    Gyro_Y: self.rotY!,
                                    Gyro_Z: self.rotZ!,
                                    Time_Stamp: self.timeStampArray!,
                                    stateIn: self.currentState) //last ouput helps predict next input
                                
                            self.predictionLabel.setText(modelPrediction?.label) //displays the action on screen
                            self.currentState = modelPrediction?.stateOut //captures output array
                            self.timeStamp+=0.001 //increments time stamp to create a horizontal graph
                        }
                        else{
                            self.stopDeviceMotion() //makes sure no background data is collected
                            self.stopIt() //stops the timer from going past 3
                            self.timeStamp = self.timeStamp-0.5 //resets time stamp back to 0
                            self.timeStamp.round()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func startPressed() {
        if(isPlaying) {
               return
           }
           startButton.setEnabled(false)
           recordTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true) //starts recording
           isPlaying = true
    }
    
    func stopIt()
    {
        startButton.setEnabled(true)
        recordTimer.invalidate() //stops recording
        isPlaying = false
        stopWatchTime = 0.0
        timeLabel.setText(String(stopWatchTime))
    }
    
    @objc func UpdateTimer() {
        stopWatchTime += 0.1 //increments the timer to create a stopwatch
        timeLabel.setText(String(format: "%.1f", stopWatchTime)) //shows stopwatch on screen
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        predictionLabel.setText("") //predict nothing before the user sees the screen
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func stopDeviceMotion() {
      guard motion.isDeviceMotionAvailable else {
        debugPrint("Core Motion Data Unavailable!")
        return
      }
    // Stop streaming device data
      motion.stopDeviceMotionUpdates()
    // Reset some parameters
      currentIndexInPredictionWindow = 0
      currentState = try? MLMultiArray(
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)
    }
}
