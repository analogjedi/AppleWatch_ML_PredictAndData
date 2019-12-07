# AppleWatch_ML_PredictAndData
creates an apple watch app that gets the accelerometer and gyroscope data and makes a Machine Learning model that uses the sensor data and predicts your action

First open the data xcode proj and change signing as well as build device to an apple watch

Then build the app and it should open on ur watch where you press start and complete your action. Every time you press start the data is printed to the console, so after each action press start and once you are satisfied with the amount of actions to made, copy all of the console output

Then paste that output into the input.csv file

Next change the url paths in SplitCSV.java so that it accesses your files in the correct directory as well as the directory names from Training/Throwing a Baseball to Training/Whatever your action is. Run SplitCSV.java
If that is done properly the console will output the number of files that have been created and will place them in the directory you specifed

After that take the training set folder that has sub folder(classes) which each have csv files within them, and drag that into your activity classifer through the createML app on mac that is offered once you have XCode installed

Once you have selected the training data, select all the checkboxes in the select features button and specify the number of iterations or epochs you would like to train

Then you train your model and drag your testing data that you acquired from the same data collection method once you are in the testing panel. Then press test and there you can see your model accuracy

After that you drag your model into the WatchMotionPredict project and within the InferenceController.swift file, change the line that says: classifier = ModelName() and replace the current model with the ModelName

Then change the signing and build device and deploy to your watch where it will predict your actions every time you press start and stops predicting after 3 seconds.

Enjoy!
