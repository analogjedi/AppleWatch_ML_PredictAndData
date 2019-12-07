//
//  InterfaceController.swift
//  WatchMotionData WatchKit Extension
//
//  Created by Arnav Reddy on 11/30/19.
//  Copyright © 2019 Arnav Reddy2. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var ActionLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
        var timer = Timer()
        var timer2 = Timer()
        var counter = 0.0
        var timeStamp = 0.000000
        var actionCounter = 0
        var isPlaying = false
        var csv = ""

        override func awake(withContext context: Any?) {
            super.awake(withContext: context)
            timeLabel.setText(String(counter))
            let motion = CMMotionManager()

            if motion.isDeviceMotionAvailable {
               /// print(motion.isGyroAvailable ? "Gyro available" : "Gyro NOT available")
               /// print(motion.isAccelerometerAvailable ? "Accel available" : "Accel NOT available")
               /// print(motion.isMagnetometerAvailable ? "Mag available" : "Mag NOT available")
                motion.deviceMotionUpdateInterval = 1.0 / 60.0
                motion.showsDeviceMovementDisplay = true
                motion.startDeviceMotionUpdates(using: .xArbitraryZVertical) // *******
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                    if let data = motion.deviceMotion {
                        if self.counter>0
                        {
                            if self.counter<3
                            {
                                self.startButton.setBackgroundColor(UIColor.red)
                                self.csv = self.csv+String(self.timeStamp) + ","
                                self.csv = self.csv+String(data.rotationRate.x) + ","
                                self.csv = self.csv+String(data.rotationRate.y) + ","
                                self.csv = self.csv+String(data.rotationRate.z) + ","
                                self.csv = self.csv+String(data.userAcceleration.x) + ","
                                self.csv = self.csv+String(data.userAcceleration.y) + ","
                                self.csv = self.csv+String(data.userAcceleration.z) + "\n"
                                self.timeStamp+=0.001
                            }
                            else{
                                self.stopIt()
                                self.timeStamp = self.timeStamp-0.5
                                self.timeStamp.round()
                                self.timeStamp+=1
                                self.startButton.setBackgroundColor(UIColor.green)
                            }
                        }
                    }
                }
            }
            // Configure interface objects here.
        }
        @IBAction func startPressed() {
            if(isPlaying) {
                   return
               }
               startButton.setEnabled(false)
               timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
               isPlaying = true
            print(self.csv)
            timeStamp = 0.000000
            self.csv = "Time Stamp, Gyro X, Gyro Y, Gyro Z, Accel X, Accel Y, Accel Z\n"
            actionCounter+=1
            ActionLabel.setText(String("Action: " + String(actionCounter)))
            
        }

        func stopIt()
        {
            startButton.setEnabled(true)
            timer2.invalidate()
            isPlaying = false
            counter = 0.0
            timeLabel.setText(String(counter))
        }

        @objc func UpdateTimer() {
            counter = counter + 0.1
            timeLabel.setText(String(format: "%.1f", counter))
        }
        override func willActivate() {
            // This method is called when watch view controller is about to be visible to user
            super.willActivate()
        }
        override func didDeactivate() {
            // This method is called when watch view controller is no longer visible
            super.didDeactivate()
        }
    }
