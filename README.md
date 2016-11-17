# RapidLogger
Rapid Logger captures all the log and able to display in device with neat UI.

And It also captures the crashes with screenshot and developer can able to screen list of crashes with Stack symobols.

And using rapid logger we can create video of the App from the device itself(Long press the rounded button for recording video).

![alt tag](https://github.com/krishna706/RapidLogger/blob/master/IMG_0123.PNG)
![alt tag](https://github.com/krishna706/RapidLogger/blob/master/IMG_0125.PNG)
![alt tag](https://github.com/krishna706/RapidLogger/blob/master/1.png)
![alt tag](https://github.com/krishna706/RapidLogger/blob/master/2.png)



# How to use it

1.Goto pch file and write below statement

  #import "RapidLogger.h"
  
2.In AppDelegate.m 

   -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       // Override point for customization after application launch.
    
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[RapidLogger sharedController] addLoggerButton];
       });
       return YES;
   }



